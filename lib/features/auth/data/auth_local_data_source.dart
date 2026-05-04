import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_session.dart';

class AuthLocalDataSource {
  static const String _sessionKey = 'auth_session';
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<AuthSession?> readSession() async {
    final sessionJson = await _storage.read(key: _sessionKey);
    if (sessionJson == null || sessionJson.isEmpty) {
      return null;
    }

    try {
      return AuthSession.fromJson(
        Map<String, dynamic>.from(jsonDecode(sessionJson) as Map),
      );
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  Future<String?> readToken() async {
    return (await readSession())?.token;
  }

  Future<String?> readRefreshToken() async {
    return (await readSession())?.refreshToken;
  }

  Future<void> saveSession(AuthSession session) async {
    await _storage.write(key: _sessionKey, value: jsonEncode(session.toJson()));
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
  }
}
