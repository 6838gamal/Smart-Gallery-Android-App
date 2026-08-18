import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../data/models/media_item.dart';
import '../../../services/thumbnails/thumbnail_service.dart';

/// A single grid cell. Uses the on-disk thumbnail cache and shows a video
/// badge + duration when relevant.
class MediaThumbnail extends ConsumerStatefulWidget {
  const MediaThumbnail({super.key, required this.item, this.onTap, this.onLongPress, this.selected = false, this.selectionMode = false});
  final MediaItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool selectionMode;

  @override
  ConsumerState<MediaThumbnail> createState() => _MediaThumbnailState();
}

class _MediaThumbnailState extends ConsumerState<MediaThumbnail> {
  Future<ImageProvider?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<ImageProvider?> _load() async {
    final asset = await AssetEntity.fromId(widget.item.id);
    if (asset == null) return null;
    return ThumbnailService.instance.provider(asset);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FutureBuilder<ImageProvider?>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return Container(color: Theme.of(context).colorScheme.surfaceContainerHighest);
                }
                final img = snap.data;
                if (img == null) {
                  return Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.broken_image_outlined),
                  );
                }
                return Image(image: img, fit: BoxFit.cover);
              },
            ),
          ),
          if (widget.item.isVideo)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 18),
              ),
            ),
          if (widget.item.isFavorite)
            const Positioned(
              top: 4,
              right: 4,
              child: Icon(Icons.favorite, color: Colors.redAccent, size: 18),
            ),
          if (widget.selectionMode)
            Positioned(
              top: 4,
              left: 4,
              child: Icon(
                widget.selected ? Icons.check_circle : Icons.circle_outlined,
                color: widget.selected ? Theme.of(context).colorScheme.primary : Colors.white,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }
}
