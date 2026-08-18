import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/media_thumbnail.dart';
import '../controllers/trash_controller.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final items = ref.watch(trashControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.trash),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: l.deletePermanently,
              onPressed: () async {
                final ok = await _confirm(context, l.deleteConfirm);
                if (ok) ref.read(trashControllerProvider.notifier).emptyTrash();
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.delete_outline, size: 72, color: AppColors.neutral400),
                const SizedBox(height: 16),
                Text(l.noTrash, style: Theme.of(context).textTheme.titleMedium),
              ]),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return MediaThumbnail(
                  item: item,
                  onTap: () => _actions(context, ref, item.id),
                );
              },
            ),
    );
  }

  Future<bool> _confirm(BuildContext context, String msg) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(false), child: Text(context.l.cancel)),
          TextButton(onPressed: () => Navigator.pop(true), child: Text(context.l.confirm)),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _actions(BuildContext context, WidgetRef ref, String id) async {
    final l = context.l;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(l.restore),
            onTap: () => Navigator.pop('restore'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: Text(l.deletePermanently),
            onTap: () => Navigator.pop('delete'),
          ),
        ],
      ),
    );
    final c = ref.read(trashControllerProvider.notifier);
    if (action == 'restore') {
      c.restore(id);
    } else if (action == 'delete') {
      c.deletePermanently(id);
    }
  }
}
