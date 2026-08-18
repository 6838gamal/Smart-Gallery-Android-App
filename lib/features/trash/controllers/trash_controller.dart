import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/media_data_source.dart';
import '../../../data/models/media_item.dart';
import '../../../services/media/media_service.dart';

class TrashController extends Notifier<List<MediaItem>> {
  @override
  List<MediaItem> build() {
    Future.microtask(load);
    return const [];
  }

  Future<void> load() async {
    state = await MediaDataSource.instance.query(
      where: 'trashed_at IS NOT NULL',
      orderBy: 'trashed_at DESC',
    );
  }

  Future<void> restore(String id) async {
    await MediaDataSource.instance.restoreFromTrash(id);
    await load();
  }

  Future<void> deletePermanently(String id) async {
    await MediaDataSource.instance.deletePermanently(id);
    await MediaService.instance.deleteAssets([id]);
    await load();
  }

  Future<void> emptyTrash() async {
    final ids = state.map((m) => m.id).toList();
    await MediaService.instance.deleteAssets(ids);
    for (final id in ids) {
      await MediaDataSource.instance.deletePermanently(id);
    }
    await load();
  }
}

final trashControllerProvider =
    NotifierProvider<TrashController, List<MediaItem>>(TrashController.new);
