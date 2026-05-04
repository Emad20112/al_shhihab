import 'auth_user.dart';

class AuthSession {
  final String token;
  final String? refreshToken;
  final AuthUser? user;
  final Map<String, dynamic> raw;

  const AuthSession({
    required this.token,
    required this.raw,
    this.refreshToken,
    this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final token = _extractToken(json);
    if (token == null || token.isEmpty) {
      throw const FormatException('لا تحتوي الاستجابة على توكن صالح');
    }

    return AuthSession(
      token: token,
      refreshToken: _extractRefreshToken(json),
      user: _extractUser(json),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => raw;

  AuthSession copyWith({
    String? token,
    String? refreshToken,
    AuthUser? user,
    Map<String, dynamic>? raw,
  }) {
    return AuthSession(
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      raw: raw ?? this.raw,
    );
  }

  static String? tryExtractToken(Object? value) => _extractToken(value);

  static String? tryExtractRefreshToken(Object? value) {
    return _extractRefreshToken(value);
  }

  static AuthUser? tryExtractUser(Object? value) => _extractUser(value);

  static String? _extractToken(Object? value) {
    const tokenKeys = {
      'token',
      'access_token',
      'accessToken',
      'bearer_token',
      'auth_token',
      'api_token',
      'plainTextToken',
      'jwt',
    };

    if (value is Map) {
      for (final entry in value.entries) {
        if (tokenKeys.contains(entry.key) && entry.value is String) {
          return entry.value as String;
        }
      }

      for (final entry in value.entries) {
        final nested = _extractToken(entry.value);
        if (nested != null && nested.isNotEmpty) return nested;
      }
    } else if (value is List) {
      for (final item in value) {
        final nested = _extractToken(item);
        if (nested != null && nested.isNotEmpty) return nested;
      }
    }

    return null;
  }

  static String? _extractRefreshToken(Object? value) {
    const tokenKeys = {
      'refresh_token',
      'refreshToken',
      'refresh',
    };

    if (value is Map) {
      for (final entry in value.entries) {
        if (tokenKeys.contains(entry.key) && entry.value is String) {
          return entry.value as String;
        }
      }

      for (final entry in value.entries) {
        final nested = _extractRefreshToken(entry.value);
        if (nested != null && nested.isNotEmpty) return nested;
      }
    } else if (value is List) {
      for (final item in value) {
        final nested = _extractRefreshToken(item);
        if (nested != null && nested.isNotEmpty) return nested;
      }
    }

    return null;
  }

  static AuthUser? _extractUser(Object? value) {
    if (value is! Map) return null;

    const userKeys = {'user', 'customer', 'account', 'profile', 'me'};
    for (final key in userKeys) {
      final nested = value[key];
      if (nested is Map<String, dynamic>) {
        return AuthUser.fromJson(nested);
      }
      if (nested is Map) {
        return AuthUser.fromJson(Map<String, dynamic>.from(nested));
      }
    }

    final looksLikeUser =
        value.containsKey('email') ||
        value.containsKey('phone') ||
        value.containsKey('mobile') ||
        value.containsKey('name');
    if (looksLikeUser) {
      return AuthUser.fromJson(Map<String, dynamic>.from(value));
    }

    for (final nested in value.values) {
      final user = _extractUser(nested);
      if (user != null) return user;
    }

    return null;
  }
}
