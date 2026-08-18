import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../services/security_service.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(securityStateProvider);
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.security)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l.lockApp),
            value: state.lockEnabled,
            onChanged: (v) async {
              if (v && !state.hasPassword) {
                await _setPassword(context, ref);
              } else if (!v) {
                ref.read(securityStateProvider.notifier).disableLock();
              }
            },
          ),
          if (state.lockEnabled) ...[
            ListTile(
              leading: const Icon(Icons.password),
              title: Text(l.setPassword),
              onTap: () => _setPassword(context, ref),
            ),
            SwitchListTile(
              title: Text(l.biometricUnlock),
              value: state.biometricEnabled,
              onChanged: (v) =>
                  ref.read(securityStateProvider.notifier).setBiometric(v),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _setPassword(BuildContext context, WidgetRef ref) async {
    final l = context.l;
    final p1 = await _prompt(context, l.setPassword, obscure: true);
    if (p1 == null) return;
    final p2 = await _prompt(context, l.confirmPassword, obscure: true);
    if (p2 == null) return;
    final ok = await ref.read(securityStateProvider.notifier).setPassword(p1, p2);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.passwordMismatch)));
    }
  }

  Future<String?> _prompt(BuildContext context, String label, {bool obscure = false}) async {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: c,
          obscureText: obscure,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, c.text), child: Text(context.l.ok)),
        ],
      ),
    );
  }
}
