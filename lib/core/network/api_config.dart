import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String defaultBaseUrl = 'https://demodelivery.now-ye.com/api/v1';

  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    // Use environment variable if provided and not empty
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    // Fallback to local backend in development
    if (kDebugMode) return 'http://10.0.2.2:3000/api/v1';
    // Production default
    return defaultBaseUrl;
  }

  static const String _envAppKey = String.fromEnvironment('API_APP_KEY');
  static const String _envAppSecret = String.fromEnvironment('API_APP_SECRET');

  static String get appKey {
    if (_envAppKey.isNotEmpty) return _envAppKey;
    if (kDebugMode) return 'local-app-key';
    return '';
  }

  static String get appSecret {
    if (_envAppSecret.isNotEmpty) return _envAppSecret;
    if (kDebugMode) return 'local-app-secret';
    return '';
  }

  static String get channelId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'frontend';
    }
  }
}
