import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_key_store.dart';

class SecureApiKeyStore implements ApiKeyStore {
  SecureApiKeyStore(
      {FlutterSecureStorage storage = const FlutterSecureStorage()})
      : _storage = storage;

  final FlutterSecureStorage _storage;
  static const _storageKey = 'gemini_api_key';

  @override
  Future<void> delete() => _storage.delete(key: _storageKey);

  @override
  Future<String?> read() => _storage.read(key: _storageKey);

  @override
  Future<void> write(String key) =>
      _storage.write(key: _storageKey, value: key);
}
