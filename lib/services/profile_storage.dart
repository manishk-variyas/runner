import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:runner/models/ssh_profile.dart';

const _key = 'ssh_profiles';

class ProfileStorage {
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
}
