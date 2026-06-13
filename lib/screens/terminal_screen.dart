import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dartssh3/dartssh3.dart';
import 'package:runner/services/session_manager.dart';
import 'package:runner/services/ssh_session.dart';

String _stripAnsi(String input) {
  return input
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '')
      .replaceAll(RegExp(r'\x1B\[[0-9;]*[a-zA-Z]'), '')
      .replaceAll(RegExp(r'\x1B\].*?(\x1B\\|\x07)'), '')
      .replaceAll(RegExp(r'\x1B[[\]()][0-9;]*'), '')
      .replaceAll(RegExp(r'\x1B[PMX^_]'), '')
      .replaceAll(RegExp(r'\x1B[0-9]+'), '');
}

class TerminalScreen extends StatefulWidget {
  final SessionManager manager;
  const TerminalScreen({super.key, required this.manager});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final _scrollCtrl = ScrollController();
  final _inputCtrl = TextEditingController();
  final _focusNode = FocusNode();
  StreamSubscription? _stdoutSub;
  bool _loading = true;

  SshSession? get _session => widget.manager.activeSession;
  bool get _connected =>
      _session != null && _session!.value == SshSessionState.connected;

  @override
  void initState() {
    super.initState();
    widget.manager.addListener(_onSessionsChanged);
    _startShell();
  }

  @override
  void dispose() {
    _stdoutSub?.cancel();
    widget.manager.removeListener(_onSessionsChanged);
    _scrollCtrl.dispose();
    _inputCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSessionsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _startShell() async {
    final session = _session;
    if (session == null || session.value != SshSessionState.connected) {
      _loading = false;
      if (session?.error != null) session!.output.write('Error: ${session.error}');
      setState(() {});
      return;
    }

    if (session.hasShell) {
      _loading = false;
      _listenShell(session);
      setState(() {});
      return;
    }

    try {
      final shell = await session.startShell();
      _loading = false;
      _listenShell(session);
    } catch (e) {
      session.output.writeln('Failed to start shell: $e');
      _loading = false;
      setState(() {});
    }
  }

  void _listenShell(SshSession session) {
    if (session.shell == null) return;
    _stdoutSub?.cancel();
    _stdoutSub = session.shell!.stdout.listen(
      (data) {
        session.output.write(_stripAnsi(utf8.decode(data)));
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollDown());
      },
      onError: (e) => session.output.writeln('Error: $e'),
      onDone: () {
        session.output.writeln('\nConnection closed.');
        setState(() {});
      },
      cancelOnError: false,
    );
  }

  void _sendCommand(String text) {
    final session = _session;
    if (session?.shell == null) return;
    session!.shell!.write(utf8.encode('$text\n'));
    _inputCtrl.clear();
  }

  void _scrollDown() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final terminalBg = const Color(0xFF1E1E2E);
    final terminalFg = const Color(0xFFCDD6F4);
    final promptColor = const Color(0xFFA6E3A1);

    return Scaffold(
      backgroundColor: terminalBg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF181825),
        foregroundColor: terminalFg,
        elevation: 0,
        title: Text(session?.profile.label ?? 'Terminal',
            style: const TextStyle(fontSize: 14)),
        actions: [
          if (widget.manager.sessions.length > 1)
            PopupMenuButton<int>(
              icon: const Icon(Icons.tab, size: 20),
              onSelected: (i) async {
                widget.manager.setActiveSession(i);
                await _startShell();
              },
              itemBuilder: (context) => [
                for (var i = 0; i < widget.manager.sessions.length; i++)
                  PopupMenuItem(
                    value: i,
                    child: Text(
                      '${widget.manager.sessions[i].profile.label}'
                      '${i == widget.manager.activeIndex ? ' ✓' : ''}',
                    ),
                  ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: Container(
                color: terminalBg,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  child: SelectableText(
                    (session?.output ?? StringBuffer()).toString(),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: terminalFg,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!_connected)
            Container(
              width: double.infinity,
              color: const Color(0xFF45475A),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: const Text('Connection closed',
                  style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Color(0xFFF38BA8))),
            ),
          Container(
            color: const Color(0xFF181825),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('\$ ',
                    style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: promptColor)),
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    focusNode: _focusNode,
                    enabled: _connected,
                    autofocus: true,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: terminalFg,
                    ),
                    cursorColor: promptColor,
                    cursorWidth: 8,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      hintText: 'Type a command...',
                      hintStyle: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Color(0xFF6C7086),
                      ),
                    ),
                    onSubmitted: _sendCommand,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
        ),
    );
  }
}
