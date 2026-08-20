import '../data/user_model.dart';

enum AuthStatus { unknown, unauthenticated, otpSent, authenticated }

/// Which OTP namespace the pending verification belongs to — phone and
/// email each have their own OTP records server-side (see auth.service.ts).
enum PendingOtpMethod { phone, email }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.pendingPhone,
    this.pendingCountryCode,
    this.pendingEmail,
    this.pendingOtpMethod,
    this.profileComplete = false,
    this.subscriptionActive = true,
  });

  final AuthStatus status;
  final UserModel? user;

  /// Set while status == otpSent, so the verify screen knows what to submit.
  final String? pendingPhone;
  final String? pendingCountryCode;
  final String? pendingEmail;
  final PendingOtpMethod? pendingOtpMethod;

  /// Only meaningful while status == authenticated — drives whether the
  /// router sends the user to profile setup / subscription paywall / home.
  final bool profileComplete;
  final bool subscriptionActive;

  static const initial = AuthState(status: AuthStatus.unknown);

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? pendingPhone,
    String? pendingCountryCode,
    String? pendingEmail,
    PendingOtpMethod? pendingOtpMethod,
    bool? profileComplete,
    bool? subscriptionActive,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      pendingPhone: pendingPhone ?? this.pendingPhone,
      pendingCountryCode: pendingCountryCode ?? this.pendingCountryCode,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      pendingOtpMethod: pendingOtpMethod ?? this.pendingOtpMethod,
      profileComplete: profileComplete ?? this.profileComplete,
      subscriptionActive: subscriptionActive ?? this.subscriptionActive,
    );
  }
}
