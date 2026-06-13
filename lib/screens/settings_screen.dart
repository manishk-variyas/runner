import 'package:flutter/material.dart';
import 'package:runner/theme/catppuccin.dart';
import 'package:runner/theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const flavors = CatppuccinFlavor.values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cats = theme.extension<CatppuccinColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: themeController,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Theme', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              _FlavorSelector(),
              const SizedBox(height: 24),
              Text('Appearance', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: Icon(Icons.refresh, color: cats.green),
                  title: const Text('Reconnect on resume'),
                  subtitle: const Text('Auto-reconnect after app backgrounding'),
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text('About', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.info_outline, color: cats.subtext0),
                      title: const Text('Runner'),
                      subtitle: const Text('Version 1.0.0'),
                    ),
                    ListTile(
                      leading: Icon(Icons.code, color: cats.subtext0),
                      title: const Text('SSH Terminal Client'),
                      subtitle: const Text('Powered by dartssh3 + xterm.dart'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FlavorSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final current = themeController.value;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final flavor in SettingsScreen.flavors)
          ChoiceChip(
            label: Text(flavor.name.toUpperCase()),
            selected: flavor == current,
            onSelected: (_) => themeController.setFlavor(flavor),
          ),
      ],
    );
  }
}
