import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/network/error_interceptor.dart';
import '../../submission/state/submission_models.dart';
import '../data/upload_repository.dart';

enum UploadStatus { idle, preprocessing, uploading, success, failure }

typedef UploadProgressCallback = void Function(double progress);

defaultProgressCallback(double progress) {}

class UploadState {
  const UploadState({
    this.status = UploadStatus.idle,
    this.progress = 0,
    this.errorMessage,
    this.compressionRatio = 1,
  });

  final UploadStatus status;
  final double progress;
  final String? errorMessage;
  final double compressionRatio;

  UploadState copyWith({
    UploadStatus? status,
    double? progress,
    String? errorMessage,
    double? compressionRatio,
  }) {
    return UploadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
      compressionRatio: compressionRatio ?? this.compressionRatio,
    );
  }
}

final uploadControllerProvider =
    StateNotifierProvider<UploadController, UploadState>((ref) {
  final controller = UploadController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

class UploadController extends StateNotifier<UploadState> {
  UploadController(this._ref) : super(const UploadState());

  final Ref _ref;

  UploadRepository get _repository => _ref.read(uploadRepositoryProvider);
  Logger get _logger => _ref.read(loggerProvider);

  Future<void> executeUpload({
    required String submissionId,
    required String assignmentId,
    required List<SubmissionPagePayload> pages,
    UploadProgressCallback onProgress = defaultProgressCallback,
  }) async {
    if (pages.isEmpty) return;
    state = state.copyWith(status: UploadStatus.preprocessing, progress: 0);
    final compression = pages
            .map((page) => page.processed.compressionRatio)
            .fold<double>(0, (prev, ratio) => prev + ratio) /
        pages.length;
    state = state.copyWith(compressionRatio: compression);
    try {
      final presign = await _repository.presignUpload(
        submissionId: submissionId,
        assignmentId: assignmentId,
        pageCount: pages.length,
      );
      state = state.copyWith(status: UploadStatus.uploading);
      var uploaded = 0;
      final totalBytes =
          pages.fold<int>(0, (sum, page) => sum + page.processed.bytes.length);
      for (final page in pages) {
        await _uploadSinglePage(
          page,
          presign,
          onChunkUploaded: (chunkBytes) {
            uploaded += chunkBytes;
            final progress = uploaded / max(totalBytes, 1);
            state = state.copyWith(progress: progress);
            onProgress(progress);
          },
        );
      }
      await _repository.notifyUploadCompleted(
        submissionId: submissionId,
        presign: presign,
      );
      state = state.copyWith(status: UploadStatus.success, progress: 1);
    } on ApiErrorException catch (e) {
      state = state.copyWith(
        status: UploadStatus.failure,
        errorMessage: e.apiError.message,
      );
      rethrow;
    } catch (error) {
      _logger.e('Upload failed', error);
      state = state.copyWith(
        status: UploadStatus.failure,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  Future<void> _uploadSinglePage(
    SubmissionPagePayload page,
    PresignUploadTicket ticket, {
    required void Function(int chunkBytes) onChunkUploaded,
  }) async {
    final chunkSize = ticket.chunkSize;
    final bytes = page.processed.bytes;
    var offset = 0;
    var partNumber = 1;
    while (offset < bytes.length) {
      final end = (offset + chunkSize).clamp(0, bytes.length);
      final chunk = bytes.sublist(offset, end);
      await _uploadWithRetry(
        () => _repository.uploadChunk(
          ticket,
          page.order,
          partNumber,
          chunk,
        ),
      );
      onChunkUploaded(chunk.length);
      offset = end;
      partNumber += 1;
    }
  }

  Future<void> _uploadWithRetry(Future<void> Function() uploader) async {
    const maxAttempts = 3;
    var attempt = 0;
    while (attempt < maxAttempts) {
      try {
        await uploader();
        return;
      } catch (error) {
        attempt += 1;
        if (attempt >= maxAttempts) {
          rethrow;
        }
        final delay = Duration(milliseconds: 500 * pow(2, attempt).toInt());
        _logger.w('Upload chunk failed attempt=$attempt retry in=$delay');
        await Future<void>.delayed(delay);
      }
    }
  }
}
