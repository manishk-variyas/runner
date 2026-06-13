import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dartssh3/dartssh3.dart';
import 'package:runner/models/ssh_profile.dart';

enum SshSessionState { disconnected, connecting, connected, error }

class SshSession extends ValueNotifier<SshSessionState> {
  final SshProfile profile;
  final Map<String, String> secrets;
  SSHClient? _client;
  SSHClient? _jumpClient;
  SSHSession? _shell;
  final StringBuffer output = StringBuffer();
  String? _error;
  StreamSubscription? _shellStdoutSub;
  StreamSubscription? _shellStderrSub;
  bool _disposed = false;

  SshSession(this.profile, {Map<String, String>? secrets})
      : secrets = secrets ?? const {},
        super(SshSessionState.disconnected);

  String? get error => _error;
  SSHClient? get client => _client;
  SSHSession? get shell => _shell;
  bool get hasShell => _shell != null;
  String get password => secrets['password'] ?? '';
  String get privateKey => secrets['privateKey'] ?? '';
  String get passphrase => secrets['passphrase'] ?? '';
  String get jumpPassword => secrets['jumpPassword'] ?? '';

  SSHClient _authClient(SSHSocket socket) => SSHClient(
        socket,
        username: profile.username,
        onPasswordRequest: () => password,
        identities: profile.authType == SshAuthType.key && privateKey.isNotEmpty
            ? SSHKeyPair.fromPem(privateKey, passphrase)
            : null,
        keepAliveInterval: const Duration(seconds: 30),
      );

  SSHClient _authJump(SSHSocket socket) => SSHClient(
        socket,
        username: profile.jumpUser,
        onPasswordRequest: () => jumpPassword,
      );

  Future<void> connect() async {
    if (_disposed) return;
    value = SshSessionState.connecting;
    _error = null;

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
      if (_disposed) return;

      value = SshSessionState.connected;
    } catch (e) {
      _error = e.toString();
      value = SshSessionState.error;
    }
  }

  Future<SSHSession> startShell() async {
    if (_client == null || _disposed) throw Exception('Not connected');
    _shell?.close();
    _shell = await _client!.shell();

    _shellStdoutSub = _shell!.stdout.listen(
      (data) {
        output.write(utf8.decode(data));
      },
      onError: (e) {
        _error = e.toString();
        value = SshSessionState.error;
      },
      onDone: () {
        if (!_disposed) {
          value = SshSessionState.disconnected;
        }
      },
    );

    _shellStderrSub = _shell!.stderr.listen(
          (data) => output.write(utf8.decode(data)),
        );

    return _shell!;
  }

  void writeToShell(String data) {
    _shell?.write(utf8.encode(data));
  }

  void writeBytesToShell(Uint8List bytes) {
    _shell?.write(bytes);
  }

  void closeShell() {
    _shellStdoutSub?.cancel();
    _shellStderrSub?.cancel();
    _shell?.close();
    _shell = null;
    _shellStdoutSub = null;
    _shellStderrSub = null;
  }

  Future<void> disconnect() async {
    closeShell();
    _client?.close();
    await _client?.done;
    _client = null;
    _jumpClient?.close();
    await _jumpClient?.done;
    _jumpClient = null;
    if (!_disposed) value = SshSessionState.disconnected;
  }

  Future<bool> reconnect() async {
    await disconnect();
    await connect();
    if (value == SshSessionState.connected && !_disposed) {
      await startShell();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _disposed = true;
    disconnect();
    super.dispose();
  }
}
