import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/media_data_source.dart';
import '../../../data/models/media_item.dart';

class FavoritesController extends Notifier<List<MediaItem>> {
  @override
  List<MediaItem> build() {
    Future.microtask(load);
    return const [];
  }

  Future<void> load() async {
    state = await MediaDataSource.instance.query(
      where: 'is_favorite = 1 AND trashed_at IS NULL',
      orderBy: 'created_at DESC',
    );
  }

  Future<void> remove(String id) async {
    await MediaDataSource.instance.setFavorite(id, false);
    await load();
  }
}

final favoritesControllerProvider =
    NotifierProvider<FavoritesController, List<MediaItem>>(FavoritesController.new);
