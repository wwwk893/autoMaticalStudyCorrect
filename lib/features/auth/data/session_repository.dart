import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/session.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.read);
});

class SessionRepository {
  SessionRepository(this._read);

  final Reader _read;
  FlutterSecureStorage get _secureStorage => _read(secureStorageProvider);

  static const _key = 'app_session';

  Future<void> persist(UserSession session) async {
    await _secureStorage.write(
      key: _key,
      value: jsonEncode(session.toJson()),
    );
  }

  Future<UserSession?> restore() async {
    final raw = await _secureStorage.read(key: _key);
    if (raw == null) {
      return null;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserSession.fromJson(json);
    } catch (_) {
      await _secureStorage.delete(key: _key);
      return null;
    }
  }

  Future<void> clear() async {
    await _secureStorage.delete(key: _key);
  }
}

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
});
