import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../config.dart';
import '../networking/dio_client.dart';
import 'error_interceptor.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final logger = ref.watch(loggerProvider);
  final client = ApiClient(
    config: config,
    logger: logger,
  );
  ref.onDispose(client.dispose);
  return client;
});

final dioProvider = Provider<Dio>((ref) {
  final client = ref.watch(apiClientProvider);
  return client.dio;
});

final appConfigProvider = Provider<EnvConfig>((ref) {
  final logger = ref.watch(loggerProvider);
  return EnvConfig.load(logger: logger);
});

class ApiClient {
  ApiClient({required EnvConfig config, required Logger logger})
      : _config = config,
        _logger = logger,
        dio = Dio(
          BaseOptions(
            baseUrl: config.apiBaseUrl.toString(),
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 20),
            contentType: 'application/json',
          ),
        ) {
    dio.interceptors.add(
      ErrorInterceptor(
        logger: logger,
        onUnauthorized: (error) {
          _onUnauthorized?.call(error);
        },
      ),
    );
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final EnvConfig _config;
  final Logger _logger;
  final Dio dio;
  String? _token;
  void Function(ApiError error)? _onUnauthorized;

  EnvConfig get config => _config;

  void updateAuthToken(String? token) {
    _logger.i('Auth token updated ${token != null}');
    _token = token;
  }

  void registerUnauthorizedHandler(void Function(ApiError error)? handler) {
    _onUnauthorized = handler;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  void dispose() {
    dio.close(force: true);
  }
}
