import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dartssh3/dartssh3.dart';
import 'package:runner/models/ssh_profile.dart';

enum SshSessionState { disconnected, connecting, connected, error }

class SshSession extends ValueNotifier<SshSessionState> {
  final SshProfile profile;
  SSHClient? _client;
  String? _error;

  SshSession(this.profile) : super(SshSessionState.disconnected);

  String? get error => _error;
  SSHClient? get client => _client;

  Future<void> connect() async {
    value = SshSessionState.connecting;

    try {
      final socket = await SSHSocket.connect(profile.host, profile.port);

      _client = SSHClient(
        socket,
        username: profile.username,
        onPasswordRequest: () => profile.password,
        identities: profile.authType == SshAuthType.key
            ? SSHKeyPair.fromPem(profile.privateKey, profile.passphrase)
            : null,
      );

      await _client!.authenticated;
      value = SshSessionState.connected;
    } catch (e) {
      _error = e.toString();
      value = SshSessionState.error;
    }
  }

  Future<SSHSession> shell() async {
    if (_client == null) throw Exception('Not connected');
    return _client!.shell();
  }

  Future<String> run(String command) async {
    if (_client == null) throw Exception('Not connected');
    final result = await _client!.run(command);
    return utf8.decode(result);
  }

  Future<void> disconnect() async {
    _client?.close();
    await _client?.done;
    _client = null;
    value = SshSessionState.disconnected;
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
