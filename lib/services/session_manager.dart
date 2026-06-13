import 'package:flutter/foundation.dart';
import 'package:runner/models/ssh_profile.dart';
import 'package:runner/services/profile_storage.dart';
import 'package:runner/services/ssh_session.dart';

class SessionManager extends ChangeNotifier {
  final _storage = ProfileStorage();
  List<SshProfile> _profiles = [];
  final List<SshSession> _sessions = [];
  int _activeIndex = 0;

  List<SshProfile> get profiles => List.unmodifiable(_profiles);
  List<SshSession> get sessions => List.unmodifiable(_sessions);
  int get activeIndex => _activeIndex;
  SshSession? get activeSession =>
      _sessions.isNotEmpty ? _sessions[_activeIndex] : null;

  Future<void> loadProfiles() async {
    _profiles = await _storage.load();
    notifyListeners();
  }

  Future<void> _saveProfiles() async {
    await _storage.save(_profiles);
  }

  void addProfile(SshProfile profile) {
    _profiles.add(profile);
    _saveProfiles();
    notifyListeners();
  }

  void updateProfile(SshProfile profile) {
    final i = _profiles.indexWhere((p) => p.id == profile.id);
    if (i != -1) _profiles[i] = profile;
    _saveProfiles();
    notifyListeners();
  }

  void deleteProfile(String id) {
    _profiles.removeWhere((p) => p.id == id);
    final session = _sessions.cast<SshSession?>().firstWhere(
          (s) => s!.profile.id == id,
          orElse: () => null,
        );
    if (session != null) {
      session.dispose();
      _sessions.remove(session);
    }
    _saveProfiles();
    notifyListeners();
  }

  Future<bool> connectProfile(String profileId) async {
    final profile = _profiles.firstWhere((p) => p.id == profileId);
    final existing = _sessions.indexWhere((s) => s.profile.id == profileId);

    SshSession session;
    if (existing != -1) {
      session = _sessions[existing];
      _activeIndex = existing;
    } else {
      session = SshSession(profile);
      _sessions.add(session);
      _activeIndex = _sessions.length - 1;
      session.addListener(_onSessionChanged);
    }

    notifyListeners();
    if (session.value == SshSessionState.disconnected) {
      await session.connect();
    }

    return session.value == SshSessionState.connected;
  }

  void setActiveSession(int index) {
    _activeIndex = index;
    notifyListeners();
  }

  void closeSession(int index) {
    final session = _sessions[index];
    session.removeListener(_onSessionChanged);
    session.dispose();
    _sessions.removeAt(index);
    if (_activeIndex >= _sessions.length) {
      _activeIndex = (_sessions.length - 1).clamp(0, _sessions.length - 1);
    }
    notifyListeners();
  }

  void _onSessionChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _sessions) {
      s.removeListener(_onSessionChanged);
      s.dispose();
    }
    super.dispose();
  }
}
