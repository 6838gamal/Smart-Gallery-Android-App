import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/media_data_source.dart';
import '../../../data/models/media_item.dart';

/// Loads a single [MediaItem] and exposes favorite/trash/share actions.
class MediaViewerController extends FamilyAsyncNotifier<MediaItem, String> {
  @override
  Future<MediaItem> build(String id) async {
    final item = await MediaDataSource.instance.getById(id);
    if (item == null) throw StateError('Media not found');
    return item;
  }

  Future<void> toggleFavorite() async {
    final item = state.valueOrNull;
    if (item == null) return;
    final next = !item.isFavorite;
    await MediaDataSource.instance.setFavorite(item.id, next);
    state = AsyncData(item.copyWith(isFavorite: next));
  }

  Future<void> moveToTrash() async {
    final item = state.valueOrNull;
    if (item == null) return;
    await MediaDataSource.instance.moveToTrash(item.id);
  }
}

final mediaViewerProvider =
    AsyncNotifierProvider.family<MediaViewerController, MediaItem, String>(
  MediaViewerController.new,
);
