abstract interface class ApiKeyStore {
  Future<String?> read();

  Future<void> write(String key);

  Future<void> delete();
}
