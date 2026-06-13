import 'package:flutter/material.dart';
import 'package:runner/models/ssh_profile.dart';
import 'package:runner/screens/profile_form_screen.dart';
import 'package:runner/screens/terminal_screen.dart';
import 'package:runner/services/session_manager.dart';
import 'package:runner/services/ssh_session.dart';

class ConnectionListScreen extends StatefulWidget {
  final SessionManager manager;
  const ConnectionListScreen({super.key, required this.manager});

  @override
  State<ConnectionListScreen> createState() => _ConnectionListScreenState();
}

class _ConnectionListScreenState extends State<ConnectionListScreen> {
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
    await widget.manager.connectProfile(profile.id);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TerminalScreen(manager: widget.manager),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profiles = widget.manager.profiles;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Servers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<SshProfile>(
            context,
            MaterialPageRoute(builder: (_) => const ProfileFormScreen()),
          );
          if (result != null) widget.manager.addProfile(result);
        },
        child: const Icon(Icons.add),
      ),
      body: profiles.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.dns_outlined, size: 64, color: theme.disabledColor),
                  const SizedBox(height: 16),
                  Text('No servers yet', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Tap + to add a server, or use the test VM:'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      final profile = SshProfile(
                        label: 'Local Test VM',
                        host: '10.0.2.2',
                        port: 2222,
                        username: 'root',
                        password: 'test123',
                      );
                      widget.manager.addProfile(profile);
                      _connect(profile);
                    },
                    icon: const Icon(Icons.cloud),
                    label: const Text('Connect to Local Test VM'),
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

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        status == null
                            ? Icons.cloud_outlined
                            : status == SshSessionState.connected
                                ? Icons.cloud_done
                                : Icons.cloud_off,
                      ),
                    ),
                    title: Text(p.label.isNotEmpty ? p.label : p.host),
                    subtitle: Text('${p.username}@${p.host}:${p.port}'),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                      onSelected: (action) async {
                        if (action == 'edit') {
                          final result = await Navigator.push<SshProfile>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileFormScreen(profile: p),
                            ),
                          );
                          if (result != null) widget.manager.updateProfile(result);
                        } else if (action == 'delete') {
                          widget.manager.deleteProfile(p.id);
                        }
                      },
                    ),
                    onTap: () => _connect(p),
                  ),
                );
              },
            ),
    );
  }
}
