import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/error_interceptor.dart';

class PresignUploadTicket {
  const PresignUploadTicket({
    required this.uploadId,
    required this.chunkSize,
    required this.partUrls,
  });

  final String uploadId;
  final int chunkSize;
  final Map<String, Uri> partUrls;

  Uri resolveUrl(int pageOrder, int partNumber) {
    final key = '$pageOrder-$partNumber';
    return partUrls[key] ?? partUrls.values.first;
  }
}

class UploadRepository {
  UploadRepository(this._read);

  final Reader _read;
  ApiClient get _client => _read(apiClientProvider);

  Future<PresignUploadTicket> presignUpload({
    required String submissionId,
    required String assignmentId,
    required int pageCount,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/uploads/presign',
      data: {
        'submissionId': submissionId,
        'assignmentId': assignmentId,
        'pageCount': pageCount,
      },
    );
    final data = response.data ?? <String, dynamic>{};
    final chunkSize = data['chunkSize'] as int? ?? 5242880;
    final presigned = <String, Uri>{};
    final urls = data['urls'] as List<dynamic>? ?? const [];
    if (urls.isEmpty) {
      for (var page = 0; page < pageCount; page++) {
        presigned['$page-1'] = _client.config.objectStorageEndpoint
            .replace(path: '/uploads/$submissionId/$page');
      }
    } else {
      for (final entry in urls) {
        final page = entry['page'];
        final part = entry['part'];
        final url = entry['url'];
        if (page != null && part != null && url != null) {
          presigned['$page-$part'] = Uri.parse(url as String);
        }
      }
    }
    return PresignUploadTicket(
      uploadId: data['uploadId']?.toString() ?? submissionId,
      chunkSize: chunkSize,
      partUrls: presigned,
    );
  }

  Future<void> uploadChunk(
    PresignUploadTicket ticket,
    int pageOrder,
    int partNumber,
    List<int> chunk,
  ) async {
    final uri = ticket.resolveUrl(pageOrder, partNumber);
    await Future<void>.delayed(Duration(milliseconds: 200 + Random().nextInt(200)));
    if (Random().nextDouble() < 0.02) {
      throw ApiErrorException(
        apiError: const ApiError(code: 'UPLOAD_TIMEOUT', message: '网络波动'),
        requestOptions: RequestOptions(path: uri.toString()),
      );
    }
  }

  Future<void> notifyUploadCompleted({
    required String submissionId,
    required PresignUploadTicket presign,
  }) async {
    await _client.post<void>(
      '/uploads/complete',
      data: {
        'submissionId': submissionId,
        'uploadId': presign.uploadId,
      },
    );
  }
}

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  return UploadRepository(ref.read);
});
