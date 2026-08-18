import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/media_thumbnail.dart';
import '../controllers/favorites_controller.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final items = ref.watch(favoritesControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.favorites)),
      body: items.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.favorite_border, size: 72, color: AppColors.neutral400),
                const SizedBox(height: 16),
                Text(l.noFavorites, style: Theme.of(context).textTheme.titleMedium),
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
                  onTap: () => context.go('/viewer/${item.id}'),
                  onLongPress: () => ref.read(favoritesControllerProvider.notifier).remove(item.id),
                );
              },
            ),
    );
  }
}
