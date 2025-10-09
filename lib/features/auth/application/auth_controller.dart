import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/error_interceptor.dart';
import '../../../core/utils/analytics.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/session_repository.dart';
import '../../auth/domain/session.dart';

enum AuthStatus { unknown, unauthenticated, authenticating, authenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.session,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserSession? session;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    UserSession? session,
    bool clearSession = false,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : (session ?? this.session),
      errorMessage: errorMessage,
    );
  }
}

final authStateProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final controller = AuthController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState()) {
    _bootstrap();
  }

  final Ref _ref;
  bool _registeredUnauthorizedHandler = false;

  AuthRepository get _repository => _ref.read(authRepositoryProvider);
  SessionRepository get _sessionRepository =>
      _ref.read(sessionRepositoryProvider);
  ApiClient get _client => _ref.read(apiClientProvider);
  Logger get _logger => _ref.read(loggerProvider);
  AnalyticsService get _analytics => _ref.read(analyticsProvider);

  Future<void> _bootstrap() async {
    final session = await _sessionRepository.restore();
    if (session != null && !session.isExpired) {
      _client.updateAuthToken(session.accessToken);
      _registerUnauthorizedHandler();
      state = state.copyWith(status: AuthStatus.authenticated, session: session);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated, clearSession: true);
    }
  }

  Future<void> login({
    required String identifier,
    required String password,
    LoginChannel channel = LoginChannel.email,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final session = await _repository.login(
        identifier: identifier,
        password: password,
        channel: channel,
      );
      await _sessionRepository.persist(session);
      _client.updateAuthToken(session.accessToken);
      _registerUnauthorizedHandler();
      _analytics.logLoginSuccess(session.userId);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
      );
    } on ApiErrorException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.apiError.message,
      );
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refresh() async {
    final current = state.session;
    if (current == null) return;
    try {
      final refreshed = await _repository.refresh(current.refreshToken);
      await _sessionRepository.persist(refreshed);
      _client.updateAuthToken(refreshed.accessToken);
      state = state.copyWith(session: refreshed, status: AuthStatus.authenticated);
    } on ApiErrorException catch (e) {
      _logger.w('Refresh failed: ${e.apiError}');
      await logout(message: '会话已过期，请重新登录');
    } catch (error) {
      _logger.e('Refresh error', error);
    }
  }

  Future<void> logout({String? message}) async {
    final refreshToken = state.session?.refreshToken;
    if (refreshToken != null) {
      await _repository.revoke(refreshToken);
    }
    await _sessionRepository.clear();
    _client.updateAuthToken(null);
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearSession: true,
      errorMessage: message,
    );
  }

  void _registerUnauthorizedHandler() {
    if (_registeredUnauthorizedHandler) return;
    _client.registerUnauthorizedHandler((error) async {
      _logger.w('Unauthorized error: $error');
      await logout(message: '登录状态失效，请重新登录');
    });
    _registeredUnauthorizedHandler = true;
  }
}
