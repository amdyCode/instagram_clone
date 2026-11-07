import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/api/api_providers.dart';
import '../../core/models/user.dart';
import 'auth_repository.dart';

class AuthState {
  const AuthState({this.user, this.isLoading = false, this.error});

  final User? user;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final token = await ref.read(authTokenStorageProvider).readToken();
      if (token == null || token.isEmpty) {
        state = state.copyWith(clearUser: true, isLoading: false);
        return;
      }

      final user = await _repository.getMe();
      state = state.copyWith(
        user: user,
        clearUser: user == null,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(clearUser: true, isLoading: false);
    }
  }

  Future<bool> login({
    required String emailOrUsername,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final payload = await _repository.login(
        emailOrUsername: emailOrUsername,
        password: password,
      );
      state = state.copyWith(
        user: payload.user,
        isLoading: false,
        clearError: true,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur inattendue lors de la connexion',
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String username,
    required String password,
    String? fullName,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final payload = await _repository.register(
        email: email,
        username: username,
        password: password,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );
      state = state.copyWith(
        user: payload.user,
        isLoading: false,
        clearError: true,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur inattendue lors de l\'inscription',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
