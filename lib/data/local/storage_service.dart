import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A service to handle persistent session state securely using native keystores.
class StorageService {
  static const _storage = FlutterSecureStorage();

  static const String _keyAccessToken = 'accessToken';
  static const String _keyRefreshToken = 'refreshToken';
  static const String _keyUserId = 'userId';

  /// 1. Start a Session (Login/Signup)
  /// Saves the JWT tokens and user ID into the secure enclave.
  static Future<void> startSession(String accessToken, String refreshToken, String userId) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    await _storage.write(key: _keyUserId, value: userId);
  }

  /// 2. Check Login Status
  /// Returns true if an access token exists.
  static Future<bool> isUserLoggedIn() async {
    final token = await _storage.read(key: _keyAccessToken);
    return token != null && token.isNotEmpty;
  }

  /// 3. Get Active User ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  /// 4. Get Access Token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  /// 5. Get Refresh Token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// 6. End Session (Logout)
  /// Clears the securely saved keys.
  static Future<void> clearSession() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserId);
  }
}
