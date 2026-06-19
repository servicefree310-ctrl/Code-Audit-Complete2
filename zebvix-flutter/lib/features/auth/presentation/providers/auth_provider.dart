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

  // Backend returns { user, token } — "token" is the 14-day session token
  // used as a Bearer token in Authorization header for mobile clients.
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      final response = await dio.post(AppConstants.loginPath, data: {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;

      // Backend returns 202 + challenge when MFA is required
      if (response.statusCode == 202 && data['challenge'] != null) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      // Direct login — backend returns { user, token }
      final token = data['token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;

      if (token != null) {
        final storage = _ref.read(secureStorageProvider);
        await storage.saveTokens(accessToken: token, refreshToken: '');
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

  // Backend returns 201 + { user, token } (if no OTP policy)
  // or 202 + { challenge } (if OTP required)
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
      final response = await dio.post(AppConstants.registerPath, data: {
        'email': email,
        'password': password,
        'name': name,
        if (referralCode != null && referralCode.isNotEmpty) 'referralCode': referralCode,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });

      final data = response.data as Map<String, dynamic>;

      // If OTP policy is on, server returns 202 + challenge — registration
      // succeeded but needs OTP verification before session is created
      if (response.statusCode == 202 && data['challenge'] != null) {
        state = state.copyWith(isLoading: false);
        return true;
      }

      // Direct session — backend returns { user, token }
      final token = data['token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;
      if (token != null) {
        final storage = _ref.read(secureStorageProvider);
        await storage.saveTokens(accessToken: token, refreshToken: '');
        if (user != null) await storage.saveUserData(user);
        state = state.copyWith(isLoading: false, isLoggedIn: true, user: user);
      } else {
        state = state.copyWith(isLoading: false);
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Registration failed. Please try again.');
      return false;
    }
  }

  // Complete MFA challenge after login/register — sends verified OTP IDs
  Future<bool> verifyLoginChallenge({
    required String challengeToken,
    int? emailOtpId,
    int? phoneOtpId,
    int? twoFaOtpId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      final response = await dio.post(AppConstants.loginVerifyPath, data: {
        'challengeToken': challengeToken,
        if (emailOtpId != null) 'emailOtpId': emailOtpId,
        if (phoneOtpId != null) 'phoneOtpId': phoneOtpId,
        if (twoFaOtpId != null) 'twoFaOtpId': twoFaOtpId,
      });
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;
      if (token != null) {
        final storage = _ref.read(secureStorageProvider);
        await storage.saveTokens(accessToken: token, refreshToken: '');
        if (user != null) await storage.saveUserData(user);
        state = state.copyWith(isLoading: false, isLoggedIn: true, user: user);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Verification failed.');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Invalid OTP. Please try again.');
      return false;
    }
  }

  Future<bool> verifyOtp({required String email, required String otp, required String type}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      await dio.post(AppConstants.otpVerifyPath, data: {
        'email': email,
        'code': otp,
        'purpose': type,
      });
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Invalid OTP. Please try again.');
      return false;
    }
  }

  // Resend OTP — called when user taps "Resend Code" on OTP screen
  Future<bool> resendOtp({required String email, required String type}) async {
    try {
      final dio = _ref.read(dioProvider);
      await dio.post(AppConstants.otpSendPath, data: {
        'channel': 'email',
        'purpose': type,
        'recipient': email,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // Forgot password — sends OTP to email for password reset flow
  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      await dio.post(AppConstants.otpSendPath, data: {
        'channel': 'email',
        'purpose': 'password_reset',
        'recipient': email,
      });
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to send reset email.');
      return false;
    }
  }

  Future<bool> resetPassword({required String token, required String password}) async {
    // Backend does not expose a standalone reset-password endpoint in the
    // current version. Password change is done via /security/me while logged in.
    // This is a placeholder for future implementation.
    state = state.copyWith(
      isLoading: false,
      error: 'Password reset via email link is not supported yet. Please contact support.',
    );
    return false;
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
