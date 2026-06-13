import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:runner/models/ssh_profile.dart';
import 'package:runner/services/secure_storage_service.dart';

const _key = 'ssh_profiles';

class ProfileStorage {
  final SecureStorageService _secure;
  ProfileStorage() : _secure = SecureStorageService();

  Future<List<SshProfile>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => SshProfile.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> save(List<SshProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(profiles.map((p) => p.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  Future<void> saveSecrets(SshProfile profile, {
    String? password,
    String? privateKey,
    String? passphrase,
    String? jumpPassword,
  }) async {
    if (password != null && password.isNotEmpty) {
      await _secure.write(SecureStorageService.passwordKey(profile.id), password);
    }
    if (privateKey != null && privateKey.isNotEmpty) {
      await _secure.write(SecureStorageService.privateKeyKey(profile.id), privateKey);
    }
    if (passphrase != null && passphrase.isNotEmpty) {
      await _secure.write(SecureStorageService.passphraseKey(profile.id), passphrase);
    }
    if (jumpPassword != null && jumpPassword.isNotEmpty) {
      await _secure.write(SecureStorageService.jumpPasswordKey(profile.id), jumpPassword);
    }
  }

  Future<Map<String, String>> loadSecrets(SshProfile profile) async {
    final password = await _secure.read(SecureStorageService.passwordKey(profile.id));
    final privateKey = await _secure.read(SecureStorageService.privateKeyKey(profile.id));
    final passphrase = await _secure.read(SecureStorageService.passphraseKey(profile.id));
    final jumpPassword = await _secure.read(SecureStorageService.jumpPasswordKey(profile.id));
    return {
      'password': password ?? '',
      'privateKey': privateKey ?? '',
      'passphrase': passphrase ?? '',
      'jumpPassword': jumpPassword ?? '',
    };
  }

  Future<void> deleteSecrets(String profileId) async {
    await _secure.delete(SecureStorageService.passwordKey(profileId));
    await _secure.delete(SecureStorageService.privateKeyKey(profileId));
    await _secure.delete(SecureStorageService.passphraseKey(profileId));
    await _secure.delete(SecureStorageService.jumpPasswordKey(profileId));
  }
}
