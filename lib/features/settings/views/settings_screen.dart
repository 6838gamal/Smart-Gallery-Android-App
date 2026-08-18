import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../backup/services/backup_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        children: [
          _Section(l.themeMode, [
            for (final mode in ThemeMode.values)
              RadioListTile<ThemeMode>(
                title: Text(_modeLabel(mode, l)),
                value: mode,
                groupValue: settings.themeMode,
                onChanged: (v) => ref.read(settingsProvider.notifier).setThemeMode(v!),
              ),
          ]),
          _Section(l.language, [
            RadioListTile<Locale>(
              title: Text(l.arabic),
              value: const Locale('ar'),
              groupValue: settings.locale,
              onChanged: (v) => ref.read(settingsProvider.notifier).setLocale(v!),
            ),
            RadioListTile<Locale>(
              title: Text(l.english),
              value: const Locale('en'),
              groupValue: settings.locale,
              onChanged: (v) => ref.read(settingsProvider.notifier).setLocale(v!),
            ),
          ]),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text(l.security),
            onTap: () => context.push('/security'),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: Text(l.favorites),
            onTap: () => context.push('/favorites'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l.trash),
            onTap: () => context.push('/trash'),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: Text(l.backup),
            subtitle: Text(NoopBackupProvider().displayName),
            enabled: false,
          ),
        ],
      ),
    );
  }

  String _modeLabel(ThemeMode m, AppLocalizations l) => switch (m) {
        ThemeMode.light => l.light,
        ThemeMode.dark => l.dark,
        ThemeMode.system => l.system,
      };
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.children);
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(title, style: Theme.of(context).textTheme.labelLarge),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
