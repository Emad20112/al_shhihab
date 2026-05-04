class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Object? errors;
  final Uri? uri;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
    this.uri,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isValidationError => statusCode == 400 || statusCode == 422;

  @override
  String toString() {
    final code = statusCode == null ? '' : ' ($statusCode)';
    return 'ApiException$code: $message';
  }
}
