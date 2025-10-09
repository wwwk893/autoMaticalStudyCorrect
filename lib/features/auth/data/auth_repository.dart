import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/error_interceptor.dart';
import '../domain/session.dart';

enum LoginChannel { email, phone }

class AuthRepository {
  AuthRepository(this._read);

  final Reader _read;

  ApiClient get _client => _read(apiClientProvider);

  Future<UserSession> login({
    required String identifier,
    required String password,
    LoginChannel channel = LoginChannel.email,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'identifier': identifier,
        'password': password,
        'channel': channel.name,
      },
    );
    final body = response.data ?? <String, dynamic>{};
    return _parseSession(body);
  }

  Future<UserSession> refresh(String refreshToken) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final body = response.data ?? <String, dynamic>{};
    return _parseSession(body);
  }

  Future<void> revoke(String refreshToken) async {
    try {
      await _client.post<void>(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } on ApiErrorException {
      // Ignore network-side errors on logout to avoid blocking UX.
    } on DioException {
      // Ignore network-side errors on logout to avoid blocking UX.
    }
  }

  UserSession _parseSession(Map<String, dynamic> json) {
    return UserSession(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: json['userId']?.toString() ?? 'unknown',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read);
});
