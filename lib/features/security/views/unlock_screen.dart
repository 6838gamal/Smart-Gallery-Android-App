import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../services/security_service.dart';

class UnlockScreen extends ConsumerWidget {
  const UnlockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final state = ref.watch(securityStateProvider);
    final controller = TextEditingController();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 72, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text(l.unlock, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: l.enterPassword,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (v) async {
                  final ok = await ref.read(securityStateProvider.notifier).unlock(v);
                  if (ok && context.mounted) context.go('/gallery');
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final ok = await ref.read(securityStateProvider.notifier).unlock(controller.text);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.wrongPassword)));
                  } else if (context.mounted) {
                    context.go('/gallery');
                  }
                },
                child: Text(l.unlock),
              ),
              if (state.biometricEnabled) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l.biometricUnlock),
                  onPressed: () async {
                    final ok = await ref.read(securityStateProvider.notifier).unlockBiometric();
                    if (ok && context.mounted) context.go('/gallery');
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
