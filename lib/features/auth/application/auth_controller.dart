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
    state = state.copyWith(
      status: AuthStatus.otpSent,
      pendingPhone: phone,
      pendingCountryCode: countryCode,
      pendingOtpMethod: PendingOtpMethod.phone,
    );
  }

  /// Registers phone + email, then moves to the same OTP-verify screen as
  /// phone login — the backend's `/auth/signup` attaches the email and sends
  /// the OTP; `/auth/verify-otp` finishes it exactly like a normal phone
  /// login (no separate "verify signup" call, and no password — login is
  /// phone/email OTP-only).
  Future<void> signup({
    required String phone,
    required String countryCode,
    required String email,
  }) async {
    try {
      await _repo.signup(phone: phone, countryCode: countryCode, email: email);
    } catch (_) {
      if (!Env.useMockAuth) rethrow;
    }
    state = state.copyWith(
      status: AuthStatus.otpSent,
      pendingPhone: phone,
      pendingCountryCode: countryCode,
      pendingEmail: email,
      pendingOtpMethod: PendingOtpMethod.phone,
    );
  }

  /// Email login — a separate OTP namespace from phone. The account must
  /// already exist (created via [signup]); the backend 404s otherwise.
  Future<void> sendEmailOtp({required String email}) async {
    try {
      await _repo.sendEmailOtp(email: email);
    } catch (_) {
      if (!Env.useMockAuth) rethrow;
    }
    state = state.copyWith(status: AuthStatus.otpSent, pendingEmail: email, pendingOtpMethod: PendingOtpMethod.email);
  }

  Future<void> resendOtp() async {
    try {
      if (state.pendingOtpMethod == PendingOtpMethod.email) {
        final email = state.pendingEmail;
        if (email == null) return;
        await _repo.sendEmailOtp(email: email);
      } else {
        final phone = state.pendingPhone;
        final countryCode = state.pendingCountryCode;
        if (phone == null || countryCode == null) return;
        await _repo.resendOtp(phone: phone, countryCode: countryCode);
      }
    } catch (_) {
      if (!Env.useMockAuth) rethrow;
    }
  }

  /// Returns whether this was a first-ever verified login for the
  /// phone/email — the OTP screen uses it to show "Successfully
  /// registered!" vs "Welcome back!".
  Future<bool> verifyOtp(String otp) async {
    // TEMPORARY (see Env.useMockAuth doc comment): "1234" always succeeds
    // without a real backend round-trip, so screens are reviewable without
    // digging a real OTP out of server logs. Stripped from release builds.
    // There's no real backend response to read isNewUser from here, so it
    // always reports true — good enough for a dev-only UI shortcut.
    if (Env.useMockAuth && otp == Env.mockOtp) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: UserModel(
          id: 'mock-user',
          phone: state.pendingPhone,
          countryCode: state.pendingCountryCode,
          email: state.pendingEmail,
          role: 'BROKER',
          isVerified: true,
        ),
        profileComplete: false,
        subscriptionActive: true,
      );
      return true;
    }

    if (state.pendingOtpMethod == PendingOtpMethod.email) {
      final email = state.pendingEmail;
      if (email == null) throw StateError('No email pending verification');
      final result = await _repo.verifyEmailOtp(email: email, otp: otp);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
        profileComplete: result.profileComplete,
        subscriptionActive: result.subscriptionActive,
      );
      return result.isNewUser;
    }

    final phone = state.pendingPhone;
    final countryCode = state.pendingCountryCode;
    if (phone == null || countryCode == null) {
      throw StateError('No phone number pending verification');
    }
    final result = await _repo.verifyOtp(phone: phone, countryCode: countryCode, otp: otp);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: result.user,
      profileComplete: result.profileComplete,
      subscriptionActive: result.subscriptionActive,
    );
    return result.isNewUser;
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
