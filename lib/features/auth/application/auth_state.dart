import '../data/user_model.dart';

enum AuthStatus { unknown, unauthenticated, otpSent, authenticated }

class AuthState {
  const AuthState({required this.status, this.user, this.pendingPhone, this.pendingCountryCode});

  final AuthStatus status;
  final UserModel? user;

  /// Set while status == otpSent, so the verify screen knows what to submit.
  final String? pendingPhone;
  final String? pendingCountryCode;

  static const initial = AuthState(status: AuthStatus.unknown);

  AuthState copyWith({AuthStatus? status, UserModel? user, String? pendingPhone, String? pendingCountryCode}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      pendingPhone: pendingPhone ?? this.pendingPhone,
      pendingCountryCode: pendingCountryCode ?? this.pendingCountryCode,
    );
  }
}
