import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/album_data_source.dart';
import '../../../data/datasources/media_data_source.dart';
import '../../../data/models/album.dart';
import '../../../services/media/media_service.dart';

class AlbumsController extends Notifier<AlbumsState> {
  @override
  AlbumsState build() {
    Future.microtask(load);
    return const AlbumsState();
  }

  Future<void> load() async {
    state = state.copyWith(loading: true);
    final deviceAlbums = await MediaService.instance.getAlbums();
    final dbAlbums = await AlbumDataSource.instance.all(includeHidden: true);
    final hiddenIds = dbAlbums.where((a) => a.isHidden).map((a) => a.id).toSet();
    final albums = <Album>[];
    for (final p in deviceAlbums) {
      albums.add(Album.fromPathEntity(p).copyWith(isHidden: hiddenIds.contains(p.id)));
    }
    // Merge user-created albums from DB.
    for (final a in dbAlbums.where((a) => a.isUserCreated)) {
      albums.add(a);
    }
    state = state.copyWith(albums: albums, loading: false);
  }

  Future<void> createAlbum(String name) async {
    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final album = Album(
      id: id,
      name: name,
      path: '',
      coverId: null,
      count: 0,
      isUserCreated: true,
    );
    await AlbumDataSource.instance.upsert(album);
    await load();
  }

  Future<void> rename(String id, String name) async {
    await AlbumDataSource.instance.rename(id, name);
    await load();
  }

  Future<void> toggleHidden(Album a) async {
    await AlbumDataSource.instance.setHidden(a.id, !a.isHidden);
    await load();
  }

  Future<void> delete(String id) async {
    await AlbumDataSource.instance.delete(id);
    await load();
  }
}

class AlbumsState {
  const AlbumsState({this.albums = const [], this.loading = false});
  final List<Album> albums;
  final bool loading;
  AlbumsState copyWith({List<Album>? albums, bool? loading}) =>
      AlbumsState(albums: albums ?? this.albums, loading: loading ?? this.loading);
}

final albumsControllerProvider =
    NotifierProvider<AlbumsController, AlbumsState>(AlbumsController.new);

/// Media items for a specific album (by album id).
final albumMediaProvider =
    FutureProvider.family<List<MediaItem>, String>((ref, albumId) async {
  return MediaDataSource.instance.query(
    where: 'album_id = ? AND trashed_at IS NULL AND is_hidden = 0',
    whereArgs: [albumId],
    orderBy: 'created_at DESC',
  );
});
