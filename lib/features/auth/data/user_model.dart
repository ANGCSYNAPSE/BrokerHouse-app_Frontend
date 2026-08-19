/// Mirrors the `user` object returned by `/api/auth/verify-otp`, `/social-login`, and `/me`.
class UserModel {
  const UserModel({
    required this.id,
    required this.phone,
    required this.countryCode,
    required this.email,
    required this.role,
    required this.isVerified,
  });

  final String id;
  final String? phone;
  final String? countryCode;
  final String? email;
  final String role;
  final bool isVerified;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String?,
      countryCode: json['countryCode'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}
