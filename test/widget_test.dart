import 'package:flutter_test/flutter_test.dart';

import 'package:al_shihab/features/auth/models/auth_session.dart';
import 'package:al_shihab/features/auth/models/auth_user.dart';

void main() {
  test('auth session extracts common token and user payloads', () {
    final payload = <String, dynamic>{
      'status': true,
      'data': {
        'access_token': 'secure-token',
        'user': {'id': 7, 'name': 'Test User', 'phone': '777000000'},
      },
    };

    final session = AuthSession.fromJson(payload);

    expect(session.token, 'secure-token');
    expect(session.user, isA<AuthUser>());
    expect(session.user?.name, 'Test User');
    expect(session.user?.phone, '777000000');
  });
}
