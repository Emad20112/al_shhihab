import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'api_config.dart';
import 'api_exception.dart';
import 'api_response.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
    FutureOr<String?> Function()? tokenProvider,
    this.acceptLanguage = 'ar',
  }) : _httpClient = httpClient ?? http.Client(),
       _baseUrl = Uri.parse(baseUrl ?? ApiConfig.baseUrl),
       _tokenProvider = tokenProvider;

  final http.Client _httpClient;
  final Uri _baseUrl;
  final FutureOr<String?> Function()? _tokenProvider;
  final String acceptLanguage;
  FutureOr<bool> Function()? refreshSession;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Object? value)? fromData,
    bool authenticated = true,
  }) {
    return _send<T>(
      'GET',
      path,
      queryParameters: queryParameters,
      fromData: fromData,
      authenticated: authenticated,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    T Function(Object? value)? fromData,
    bool authenticated = true,
  }) {
    return _send<T>(
      'POST',
      path,
      body: body,
      queryParameters: queryParameters,
      fromData: fromData,
      authenticated: authenticated,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    T Function(Object? value)? fromData,
    bool authenticated = true,
  }) {
    return _send<T>(
      'PUT',
      path,
      body: body,
      queryParameters: queryParameters,
      fromData: fromData,
      authenticated: authenticated,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    T Function(Object? value)? fromData,
    bool authenticated = true,
  }) {
    return _send<T>(
      'DELETE',
      path,
      body: body,
      queryParameters: queryParameters,
      fromData: fromData,
      authenticated: authenticated,
    );
  }

  Future<ApiResponse<T>> uploadBytes<T>(
    String path, {
    required String fieldName,
    required Uint8List bytes,
    required String filename,
    String? contentType,
    Map<String, String>? fields,
    T Function(Object? value)? fromData,
    bool authenticated = true,
    bool retryingAfterRefresh = false,
  }) async {
    final uri = _buildUri(path);
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(
      await _headers(authenticated: authenticated, includeContentType: false),
    );
    if (fields != null) request.fields.addAll(fields);

    final multipartFile = http.MultipartFile.fromBytes(
      fieldName,
      bytes,
      filename: filename,
      contentType: contentType == null ? null : _mediaType(contentType),
    );
    request.files.add(multipartFile);

    final streamed = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 401 &&
        authenticated &&
        !retryingAfterRefresh &&
        refreshSession != null) {
      final refreshed = await refreshSession!.call();
      if (refreshed) {
        return uploadBytes<T>(
          path,
          fieldName: fieldName,
          bytes: bytes,
          filename: filename,
          contentType: contentType,
          fields: fields,
          fromData: fromData,
          authenticated: authenticated,
          retryingAfterRefresh: true,
        );
      }
    }

    return _parseResponse<T>(response, uri, fromData);
  }

  Future<ApiResponse<T>> _send<T>(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    T Function(Object? value)? fromData,
    bool authenticated = true,
    bool retryingAfterRefresh = false,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = await _headers(authenticated: authenticated);
    final encodedBody = body == null ? null : jsonEncode(_wrapBody(body));

    final request = http.Request(method, uri)
      ..headers.addAll(headers)
      ..body = encodedBody ?? '';

    final streamed = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 401 &&
        authenticated &&
        !retryingAfterRefresh &&
        refreshSession != null) {
      final refreshed = await refreshSession!.call();
      if (refreshed) {
        return _send<T>(
          method,
          path,
          body: body,
          queryParameters: queryParameters,
          fromData: fromData,
          authenticated: authenticated,
          retryingAfterRefresh: true,
        );
      }
    }

    return _parseResponse<T>(response, uri, fromData);
  }

  Future<Map<String, String>> _headers({
    required bool authenticated,
    bool includeContentType = true,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Accept-Language': acceptLanguage,
      'X-Channel-Id': ApiConfig.channelId,
    };

    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }
    if (ApiConfig.appKey.isNotEmpty) {
      headers['X-API-APP-KEY'] = ApiConfig.appKey;
    }
    if (ApiConfig.appSecret.isNotEmpty) {
      headers['X-API-APP-SECRET'] = ApiConfig.appSecret;
    }
    if (authenticated) {
      final token = await _tokenProvider?.call();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final basePath = _baseUrl.path.endsWith('/')
        ? _baseUrl.path
        : '${_baseUrl.path}/';

    return _baseUrl.replace(
      path: '$basePath$normalizedPath',
      queryParameters: _cleanQuery(queryParameters),
    );
  }

  Map<String, String>? _cleanQuery(Map<String, dynamic>? queryParameters) {
    if (queryParameters == null || queryParameters.isEmpty) return null;

    return queryParameters.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );
  }

  Object _wrapBody(Object body) {
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body;
    }
    return {'data': body};
  }

  ApiResponse<T> _parseResponse<T>(
    http.Response response,
    Uri uri,
    T Function(Object? value)? fromData,
  ) {
    final body = response.body.trim();
    final decoded = body.isEmpty ? <String, dynamic>{} : _decodeJson(body, uri);

    final payload = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{
            'status': response.statusCode < 400,
            'data': decoded,
          };

    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    if (!isSuccess) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _messageFrom(payload, response.reasonPhrase),
        errors: payload['errors'] ?? payload['error'],
        uri: uri,
      );
    }

    return ApiResponse.fromJson(payload, fromData);
  }

  Object? _decodeJson(String body, Uri uri) {
    try {
      return jsonDecode(body);
    } on FormatException catch (error) {
      throw ApiException(
        message: 'استجابة الخادم ليست JSON صالحة',
        errors: error.message,
        uri: uri,
      );
    }
  }

  String _messageFrom(Map<String, dynamic> payload, String? fallback) {
    return payload['message']?.toString() ??
        payload['error']?.toString() ??
        fallback ??
        'حدث خطأ غير متوقع';
  }

  void close() => _httpClient.close();
}

MediaType? _mediaType(String value) {
  final parts = value.split('/');
  if (parts.length != 2) return null;
  return MediaType(parts[0], parts[1]);
}
