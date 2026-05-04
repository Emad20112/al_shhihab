import 'auth_session.dart';
import 'auth_user.dart';

class AuthState {
  final AuthSession? session;

  const AuthState({this.session});

  factory AuthState.guest() => const AuthState();

  bool get isAuthenticated => session?.token.isNotEmpty == true;
  String? get token => session?.token;
  AuthUser? get user => session?.user;

  AuthState copyWith({AuthSession? session, bool clearSession = false}) {
    return AuthState(session: clearSession ? null : session ?? this.session);
  }
}
