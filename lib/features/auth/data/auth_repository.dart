import '../../../core/network/api_client.dart';
import '../../../core/network/token_storage.dart';
import 'user_model.dart';

class VerifyOtpResult {
  const VerifyOtpResult({
    required this.user,
    required this.isNewUser,
    required this.profileComplete,
    required this.subscriptionActive,
  });

  final UserModel user;
  final bool isNewUser;

  /// Drives post-login routing: false → profile setup, else → home
  /// (subscription-gated roles also check [subscriptionActive]).
  final bool profileComplete;
  final bool subscriptionActive;
}

class MeResult {
  const MeResult({required this.user, required this.profileComplete, required this.subscriptionActive});
  final UserModel user;
  final bool profileComplete;
  final bool subscriptionActive;
}

/// Talks to `/api/auth/*` — mirrors the backend's auth.routes.ts 1:1.
class AuthRepository {
  AuthRepository(this._client, this._tokenStorage);

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  Future<void> sendOtp({required String phone, required String countryCode}) {
    return _client.unwrapMessage(
      () => _client.dio.post('/auth/send-otp', data: {'phone': phone, 'countryCode': countryCode}),
    );
  }

  Future<void> resendOtp({required String phone, required String countryCode}) {
    return _client.unwrapMessage(
      () => _client.dio.post('/auth/resend-otp', data: {'phone': phone, 'countryCode': countryCode}),
    );
  }

  Future<VerifyOtpResult> verifyOtp({required String phone, required String countryCode, required String otp}) async {
    final data = await _client.unwrap<Map<String, dynamic>>(
      () => _client.dio.post('/auth/verify-otp', data: {'phone': phone, 'countryCode': countryCode, 'otp': otp}),
    );
    await _tokenStorage.saveTokens(accessToken: data['accessToken'] as String, refreshToken: data['refreshToken'] as String);
    return VerifyOtpResult(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      isNewUser: data['isNewUser'] as bool? ?? false,
      profileComplete: data['profileComplete'] as bool? ?? false,
      subscriptionActive: data['subscriptionActive'] as bool? ?? true,
    );
  }

  Future<VerifyOtpResult> socialLogin({required String provider, required String token}) async {
    final data = await _client.unwrap<Map<String, dynamic>>(
      () => _client.dio.post('/auth/social-login', data: {'provider': provider, 'token': token}),
    );
    await _tokenStorage.saveTokens(accessToken: data['accessToken'] as String, refreshToken: data['refreshToken'] as String);
    return VerifyOtpResult(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      isNewUser: data['isNewUser'] as bool? ?? false,
      profileComplete: data['profileComplete'] as bool? ?? false,
      subscriptionActive: data['subscriptionActive'] as bool? ?? true,
    );
  }

  Future<MeResult> me() async {
    final data = await _client.unwrap<Map<String, dynamic>>(() => _client.dio.get('/auth/me'));
    return MeResult(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      profileComplete: data['profileComplete'] as bool? ?? false,
      subscriptionActive: data['subscriptionActive'] as bool? ?? true,
    );
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    try {
      await _client.unwrapMessage(() => _client.dio.post('/auth/logout', data: {'refreshToken': refreshToken}));
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<bool> hasStoredSession() async {
    final token = await _tokenStorage.readAccessToken();
    return token != null;
  }
}
