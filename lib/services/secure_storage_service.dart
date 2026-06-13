import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> delete(String key) => _storage.delete(key: key);

  static String passwordKey(String profileId) => '${profileId}_password';
  static String privateKeyKey(String profileId) => '${profileId}_private_key';
  static String passphraseKey(String profileId) => '${profileId}_passphrase';
  static String jumpPasswordKey(String profileId) => '${profileId}_jump_password';
}
