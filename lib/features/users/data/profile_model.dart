/// Mirrors the `profile` object returned by `/api/users/profile` (POST/PUT)
/// and `/api/users/profile/photo`.
class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.userId,
    required this.fullName,
    this.email,
    this.companyName,
    this.specialization,
    this.profilePhotoUrl,
    this.reraNumber,
  });

  final String id;
  final String userId;
  final String fullName;
  final String? email;
  final String? companyName;
  final String? specialization;
  final String? profilePhotoUrl;
  final String? reraNumber;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String?,
      companyName: json['companyName'] as String?,
      specialization: json['specialization'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      reraNumber: json['reraNumber'] as String?,
    );
  }
}
