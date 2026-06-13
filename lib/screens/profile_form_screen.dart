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
  late SshAuthType _authType;

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
    _authType = p?.authType ?? SshAuthType.password;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _keyCtrl.dispose();
    _phraseCtrl.dispose();
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
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
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
            const SizedBox(height: 24),
            FilledButton(onPressed: _submit, child: Text(isEdit ? 'Save' : 'Add')),
          ],
        ),
      ),
    );
  }
}
