import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/submission.dart';

class SubmissionFlowState {
  const SubmissionFlowState({
    this.current,
    this.history = const [],
    this.isUploading = false,
    this.progress = 0,
  });

  final Submission? current;
  final List<Submission> history;
  final bool isUploading;
  final double progress;

  SubmissionFlowState copyWith({
    Submission? current,
    bool clearCurrent = false,
    List<Submission>? history,
    bool? isUploading,
    double? progress,
  }) {
    return SubmissionFlowState(
      current: clearCurrent ? null : (current ?? this.current),
      history: history ?? this.history,
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
    );
  }
}

final submissionControllerProvider =
    StateNotifierProvider<SubmissionController, SubmissionFlowState>(
  (_) => SubmissionController(),
);

final submissionSummaryProvider = Provider<String>((ref) {
  final state = ref.watch(submissionControllerProvider);
  if (state.history.isEmpty) {
    return '暂无提交，点击“查看作业”开始体验拍照上传→判分流程。';
  }
  final latest = state.history.first;
  final statusLabel = _statusLabel(latest.status);
  final scoreLabel = latest.score != null ? '，得分 ${latest.score}' : '';
  return '最近提交 (${latest.assignmentId}) 状态：$statusLabel$scoreLabel';
});

class SubmissionController extends StateNotifier<SubmissionFlowState> {
  SubmissionController() : super(const SubmissionFlowState());

  StreamSubscription<SubmissionStatus>? _subscription;

  Future<String> create({
    required String assignmentId,
    int imageCount = 1,
  }) async {
    await _subscription?.cancel();
    final submissionId = 'sub-${DateTime.now().millisecondsSinceEpoch}';
    final submission = Submission(
      id: submissionId,
      assignmentId: assignmentId,
      status: SubmissionStatus.queued,
    );
    state = state.copyWith(
      current: submission,
      history: _mergeHistory(submission),
      isUploading: true,
      progress: 0.1,
    );
    _subscription = subscribe(submissionId).listen(_onStatusUpdate);
    return submissionId;
  }

  Stream<SubmissionStatus> subscribe(String submissionId) {
    final statuses = SubmissionStatus.values;
    return Stream.periodic(
      const Duration(seconds: 1),
      (tick) => statuses[tick],
    ).take(statuses.length);
  }

  void _onStatusUpdate(SubmissionStatus status) {
    final current = state.current;
    if (current == null) {
      return;
    }
    final score = status == SubmissionStatus.graded ? 87 : current.score;
    final updated = current.copyWith(status: status, score: score);
    final progress =
        (SubmissionStatus.values.indexOf(status) + 1) /
            SubmissionStatus.values.length;
    state = state.copyWith(
      current: updated,
      history: _mergeHistory(updated),
      progress: progress,
      isUploading: status != SubmissionStatus.reported,
    );
    if (status == SubmissionStatus.reported) {
      _subscription?.cancel();
    }
  }

  List<Submission> _mergeHistory(Submission submission) {
    return List.unmodifiable([
      submission,
      ...state.history.where((element) => element.id != submission.id),
    ]);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

String _statusLabel(SubmissionStatus status) {
  switch (status) {
    case SubmissionStatus.queued:
      return '排队中';
    case SubmissionStatus.ocr:
      return 'OCR 识别';
    case SubmissionStatus.parsed:
      return '解析中';
    case SubmissionStatus.graded:
      return '已判分';
    case SubmissionStatus.reported:
      return '报告生成';
  }
}
