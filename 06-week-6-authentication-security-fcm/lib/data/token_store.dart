import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// All tokens enter and leave the app only through this class.
/// Backed by Keychain (iOS) / Keystore (Android) via flutter_secure_storage.
/// NEVER use SharedPreferences for tokens: it is not encrypted.
class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<String?> readAccess() => _storage.read(key: _accessKey);
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  Future<void> clear() => _storage.deleteAll();
}

/// Safe way to show a token in the UI / screenshots: first 12 characters + "...".
/// Never print or screenshot a full token.
String truncateToken(String token) {
  if (token.length <= 12) return '${token.substring(0, token.length ~/ 2)}...';
  return '${token.substring(0, 12)}...';
}
