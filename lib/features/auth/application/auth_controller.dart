import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_providers.dart';
import '../data/auth_repository.dart';
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
      final user = await _repo.me();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> sendOtp({required String phone, required String countryCode}) async {
    await _repo.sendOtp(phone: phone, countryCode: countryCode);
    state = state.copyWith(status: AuthStatus.otpSent, pendingPhone: phone, pendingCountryCode: countryCode);
  }

  Future<void> resendOtp() async {
    final phone = state.pendingPhone;
    final countryCode = state.pendingCountryCode;
    if (phone == null || countryCode == null) return;
    await _repo.resendOtp(phone: phone, countryCode: countryCode);
  }

  Future<void> verifyOtp(String otp) async {
    final phone = state.pendingPhone;
    final countryCode = state.pendingCountryCode;
    if (phone == null || countryCode == null) {
      throw StateError('No phone number pending verification');
    }
    final result = await _repo.verifyOtp(phone: phone, countryCode: countryCode, otp: otp);
    state = state.copyWith(status: AuthStatus.authenticated, user: result.user);
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
