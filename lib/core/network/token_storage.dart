import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps secure, encrypted-at-rest storage for the JWT access/refresh token
/// pair issued by `POST /api/auth/verify-otp` (and rotated by
/// `POST /api/auth/refresh-token`). Never store these in SharedPreferences —
/// they're bearer credentials.
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'brokerhouse_access_token';
  static const _refreshTokenKey = 'brokerhouse_refresh_token';

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
