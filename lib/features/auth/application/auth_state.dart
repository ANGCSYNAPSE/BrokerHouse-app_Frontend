import '../data/user_model.dart';

enum AuthStatus { unknown, unauthenticated, otpSent, authenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.pendingPhone,
    this.pendingCountryCode,
    this.profileComplete = false,
    this.subscriptionActive = true,
  });

  final AuthStatus status;
  final UserModel? user;

  /// Set while status == otpSent, so the verify screen knows what to submit.
  final String? pendingPhone;
  final String? pendingCountryCode;

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
    bool? profileComplete,
    bool? subscriptionActive,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      pendingPhone: pendingPhone ?? this.pendingPhone,
      pendingCountryCode: pendingCountryCode ?? this.pendingCountryCode,
      profileComplete: profileComplete ?? this.profileComplete,
      subscriptionActive: subscriptionActive ?? this.subscriptionActive,
    );
  }
}
