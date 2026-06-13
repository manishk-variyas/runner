import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dartssh3/dartssh3.dart';
import 'package:runner/models/ssh_profile.dart';

enum SshSessionState { disconnected, connecting, connected, error }

class SshSession extends ValueNotifier<SshSessionState> {
  final SshProfile profile;
  SSHClient? _client;
  SSHClient? _jumpClient;
  SSHSession? shell;
  final StringBuffer output = StringBuffer();
  String? _error;

  SshSession(this.profile) : super(SshSessionState.disconnected);

  String? get error => _error;
  SSHClient? get client => _client;
  bool get hasShell => shell != null;

  SSHClient _authClient(SSHSocket socket) => SSHClient(
        socket,
        username: profile.username,
        onPasswordRequest: () => profile.password,
        identities: profile.authType == SshAuthType.key
            ? SSHKeyPair.fromPem(profile.privateKey, profile.passphrase)
            : null,
      );

  SSHClient _authJump(SSHSocket socket) => SSHClient(
        socket,
        username: profile.jumpUser,
        onPasswordRequest: () => profile.jumpPassword,
      );

  Future<void> connect() async {
    value = SshSessionState.connecting;

    try {
      if (profile.jumpHost.isNotEmpty) {
        final jumpSocket = await SSHSocket.connect(profile.jumpHost, profile.jumpPort);
        _jumpClient = _authJump(jumpSocket);
        await _jumpClient!.authenticated;

        final targetSocket = await _jumpClient!.forwardLocal(profile.host, profile.port);
        _client = _authClient(targetSocket);
      } else {
        final socket = await SSHSocket.connect(profile.host, profile.port);
        _client = _authClient(socket);
      }

      await _client!.authenticated;
      value = SshSessionState.connected;
    } catch (e) {
      _error = e.toString();
      value = SshSessionState.error;
    }
  }

  Future<SSHSession> startShell() async {
    if (_client == null) throw Exception('Not connected');
    shell = await _client!.shell();
    return shell!;
  }

  void closeShell() {
    shell?.close();
    shell = null;
  }

  Future<void> disconnect() async {
    closeShell();
    _client?.close();
    await _client?.done;
    _client = null;
    _jumpClient?.close();
    await _jumpClient?.done;
    _jumpClient = null;
    value = SshSessionState.disconnected;
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
