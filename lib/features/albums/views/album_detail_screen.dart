import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../shared/widgets/media_thumbnail.dart';
import '../controllers/albums_controller.dart';

class AlbumDetailScreen extends ConsumerWidget {
  const AlbumDetailScreen({super.key, required this.albumId});
  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final mediaAsync = ref.watch(albumMediaProvider(albumId));
    return Scaffold(
      appBar: AppBar(title: Text(l.albums)),
      body: mediaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l.noMedia));
          }
          return GridView.builder(
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
              );
            },
          );
        },
      ),
    );
  }
}
