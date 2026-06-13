import 'package:flutter/material.dart';
import 'package:runner/models/ssh_profile.dart';
import 'package:runner/screens/profile_form_screen.dart';
import 'package:runner/screens/settings_screen.dart';
import 'package:runner/screens/terminal_screen.dart';
import 'package:runner/services/session_manager.dart';
import 'package:runner/services/ssh_session.dart';
import 'package:runner/theme/catppuccin.dart';

class ConnectionListScreen extends StatefulWidget {
  final SessionManager manager;
  const ConnectionListScreen({super.key, required this.manager});

  @override
  State<ConnectionListScreen> createState() => _ConnectionListScreenState();
}

class _ConnectionListScreenState extends State<ConnectionListScreen> {
  String? _connectingId;

  @override
  void initState() {
    super.initState();
    widget.manager.loadProfiles();
    widget.manager.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.manager.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  Future<void> _connect(SshProfile profile) async {
    setState(() => _connectingId = profile.id);
    final success = await widget.manager.connectProfile(profile.id);
    _connectingId = null;
    if (!mounted) return;
    if (!success) {
      final session = widget.manager.sessions.cast<SshSession?>().firstWhere(
            (s) => s!.profile.id == profile.id,
            orElse: () => null,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(session?.error ?? 'Failed to connect to ${profile.label}'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _connect(profile),
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TerminalScreen(manager: widget.manager),
      ),
    );
  }

  Future<void> _editProfile(SshProfile profile) async {
    final result = await Navigator.push<Map>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileFormScreen(profile: profile),
      ),
    );
    if (result != null && mounted) {
      final p = result['profile'] as SshProfile;
      widget.manager.updateProfile(
        p,
        password: result['password'] as String?,
        privateKey: result['privateKey'] as String?,
        passphrase: result['passphrase'] as String?,
        jumpPassword: result['jumpPassword'] as String?,
      );
    }
  }

  Future<bool> _confirmDelete(SshProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete server?'),
        content: Text('Remove "${profile.label}" (${profile.host})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      widget.manager.deleteProfile(profile.id);
      return true;
    }
    return false;
  }

  Future<void> _addServer() async {
    final result = await Navigator.push<Map>(
      context,
      MaterialPageRoute(builder: (_) => const ProfileFormScreen()),
    );
    if (result != null && mounted) {
      final p = result['profile'] as SshProfile;
      widget.manager.addProfile(
        p,
        password: result['password'] as String?,
        privateKey: result['privateKey'] as String?,
        passphrase: result['passphrase'] as String?,
        jumpPassword: result['jumpPassword'] as String?,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profiles = widget.manager.profiles;
    final theme = Theme.of(context);
    final cats = theme.extension<CatppuccinColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Runner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addServer,
        child: const Icon(Icons.add),
      ),
      body: profiles.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.dns_outlined, size: 64, color: cats.subtext0),
                  const SizedBox(height: 16),
                  Text('No servers yet', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Tap + to add a server',
                      style: TextStyle(color: cats.subtext0)),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _addServer,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Server'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: profiles.length,
              itemBuilder: (context, i) {
                final p = profiles[i];
                final session = widget.manager.sessions.cast<SshSession?>().firstWhere(
                      (s) => s!.profile.id == p.id,
                      orElse: () => null,
                    );
                final status = session?.value;
                final isConnecting = _connectingId == p.id;

                Color statusColor;
                IconData statusIcon;
                switch (status) {
                  case SshSessionState.connecting:
                    statusColor = cats.yellow;
                    statusIcon = Icons.sync;
                  case SshSessionState.connected:
                    statusColor = cats.green;
                    statusIcon = Icons.cloud_done;
                  case SshSessionState.error:
                    statusColor = cats.red;
                    statusIcon = Icons.error_outline;
                  default:
                    statusColor = cats.subtext0;
                    statusIcon = Icons.cloud_outlined;
                }

                return Card(
                  child: Dismissible(
                    key: ValueKey(p.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: theme.colorScheme.error,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) => _confirmDelete(p),
                    child: ListTile(
                      leading: isConnecting
                          ? SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cats.yellow,
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: statusColor.withAlpha(40),
                              child: Icon(statusIcon, color: statusColor, size: 20),
                            ),
                      title: Text(p.label.isNotEmpty ? p.label : p.host),
                      subtitle: Text('${p.username}@${p.host}:${p.port}'),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: ListTile(
                            leading: Icon(Icons.edit, size: 20),
                            title: Text('Edit'),
                            dense: true,
                          )),
                          const PopupMenuItem(value: 'delete', child: ListTile(
                            leading: Icon(Icons.delete, size: 20),
                            title: Text('Delete'),
                            dense: true,
                          )),
                        ],
                        onSelected: (action) async {
                          if (action == 'edit') {
                            await _editProfile(p);
                          } else if (action == 'delete') {
                            await _confirmDelete(p);
                          }
                        },
                      ),
                      onTap: () => _connect(p),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
