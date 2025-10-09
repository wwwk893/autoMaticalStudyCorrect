import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiError {
  const ApiError({
    required this.code,
    required this.message,
    this.traceId,
    this.statusCode,
  });

  final String code;
  final String message;
  final String? traceId;
  final int? statusCode;

  @override
  String toString() => 'ApiError(code: $code, message: $message, traceId: $traceId)';
}

class ApiErrorException extends DioException {
  ApiErrorException({
    required this.apiError,
    required super.requestOptions,
    Response<dynamic>? response,
  }) : super(response: response, type: DioExceptionType.badResponse);

  final ApiError apiError;
}

class ErrorInterceptor extends Interceptor {
  ErrorInterceptor({
    required Logger logger,
    void Function(ApiError error)? onUnauthorized,
  })  : _logger = logger,
        _onUnauthorized = onUnauthorized;

  final Logger _logger;
  final void Function(ApiError error)? _onUnauthorized;

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('code') && data.containsKey('message')) {
      final code = data['code'];
      if (code != null && code != 0 && code != '0') {
        final error = ApiError(
          code: code.toString(),
          message: data['message']?.toString() ?? 'Unknown error',
          traceId: data['traceId']?.toString(),
          statusCode: response.statusCode,
        );
        _logger.e('API logical error ${error.code} traceId=${error.traceId}');
        handler.reject(
          ApiErrorException(
            apiError: error,
            requestOptions: response.requestOptions,
            response: response,
          ),
        );
        return;
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final parsed = _parseError(err);
    if (parsed != null) {
      if (err.response?.statusCode == 401) {
        _onUnauthorized?.call(parsed);
      }
      _logger.e('API error ${parsed.code} traceId=${parsed.traceId}', err);
      handler.next(
        ApiErrorException(
          apiError: parsed,
          requestOptions: err.requestOptions,
          response: err.response,
        ),
      );
      return;
    }
    handler.next(err);
  }

  ApiError? _parseError(DioException exception) {
    final response = exception.response;
    final data = response?.data;
    if (data is Map<String, dynamic> && data['code'] != null && data['message'] != null) {
      return ApiError(
        code: data['code'].toString(),
        message: data['message']?.toString() ?? 'Unknown error',
        traceId: data['traceId']?.toString(),
        statusCode: response?.statusCode,
      );
    }
    return null;
  }
}
