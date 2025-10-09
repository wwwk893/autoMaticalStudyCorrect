import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/offline_queue/offline_queue.dart';
import '../../../core/realtime/realtime_client.dart';
import '../../../core/utils/analytics.dart';
import '../../upload/application/upload_controller.dart';
import 'submission_models.dart';

class SubmissionFlowState {
  const SubmissionFlowState({
    this.active,
    this.history = const [],
    this.progress = 0,
    this.isUploading = false,
  });

  final SubmissionSummary? active;
  final List<SubmissionSummary> history;
  final double progress;
  final bool isUploading;

  SubmissionFlowState copyWith({
    SubmissionSummary? active,
    bool clearActive = false,
    List<SubmissionSummary>? history,
    double? progress,
    bool? isUploading,
  }) {
    return SubmissionFlowState(
      active: clearActive ? null : (active ?? this.active),
      history: history ?? this.history,
      progress: progress ?? this.progress,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

final submissionControllerProvider =
    StateNotifierProvider<SubmissionController, SubmissionFlowState>((ref) {
  final controller = SubmissionController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

class SubmissionController extends StateNotifier<SubmissionFlowState> {
  SubmissionController(this._ref) : super(const SubmissionFlowState());

  final Ref _ref;
  StreamSubscription<SubmissionStage>? _subscription;
  DateTime? _startTime;

  UploadController get _uploadController =>
      _ref.read(uploadControllerProvider.notifier);
  OfflineQueueController get _queue =>
      _ref.read(offlineQueueControllerProvider.notifier);
  RealtimeClient get _realtime => _ref.read(realtimeClientProvider);
  AnalyticsService get _analytics => _ref.read(analyticsProvider);

  Future<String> createSubmission({
    required String assignmentId,
    required List<SubmissionPagePayload> pages,
  }) async {
    await _subscription?.cancel();
    final submissionId = 'sub-${DateTime.now().millisecondsSinceEpoch}';
    _startTime = DateTime.now();
    final summary = SubmissionSummary(
      id: submissionId,
      assignmentId: assignmentId,
      stage: SubmissionStage.queued,
      pages: pages,
    );
    state = state.copyWith(
      active: summary,
      history: _merge(summary),
      progress: 0.05,
      isUploading: true,
    );
    _analytics.logSubmissionCreated(submissionId, pages.length);
    try {
      await _uploadController.executeUpload(
        submissionId: submissionId,
        assignmentId: assignmentId,
        pages: pages,
      );
    } catch (_) {
      await _queue.enqueue(
        OfflineQueueTask(
          type: 'submission',
          payload: {
            'submissionId': submissionId,
            'assignmentId': assignmentId,
            'pages': pages
                .map((p) => {
                      'localPath': p.localPath,
                      'order': p.order,
                    })
                .toList(),
          },
        ),
      );
    }
    _subscription = _realtime.watchSubmission(submissionId).listen(_onStage);
    return submissionId;
  }

  void _onStage(SubmissionStage stage) {
    final current = state.active;
    if (current == null) return;
    final updated = current.copyWith(
      stage: stage,
      score: stage == SubmissionStage.reported ? 90 : current.score,
    );
    final progress =
        (SubmissionStage.values.indexOf(stage) + 1) / SubmissionStage.values.length;
    state = state.copyWith(
      active: updated,
      history: _merge(updated),
      progress: progress,
      isUploading: stage != SubmissionStage.reported,
    );
    if (stage == SubmissionStage.reported && _startTime != null) {
      _analytics.logGradingDuration(
        updated.id,
        DateTime.now().difference(_startTime!),
      );
      unawaited(_queue.markComplete(updated.id));
    }
  }

  List<SubmissionSummary> _merge(SubmissionSummary summary) {
    final filtered =
        state.history.where((element) => element.id != summary.id).toList();
    return [summary, ...filtered];
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
