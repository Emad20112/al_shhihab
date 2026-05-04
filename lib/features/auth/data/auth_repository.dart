import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';
import 'auth_local_data_source.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required AuthLocalDataSource localDataSource,
  }) : _apiClient = apiClient,
       _localDataSource = localDataSource;

  final ApiClient _apiClient;
  final AuthLocalDataSource _localDataSource;
  Future<bool>? _refreshInFlight;

  Future<AuthSession?> restoreSession() {
    return _localDataSource.readSession();
  }

  Future<AuthSession?> register(Map<String, dynamic> data) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      body: data,
      fromData: _mapFromData,
      authenticated: false,
    );

    return _saveSessionIfPresent(response);
  }

  Future<AuthSession> login(Map<String, dynamic> credentials) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      body: credentials,
      fromData: _mapFromData,
      authenticated: false,
    );

    final session = AuthSession.fromJson(_sessionPayload(response));
    await _localDataSource.saveSession(session);
    return session;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post<Map<String, dynamic>>(
        '/auth/logout',
        body: const <String, dynamic>{},
        fromData: _mapFromData,
      );
    } finally {
      await _localDataSource.clearSession();
    }
  }

  Future<bool> refreshSession() async {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    _refreshInFlight = _refreshSessionOnce();
    try {
      return await _refreshInFlight!;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<bool> _refreshSessionOnce() async {
    final refreshToken = await _localDataSource.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _localDataSource.clearSession();
      return false;
    }

    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        body: {'refresh_token': refreshToken},
        fromData: _mapFromData,
        authenticated: false,
      );
      final session = AuthSession.fromJson(_sessionPayload(response));
      await _localDataSource.saveSession(session);
      return true;
    } catch (_) {
      await _localDataSource.clearSession();
      return false;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> sendVerification(
    Map<String, dynamic> data,
  ) {
    return _apiClient.post<Map<String, dynamic>>(
      '/auth/verify/send',
      body: data,
      fromData: _mapFromData,
      authenticated: false,
    );
  }

  Future<AuthSession?> checkVerification(Map<String, dynamic> data) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/verify/check',
      body: data,
      fromData: _mapFromData,
      authenticated: false,
    );

    return _saveSessionIfPresent(response);
  }

  Future<AuthUser?> fetchMe() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/me',
      fromData: _mapFromData,
    );
    return AuthSession.tryExtractUser(_sessionPayload(response)) ??
        AuthUser.fromJson(response.data ?? response.raw);
  }

  Future<AuthUser?> updateMe(Map<String, dynamic> data) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/me',
      body: data,
      fromData: _mapFromData,
    );
    return AuthSession.tryExtractUser(_sessionPayload(response)) ??
        AuthUser.fromJson(response.data ?? response.raw);
  }

  Future<AuthUser?> fetchProfile() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/user/profile',
      fromData: _mapFromData,
    );
    return AuthSession.tryExtractUser(_sessionPayload(response)) ??
        AuthUser.fromJson(response.data ?? response.raw);
  }

  Future<ApiResponse<Map<String, dynamic>>> fetchPreferences() {
    return _apiClient.get<Map<String, dynamic>>(
      '/me/preferences',
      fromData: _mapFromData,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updatePreferences(
    Map<String, dynamic> preferences,
  ) {
    return _apiClient.put<Map<String, dynamic>>(
      '/me/preferences',
      body: preferences,
      fromData: _mapFromData,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> changeAvatarBytes({
    required Uint8List bytes,
    required String filename,
    String fieldName = 'avatar',
    String? contentType,
  }) {
    return _apiClient.uploadBytes<Map<String, dynamic>>(
      '/me/avatar',
      fieldName: fieldName,
      bytes: bytes,
      filename: filename,
      contentType: contentType,
      fromData: _mapFromData,
    );
  }

  Future<void> deleteAvatar() async {
    await _apiClient.delete<Map<String, dynamic>>(
      '/me/avatar',
      body: const <String, dynamic>{},
      fromData: _mapFromData,
    );
  }

  Future<void> clearLocalSession() => _localDataSource.clearSession();

  Future<AuthSession?> _saveSessionIfPresent(
    ApiResponse<Map<String, dynamic>> response,
  ) async {
    final payload = _sessionPayload(response);
    final token = AuthSession.tryExtractToken(payload);
    if (token == null || token.isEmpty) return null;

    final session = AuthSession.fromJson(payload);
    await _localDataSource.saveSession(session);
    return session;
  }

  Map<String, dynamic> _sessionPayload(
    ApiResponse<Map<String, dynamic>> response,
  ) {
    final data = response.data;
    if (data == null || data.isEmpty) {
      return response.raw;
    }

    return <String, dynamic>{...response.raw, 'data': data, ...data};
  }
}

Map<String, dynamic> _mapFromData(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}
