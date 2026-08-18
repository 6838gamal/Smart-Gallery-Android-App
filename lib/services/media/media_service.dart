import 'package:photo_manager/photo_manager.dart';

import '../../data/models/album.dart';
import '../../data/models/media_item.dart';

/// Wraps `photo_manager` so feature code never imports the plugin directly.
class MediaService {
  MediaService._();
  static final MediaService instance = MediaService._();

  Future<bool> requestPermission() =>
      PhotoManager.requestPermissionExtend().then((s) => s.isAuth);

  Future<List<AssetPathEntity>> getAlbums({bool all = false}) async {
    return PhotoManager.getAssetPathList(
      type: RequestType.common,
      onlyAll: all,
      hasAll: true,
    );
  }

  Future<List<AssetEntity>> getAssetsForAlbum(
    String albumId, {
    int page = 0,
    int limit = 60,
  }) async {
    final album = await AssetPathEntity.fromId(albumId);
    return album.getAssetListPaged(page: page, size: limit);
  }

  Future<List<AssetEntity>> getAllAssets({
    int page = 0,
    int limit = 60,
  }) async {
    final list = await getAlbums(all: true);
    if (list.isEmpty) return [];
    return list.first.getAssetListPaged(page: page, size: limit);
  }

  Future<MediaItem> toMediaItem(AssetEntity asset) async {
    final album = asset.albumId == null
        ? null
        : await AssetPathEntity.fromId(asset.albumId!);
    return MediaItem.fromAsset(asset, album?.name ?? '');
  }

  Future<void> deleteAssets(List<String> ids) async {
    final assets = await Future.wait(ids.map((id) => AssetEntity.fromId(id)));
    await PhotoManager.editor.deleteWithIds(assets.whereType<AssetEntity>().map((a) => a.id).toList());
  }

  Future<AssetEntity?> assetById(String id) async {
    try {
      return await AssetEntity.fromId(id);
    } catch (_) {
      return null;
    }
  }

  Future<File?> thumbnailFile(AssetEntity asset) => asset.thumbnailDataWithSize(const ThumbnailSize.square(256)).then((d) => d == null ? null : null);
}
