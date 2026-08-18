import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/media_item.dart';
import '../../media_scanner/services/media_scanner.dart';
import '../controllers/gallery_controller.dart';
import '../providers/sort_provider.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../shared/widgets/media_thumbnail.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(galleryControllerProvider);
    final l = context.l;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.gallery),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(mediaScannerProvider).scan(),
          ),
          _SortButton(),
        ],
      ),
      body: state.isRefreshing && state.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
              ? _Empty(l: l)
              : _Grid(state: state),
    );
  }
}

class _SortButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(sortProvider);
    final l = context.l;
    return PopupMenuButton<SortField>(
      icon: const Icon(Icons.sort),
      tooltip: l.sortBy,
      onSelected: (f) => ref.read(sortProvider.notifier).setField(f),
      itemBuilder: (_) => [
        _item(l.sortByDate, SortField.date, sort.field),
        _item(l.sortByName, SortField.name, sort.field),
        _item(l.sortBySize, SortField.size, sort.field),
        _item(l.sortByType, SortField.type, sort.field),
        _item(l.sortByAlbum, SortField.album, sort.field),
      ],
    );
  }

  PopupMenuItem<SortField> _item(String label, SortField f, SortField current) {
    return PopupMenuItem(
      value: f,
      child: Row(children: [
        Icon(f == current ? Icons.check : null),
        const SizedBox(width: 8),
        Text(label),
      ]),
    );
  }
}

class _Grid extends ConsumerWidget {
  const _Grid({required this.state});
  final GalleryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(galleryControllerProvider.notifier);
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: state.items.length + (controller.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return VisibilityDetector(
            key: const Key('loader'),
            onVisibilityChanged: (info) {
              if (info.visibleFraction > 0) controller.loadMore();
            },
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final item = state.items[index];
        return MediaThumbnail(
          item: item,
          onTap: () => context.go('/viewer/${item.id}'),
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l});
  final AppLocalizations l;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_outlined, size: 72, color: AppColors.neutral400),
          const SizedBox(height: 16),
          Text(l.noMedia, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l.noMediaHint, style: TextStyle(color: AppColors.neutral600)),
        ],
      ),
    );
  }
}
