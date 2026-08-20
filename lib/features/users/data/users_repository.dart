import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'profile_model.dart';

/// Talks to `/api/users/*` — mirrors the backend's users.routes.ts 1:1.
class UsersRepository {
  UsersRepository(this._client);

  final ApiClient _client;

  /// `POST /api/users/profile` — step 1 of onboarding. `role` is only
  /// honoured by the backend on this call (never on later updates), and
  /// must never be `ADMIN` (rejected server-side regardless).
  Future<ProfileModel> completeProfile({
    required String fullName,
    String? email,
    String? reraNumber,
    String? companyName,
    String? specialization,
    String? role,
  }) async {
    final data = await _client.unwrap<Map<String, dynamic>>(
      () => _client.dio.post(
        '/users/profile',
        data: {
          'fullName': fullName,
          if (email != null && email.isNotEmpty) 'email': email,
          if (reraNumber != null && reraNumber.isNotEmpty) 'reraNumber': reraNumber,
          if (companyName != null && companyName.isNotEmpty) 'companyName': companyName,
          'specialization': ?specialization,
          'role': ?role,
        },
      ),
    );
    return ProfileModel.fromJson(data['profile'] as Map<String, dynamic>);
  }

  /// `POST /api/users/profile/photo` — requires a profile row to already
  /// exist (call [completeProfile] first on initial setup).
  Future<ProfileModel> uploadProfilePhoto(File photo) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(photo.path, filename: photo.path.split(Platform.pathSeparator).last),
    });
    final data = await _client.unwrap<Map<String, dynamic>>(
      () => _client.dio.post('/users/profile/photo', data: formData),
    );
    return ProfileModel.fromJson(data['profile'] as Map<String, dynamic>);
  }
}
