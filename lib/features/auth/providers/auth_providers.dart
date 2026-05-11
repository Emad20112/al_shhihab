import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/cart_provider.dart';
import '../data/auth_local_data_source.dart';
import '../data/auth_repository.dart';
import '../models/auth_session.dart';
import '../models/auth_state.dart';
import '../models/auth_user.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  final client = ApiClient(tokenProvider: localDataSource.readToken);
  ref.onDispose(client.close);
  return client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final repository = AuthRepository(
    apiClient: apiClient,
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
  apiClient.refreshSession = repository.refreshSession;
  return repository;
});

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  () {
    return AuthController();
  },
);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref
      .watch(authControllerProvider)
      .maybeWhen(data: (state) => state.isAuthenticated, orElse: () => false);
});

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref
      .watch(authControllerProvider)
      .maybeWhen(data: (state) => state.user, orElse: () => null);
});

class AuthController extends AsyncNotifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<AuthState> build() async {
    final session = await _repository.restoreSession();
    return AuthState(session: session);
  }

  Future<AuthSession?> register(Map<String, dynamic> data) async {
    final previous = state.value ?? AuthState.guest();
    state = const AsyncLoading<AuthState>();

    try {
      final session = await _repository.register(data);
      final next = session == null ? previous : AuthState(session: session);
      state = AsyncData(next);
      return session;
    } catch (error, stackTrace) {
      state = AsyncError<AuthState>(error, stackTrace);
      rethrow;
    }
  }

  Future<AuthSession> login(Map<String, dynamic> credentials) async {
    state = const AsyncLoading<AuthState>();

    try {
      final session = await _repository.login(credentials);
      state = AsyncData(AuthState(session: session));
      return session;
    } catch (error, stackTrace) {
      state = AsyncError<AuthState>(error, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading<AuthState>();

    try {
      await _repository.logout();
    } finally {
      // Clear cart on logout - cart items are user-specific
      ref.read(cartProvider.notifier).clearCart();
      state = AsyncData(AuthState.guest());
    }
  }

  Future<AuthSession?> checkVerification(Map<String, dynamic> data) async {
    final previous = state.value ?? AuthState.guest();
    state = const AsyncLoading<AuthState>();

    try {
      final session = await _repository.checkVerification(data);
      final next = session == null ? previous : AuthState(session: session);
      state = AsyncData(next);
      return session;
    } catch (error, stackTrace) {
      state = AsyncError<AuthState>(error, stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendVerification(
    Map<String, dynamic> data,
  ) async {
    final response = await _repository.sendVerification(data);
    return response.data ?? response.raw;
  }

  Future<void> resetPassword(Map<String, dynamic> data) {
    return _repository.resetPassword(data);
  }

  Future<AuthUser?> refreshMe() async {
    final current = state.value ?? AuthState.guest();
    final user = await _repository.fetchMe();
    final session = current.session;

    if (session != null && user != null) {
      state = AsyncData(
        current.copyWith(session: session.copyWith(user: user)),
      );
    }

    return user;
  }

  Future<AuthUser?> updateMe(Map<String, dynamic> data) async {
    final current = state.value ?? AuthState.guest();
    final user = await _repository.updateMe(data);
    final session = current.session;

    if (session != null && user != null) {
      state = AsyncData(
        current.copyWith(session: session.copyWith(user: user)),
      );
    }

    return user;
  }

  Future<AuthUser?> fetchProfile() {
    return _repository.fetchProfile();
  }

  Future<Map<String, dynamic>> fetchPreferences() async {
    final response = await _repository.fetchPreferences();
    return response.data ?? response.raw;
  }

  Future<Map<String, dynamic>> updatePreferences(
    Map<String, dynamic> preferences,
  ) async {
    final response = await _repository.updatePreferences(preferences);
    return response.data ?? response.raw;
  }

  Future<void> changeAvatarBytes({
    required Uint8List bytes,
    required String filename,
    String fieldName = 'avatar',
    String? contentType,
  }) async {
    await _repository.changeAvatarBytes(
      bytes: bytes,
      filename: filename,
      fieldName: fieldName,
      contentType: contentType,
    );
    await refreshMe();
  }

  Future<void> deleteAvatar() async {
    await _repository.deleteAvatar();
    await refreshMe();
  }

  Future<void> clearLocalSession() async {
    await _repository.clearLocalSession();
    state = AsyncData(AuthState.guest());
  }
}
