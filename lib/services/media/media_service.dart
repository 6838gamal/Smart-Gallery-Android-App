import 'dart:io';
import 'dart:typed_data';
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

  // ✅ إصلاح: إزالة asset.albumId واستخدام طريقة بديلة
  Future<MediaItem> toMediaItem(AssetEntity asset) async {
    // ✅ الحصول على albumId من خلال البحث في الألبومات
    final albumId = await _getAlbumIdForAsset(asset);
    final albumName = await _getAlbumNameForAsset(asset);
    return MediaItem.fromAsset(asset, albumName);
  }

  // ✅ إضافة دالة مساعدة للحصول على albumId
  Future<String?> _getAlbumIdForAsset(AssetEntity asset) async {
    try {
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
      );
      for (var album in albums) {
        final assets = await album.getAssetListPaged(page: 0, size: 50);
        if (assets.any((a) => a.id == asset.id)) {
          return album.id;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ✅ إضافة دالة مساعدة للحصول على albumName
  Future<String> _getAlbumNameForAsset(AssetEntity asset) async {
    try {
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
      );
      for (var album in albums) {
        final assets = await album.getAssetListPaged(page: 0, size: 50);
        if (assets.any((a) => a.id == asset.id)) {
          return album.name;
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  // ✅ إصلاح: تنفيذ دالة thumbnailFile بشكل صحيح
  Future<File?> thumbnailFile(AssetEntity asset) async {
    try {
      final data = await asset.thumbnailDataWithSize(
        const ThumbnailSize.square(256),
      );
      if (data == null) return null;
      
      // حفظ البيانات في ملف مؤقت
      final tempDir = await Directory.systemTemp.createTemp('thumbnails');
      final file = File('${tempDir.path}/${asset.id}.jpg');
      await file.writeAsBytes(data);
      return file;
    } catch (e) {
      return null;
    }
  }

  // ✅ إضافة دالة للحصول على thumbnail كـ Uint8List
  Future<Uint8List?> thumbnailBytes(AssetEntity asset) async {
    try {
      return await asset.thumbnailDataWithSize(
        const ThumbnailSize.square(256),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteAssets(List<String> ids) async {
    final assets = await Future.wait(
      ids.map((id) => AssetEntity.fromId(id)),
    );
    await PhotoManager.editor.deleteWithIds(
      assets.whereType<AssetEntity>().map((a) => a.id).toList(),
    );
  }

  Future<AssetEntity?> assetById(String id) async {
    try {
      return await AssetEntity.fromId(id);
    } catch (_) {
      return null;
    }
  }

  // ✅ إضافة دالة للحصول على مسار الملف
  Future<String?> getAssetPath(AssetEntity asset) async {
    try {
      final file = await asset.file;
      return file?.path;
    } catch (e) {
      return null;
    }
  }

  // ✅ إضافة دالة للحصول على الملف
  Future<File?> getAssetFile(AssetEntity asset) async {
    try {
      return await asset.file;
    } catch (e) {
      return null;
    }
  }
}
