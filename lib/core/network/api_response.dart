class ApiResponse<T> {
  final bool status;
  final int? code;
  final String message;
  final T? data;
  final Map<String, dynamic> raw;

  const ApiResponse({
    required this.status,
    required this.message,
    required this.raw,
    this.code,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? value)? fromData,
  ) {
    return ApiResponse<T>(
      status: json['status'] == true,
      code: _asInt(json['code']),
      message: json['message']?.toString() ?? '',
      data: fromData == null ? json['data'] as T? : fromData(json['data']),
      raw: json,
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
