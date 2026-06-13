import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';
import 'package:runner/screens/settings_screen.dart';
import 'package:runner/services/session_manager.dart';
import 'package:runner/services/ssh_session.dart';
import 'package:runner/theme/catppuccin.dart';
import 'package:runner/widgets/terminal_keyboard_toolbar.dart';

const _catppuccinTheme = TerminalTheme(
  cursor: Color(0xFFF5E0DC),
  selection: Color(0xFF585B70),
  foreground: Color(0xFFCDD6F4),
  background: Color(0xFF1E1E2E),
  black: Color(0xFF45475A),
  red: Color(0xFFF38BA8),
  green: Color(0xFFA6E3A1),
  yellow: Color(0xFFF9E2AF),
  blue: Color(0xFF89B4FA),
  magenta: Color(0xFFCBA6F7),
  cyan: Color(0xFF94E2D5),
  white: Color(0xFFBAC2DE),
  brightBlack: Color(0xFF585B70),
  brightRed: Color(0xFFF38BA8),
  brightGreen: Color(0xFFA6E3A1),
  brightYellow: Color(0xFFF9E2AF),
  brightBlue: Color(0xFF89B4FA),
  brightMagenta: Color(0xFFCBA6F7),
  brightCyan: Color(0xFF94E2D5),
  brightWhite: Color(0xFFA6ADC8),
  searchHitBackground: Color(0xFF585B70),
  searchHitBackgroundCurrent: Color(0xFFF5E0DC),
  searchHitForeground: Color(0xFF1E1E2E),
);

class TerminalScreen extends StatefulWidget {
  final SessionManager manager;
  const TerminalScreen({super.key, required this.manager});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> with WidgetsBindingObserver {
  Terminal? _terminal;
  late final TerminalController _controller;
  StreamSubscription? _stdoutSub;
  bool _showToolbar = true;

  SshSession? get _session => widget.manager.activeSession;

  @override
  void initState() {
    super.initState();
    _controller = TerminalController();
    WidgetsBinding.instance.addObserver(this);
    widget.manager.addListener(_onSessionsChanged);
    _initTerminal();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stdoutSub?.cancel();
    _terminal?.onOutput = null;
    widget.manager.removeListener(_onSessionsChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _session?.writeToShell('\x1b[2J\x1b[H');
    }
  }

  void _onSessionsChanged() {
    if (mounted) setState(() {});
  }

  void _initTerminal() {
    _stdoutSub?.cancel();

    final session = _session;
    if (session == null) return;

    _terminal = Terminal(
      onOutput: (data) {
        session.writeToShell(data);
      },
    );

    _pipeOutput();
  }

  void _pipeOutput() {
    final session = _session;
    if (session?.shell == null) return;
    _stdoutSub?.cancel();

    _stdoutSub = session!.shell!.stdout.listen(
      (data) => _terminal?.write(utf8.decode(data)),
      onError: (e) => _terminal?.write('\r\nError: $e'),
      onDone: () => _terminal?.write('\r\n\x1b[31mConnection closed.\x1b[0m'),
    );
  }

  void _onToolbarInput(String text) {
    if (text.isEmpty) return;
    _session?.writeToShell(text);
  }

  void _handleCopy() {
    final selection = _controller.selection;
    if (selection != null && _terminal != null) {
      final text = _terminal!.buffer.getText(selection);
      _controller.clearSelection();
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
      );
    }
  }

  void _handlePaste() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.isNotEmpty) {
      _session?.writeToShell(data.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final status = session?.value;
    final cats = Theme.of(context).extension<CatppuccinColors>()!;

    Color statusColor;
    String statusText;
    IconData statusIcon;
    switch (status) {
      case SshSessionState.connecting:
        statusColor = cats.yellow;
        statusText = 'Connecting...';
        statusIcon = Icons.sync;
      case SshSessionState.connected:
        statusColor = cats.green;
        statusText = 'Connected';
        statusIcon = Icons.cloud_done;
      case SshSessionState.error:
        statusColor = cats.red;
        statusText = 'Error';
        statusIcon = Icons.error_outline;
      default:
        statusColor = cats.subtext0;
        statusText = 'Disconnected';
        statusIcon = Icons.cloud_off;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181825),
        foregroundColor: const Color(0xFFCDD6F4),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session?.profile.label ?? 'Terminal',
                style: const TextStyle(fontSize: 14)),
            if (session != null)
              Row(
                children: [
                  Icon(statusIcon, size: 10, color: statusColor),
                  const SizedBox(width: 4),
                  Text(statusText,
                      style: TextStyle(fontSize: 10, color: statusColor)),
                ],
              ),
          ],
        ),
        actions: [
          if (status == SshSessionState.connected)
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: 'Reconnect',
              onPressed: () => _session?.reconnect().then((_) => _initTerminal()),
            ),
          if (widget.manager.sessions.length > 1)
            PopupMenuButton<int>(
              icon: const Icon(Icons.tab, size: 20),
              onSelected: (i) {
                widget.manager.setActiveSession(i);
                _initTerminal();
                setState(() {});
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
            icon: const Icon(Icons.settings, size: 18),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _terminal != null
                ? TerminalView(
                    _terminal!,
                    theme: _catppuccinTheme,
                    controller: _controller,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                  )
                : _buildStatusView(session, cats),
          ),
          if (_showToolbar)
            TerminalKeyboardToolbar(
              onInput: _onToolbarInput,
              onCopy: _handleCopy,
              onPaste: _handlePaste,
              onDismiss: () => setState(() => _showToolbar = false),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusView(SshSession? session, CatppuccinColors cats) {
    if (session == null) {
      return const Center(
        child: Text('No active session', style: TextStyle(color: Color(0xFF585B70))),
      );
    }
    switch (session.value) {
      case SshSessionState.connecting:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: cats.yellow),
              const SizedBox(height: 16),
              Text('Connecting to ${session.profile.label}...',
                  style: TextStyle(color: cats.subtext0)),
            ],
          ),
        );
      case SshSessionState.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: cats.red),
              const SizedBox(height: 16),
              Text('Connection failed', style: TextStyle(color: cats.red, fontSize: 16)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(session.error ?? 'Unknown error',
                    style: TextStyle(color: cats.subtext0, fontSize: 12),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  await session.reconnect();
                  if (mounted) _initTerminal();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      case SshSessionState.disconnected:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 48, color: cats.subtext0),
              const SizedBox(height: 16),
              Text('Disconnected', style: TextStyle(color: cats.subtext0, fontSize: 16)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  final ok = await widget.manager.connectProfile(session.profile.id);
                  if (ok && mounted) _initTerminal();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reconnect'),
              ),
            ],
          ),
        );
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }
}
