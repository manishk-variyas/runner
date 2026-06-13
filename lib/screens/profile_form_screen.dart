import 'package:flutter/material.dart';
import 'package:runner/models/ssh_profile.dart';

class ProfileFormScreen extends StatefulWidget {
  final SshProfile? profile;
  final String? existingPassword;
  final String? existingPrivateKey;
  final String? existingPassphrase;
  final String? existingJumpPassword;

  const ProfileFormScreen({
    super.key,
    this.profile,
    this.existingPassword,
    this.existingPrivateKey,
    this.existingPassphrase,
    this.existingJumpPassword,
  });

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _labelCtrl;
  late final TextEditingController _hostCtrl;
  late final TextEditingController _portCtrl;
  late final TextEditingController _userCtrl;
  late final TextEditingController _passCtrl;
  late final TextEditingController _keyCtrl;
  late final TextEditingController _phraseCtrl;
  late final TextEditingController _jumpHostCtrl;
  late final TextEditingController _jumpPortCtrl;
  late final TextEditingController _jumpUserCtrl;
  late final TextEditingController _jumpPassCtrl;
  late SshAuthType _authType;
  bool _showPassword = false;
  bool _showJump = false;
  bool _showJumpPass = false;
  bool _showKey = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _labelCtrl = TextEditingController(text: p?.label ?? '');
    _hostCtrl = TextEditingController(text: p?.host ?? '');
    _portCtrl = TextEditingController(text: (p?.port ?? 22).toString());
    _userCtrl = TextEditingController(text: p?.username ?? 'root');
    _passCtrl = TextEditingController(text: widget.existingPassword ?? '');
    _keyCtrl = TextEditingController(text: widget.existingPrivateKey ?? '');
    _phraseCtrl = TextEditingController(text: widget.existingPassphrase ?? '');
    _jumpHostCtrl = TextEditingController(text: p?.jumpHost ?? '');
    _jumpPortCtrl = TextEditingController(text: (p?.jumpPort ?? 22).toString());
    _jumpUserCtrl = TextEditingController(text: p?.jumpUser ?? 'root');
    _jumpPassCtrl = TextEditingController(text: widget.existingJumpPassword ?? '');
    _authType = p?.authType ?? SshAuthType.password;
    _showJump = (p?.jumpHost ?? '').isNotEmpty;
  }

  @override
  void dispose() {
    for (final c in [
      _labelCtrl, _hostCtrl, _portCtrl, _userCtrl, _passCtrl,
      _keyCtrl, _phraseCtrl, _jumpHostCtrl, _jumpPortCtrl,
      _jumpUserCtrl, _jumpPassCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final profile = SshProfile(
      id: widget.profile?.id,
      label: _labelCtrl.text,
      host: _hostCtrl.text,
      port: int.tryParse(_portCtrl.text) ?? 22,
      username: _userCtrl.text,
      authType: _authType,
      jumpHost: _showJump ? _jumpHostCtrl.text : '',
      jumpPort: int.tryParse(_jumpPortCtrl.text) ?? 22,
      jumpUser: _jumpUserCtrl.text,
    );
    Navigator.pop(context, {
      'profile': profile,
      'password': _passCtrl.text,
      'privateKey': _keyCtrl.text,
      'passphrase': _phraseCtrl.text,
      'jumpPassword': _jumpPassCtrl.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.profile != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Server' : 'Add Server')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Connection', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextFormField(
              controller: _labelCtrl,
              decoration: const InputDecoration(
                labelText: 'Label',
                hintText: 'My Server',
                prefixIcon: Icon(Icons.label_outline, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _hostCtrl,
              decoration: const InputDecoration(
                labelText: 'Host',
                hintText: 'example.com',
                prefixIcon: Icon(Icons.dns_outlined, size: 20),
              ),
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _portCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      prefixIcon: Icon(Icons.numbers, size: 20),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _userCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Authentication', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<SshAuthType>(
              segments: const [
                ButtonSegment(value: SshAuthType.password, label: Text('Password')),
                ButtonSegment(value: SshAuthType.key, label: Text('Key')),
              ],
              selected: {_authType},
              onSelectionChanged: (s) => setState(() => _authType = s.first),
            ),
            const SizedBox(height: 12),
            if (_authType == SshAuthType.password)
              TextFormField(
                controller: _passCtrl,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: widget.profile != null ? 'Password (leave blank to keep)' : 'Password',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
              )
            else ...[
              TextFormField(
                controller: _keyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Private Key (PEM)',
                  prefixIcon: Icon(Icons.vpn_key_outlined, size: 20),
                ),
                maxLines: 4,
                obscureText: !_showKey,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phraseCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Passphrase',
                        prefixIcon: Icon(Icons.lock_outline, size: 20),
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showKey = !_showKey),
                    tooltip: 'Toggle key visibility',
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Jump Host / Proxy'),
              subtitle: const Text('Connect through a bastion server'),
              value: _showJump,
              onChanged: (v) => setState(() => _showJump = v),
            ),
            if (_showJump) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _jumpHostCtrl,
                decoration: const InputDecoration(
                  labelText: 'Jump Host',
                  prefixIcon: Icon(Icons.alt_route, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _jumpPortCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Jump Port',
                        prefixIcon: Icon(Icons.numbers, size: 20),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _jumpUserCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Jump User',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jumpPassCtrl,
                obscureText: !_showJumpPass,
                decoration: InputDecoration(
                  labelText: 'Jump Password',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_showJumpPass ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showJumpPass = !_showJumpPass),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: Icon(isEdit ? Icons.save : Icons.add),
              label: Text(isEdit ? 'Save Changes' : 'Add Server'),
            ),
          ],
        ),
      ),
    );
  }
}
