class AuthUser {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final Map<String, dynamic> raw;

  const AuthUser({
    required this.raw,
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avatarUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: _stringValue(json, const ['id', 'uuid', 'user_id']),
      name: _stringValue(json, const ['name', 'full_name', 'username']),
      email: _stringValue(json, const ['email', 'email_address']),
      phone: _stringValue(json, const ['phone', 'mobile', 'phone_number']),
      avatarUrl: _stringValue(json, const [
        'avatar',
        'avatar_url',
        'image',
        'image_url',
        'photo',
      ]),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => raw;

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    Map<String, dynamic>? raw,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      raw: raw ?? this.raw,
    );
  }

  static String? _stringValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }
}
