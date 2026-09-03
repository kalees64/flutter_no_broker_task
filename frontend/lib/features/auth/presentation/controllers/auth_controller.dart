import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final String? errorCode;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.errorCode,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null,
        errorCode = null;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    String? errorCode,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthNotifier(repository: repo, storage: storage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  final SecureStorageService storage;

  AuthNotifier({
    required this.repository,
    required this.storage,
  }) : super(const AuthState.initial());

  Future<void> checkAuthStatus() async {
    final token = await storage.getAccessToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      // First check local cached user for instant launch
      final cachedUser = await storage.getUser();
      if (cachedUser != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: UserModel.fromJson(cachedUser),
        );
      }

      // Verify and sync live profile from backend
      final freshProfile = await repository.getProfile();
      await storage.saveUser(freshProfile.toJson());
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: freshProfile,
      );
    } catch (_) {
      // Token is invalid/expired and couldn't be refreshed
      await storage.clearTokens();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login({
    required String identifier,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await repository.login(
        identifier: identifier,
        password: password,
      );

      await storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await storage.saveUser(response.user.toJson());

      if (rememberMe) {
        await storage.saveRememberMeEmail(identifier);
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
      );
      return true;
    } on AppNetworkException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
        errorCode: e.code,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Login failed. Please check your credentials.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? role,
    String? flatNumber,
    String? societyName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      await repository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
        flatNumber: flatNumber,
        societyName: societyName,
      );

      // Auto-login after successful registration
      return await login(identifier: email, password: password);
    } on AppNetworkException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
        errorCode: e.code,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Registration failed. Please try again.',
      );
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> payload) async {
    if (state.user == null) return false;
    try {
      final updatedUser = await repository.updateProfile(state.user!.id, payload);
      await storage.saveUser(updatedUser.toJson());
      state = state.copyWith(user: updatedUser);
      return true;
    } on AppNetworkException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update profile');
      return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = await storage.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await repository.logout(refreshToken: refreshToken);
      } catch (_) {}
    }

    await storage.clearTokens();
    await storage.saveRememberMeEmail('');
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null, errorCode: null);
  }
}
