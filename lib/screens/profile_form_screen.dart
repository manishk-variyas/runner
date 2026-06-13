import 'package:flutter/material.dart';
import 'package:runner/models/ssh_profile.dart';

class ProfileFormScreen extends StatefulWidget {
  final SshProfile? profile;
  const ProfileFormScreen({super.key, this.profile});

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

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _labelCtrl = TextEditingController(text: p?.label ?? '');
    _hostCtrl = TextEditingController(text: p?.host ?? '');
    _portCtrl = TextEditingController(text: (p?.port ?? 22).toString());
    _userCtrl = TextEditingController(text: p?.username ?? 'root');
    _passCtrl = TextEditingController(text: p?.password ?? '');
    _keyCtrl = TextEditingController(text: p?.privateKey ?? '');
    _phraseCtrl = TextEditingController(text: p?.passphrase ?? '');
    _jumpHostCtrl = TextEditingController(text: p?.jumpHost ?? '');
    _jumpPortCtrl = TextEditingController(text: (p?.jumpPort ?? 22).toString());
    _jumpUserCtrl = TextEditingController(text: p?.jumpUser ?? 'root');
    _jumpPassCtrl = TextEditingController(text: p?.jumpPassword ?? '');
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
      port: int.parse(_portCtrl.text),
      username: _userCtrl.text,
      authType: _authType,
      password: _passCtrl.text,
      privateKey: _keyCtrl.text,
      passphrase: _phraseCtrl.text,
      jumpHost: _showJump ? _jumpHostCtrl.text : '',
      jumpPort: int.tryParse(_jumpPortCtrl.text) ?? 22,
      jumpUser: _jumpUserCtrl.text,
      jumpPassword: _jumpPassCtrl.text,
    );

    Navigator.pop(context, profile);
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
            TextFormField(
              controller: _labelCtrl,
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _hostCtrl,
              decoration: const InputDecoration(labelText: 'Host'),
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _portCtrl,
              decoration: const InputDecoration(labelText: 'Port'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _userCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            SegmentedButton<SshAuthType>(
              segments: const [
                ButtonSegment(value: SshAuthType.password, label: Text('Password')),
                ButtonSegment(value: SshAuthType.key, label: Text('Private Key')),
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
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
              )
            else ...[
              TextFormField(
                controller: _keyCtrl,
                decoration: const InputDecoration(labelText: 'Private Key (PEM)'),
                maxLines: 6,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phraseCtrl,
                decoration: const InputDecoration(labelText: 'Passphrase'),
                obscureText: true,
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
                decoration: const InputDecoration(labelText: 'Jump Host'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jumpPortCtrl,
                decoration: const InputDecoration(labelText: 'Jump Port'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jumpUserCtrl,
                decoration: const InputDecoration(labelText: 'Jump Username'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jumpPassCtrl,
                obscureText: !_showJumpPass,
                decoration: InputDecoration(
                  labelText: 'Jump Password',
                  suffixIcon: IconButton(
                    icon: Icon(_showJumpPass ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showJumpPass = !_showJumpPass),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(onPressed: _submit, child: Text(isEdit ? 'Save' : 'Add')),
          ],
        ),
      ),
    );
  }
}
