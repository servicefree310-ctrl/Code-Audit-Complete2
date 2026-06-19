import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/secure_storage.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;
  final Map<String, dynamic>? user;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
    Map<String, dynamic>? user,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState());

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      final response = await dio.post(AppConstants.loginPath, data: {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final user = data['user'] as Map<String, dynamic>?;

      if (accessToken != null) {
        final storage = _ref.read(secureStorageProvider);
        await storage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken ?? '',
        );
        if (user != null) await storage.saveUserData(user);
        state = state.copyWith(isLoading: false, isLoggedIn: true, user: user);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Login failed. Please try again.');
      return false;
    } catch (e) {
      final msg = e.toString().contains('AppException')
          ? e.toString()
          : 'Invalid credentials. Please try again.';
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? referralCode,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      await dio.post(AppConstants.registerPath, data: {
        'email': email,
        'password': password,
        'name': name,
        if (referralCode != null) 'referralCode': referralCode,
        if (phone != null) 'phone': phone,
      });
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Registration failed. Please try again.');
      return false;
    }
  }

  Future<bool> verifyOtp({required String email, required String otp, required String type}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      await dio.post(AppConstants.verifyOtpPath, data: {
        'email': email,
        'otp': otp,
        'type': type,
      });
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Invalid OTP. Please try again.');
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      await dio.post(AppConstants.forgotPasswordPath, data: {'email': email});
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to send reset email.');
      return false;
    }
  }

  Future<bool> resetPassword({required String token, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      await dio.post(AppConstants.resetPasswordPath, data: {
        'token': token,
        'password': password,
      });
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to reset password.');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final dio = _ref.read(dioProvider);
      await dio.post(AppConstants.logoutPath);
    } catch (_) {}
    final storage = _ref.read(secureStorageProvider);
    await storage.clearAll();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
