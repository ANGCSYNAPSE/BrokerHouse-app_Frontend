import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../data/auth_providers.dart';
import '../data/auth_repository.dart';
import '../data/user_model.dart';
import 'auth_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repo = ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    _restoreSession();
    return AuthState.initial;
  }

  Future<void> _restoreSession() async {
    final hasSession = await _repo.hasStoredSession();
    if (!hasSession) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final result = await _repo.me();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
        profileComplete: result.profileComplete,
        subscriptionActive: result.subscriptionActive,
      );
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> sendOtp({required String phone, required String countryCode}) async {
    // Still hits the real backend when it's reachable (so a real OTP is
    // genuinely sent/logged) — only swallows the error in mock mode so the
    // screen flow keeps working during pure UI review with no backend up.
    try {
      await _repo.sendOtp(phone: phone, countryCode: countryCode);
    } catch (_) {
      if (!Env.useMockAuth) rethrow;
    }
    state = state.copyWith(status: AuthStatus.otpSent, pendingPhone: phone, pendingCountryCode: countryCode);
  }

  Future<void> resendOtp() async {
    final phone = state.pendingPhone;
    final countryCode = state.pendingCountryCode;
    if (phone == null || countryCode == null) return;
    try {
      await _repo.resendOtp(phone: phone, countryCode: countryCode);
    } catch (_) {
      if (!Env.useMockAuth) rethrow;
    }
  }

  Future<void> verifyOtp(String otp) async {
    final phone = state.pendingPhone;
    final countryCode = state.pendingCountryCode;
    if (phone == null || countryCode == null) {
      throw StateError('No phone number pending verification');
    }

    // TEMPORARY (see Env.useMockAuth doc comment): "1234" always succeeds
    // without a real backend round-trip, so screens are reviewable without
    // digging a real OTP out of server logs. Stripped from release builds.
    if (Env.useMockAuth && otp == Env.mockOtp) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: UserModel(id: 'mock-user', phone: phone, countryCode: countryCode, email: null, role: 'BROKER', isVerified: true),
        profileComplete: false,
        subscriptionActive: true,
      );
      return;
    }

    final result = await _repo.verifyOtp(phone: phone, countryCode: countryCode, otp: otp);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: result.user,
      profileComplete: result.profileComplete,
      subscriptionActive: result.subscriptionActive,
    );
  }

  /// Called after `/api/users/profile` succeeds, so the router immediately
  /// moves on from profile-setup without waiting for another `/auth/me` call.
  void markProfileComplete() {
    state = state.copyWith(profileComplete: true);
  }

  void backToPhoneEntry() {
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Wired to [ApiClient.onSessionExpired] so a failed token refresh
  /// anywhere in the app forces the user back to the login screen.
  void forceSignOut() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
