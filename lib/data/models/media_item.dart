import 'dart:ui';
import 'package:photo_manager/photo_manager.dart';

/// Media type classification.
enum MediaType { image, video, unknown }

/// A single media item as seen by the gallery.
///
/// `id` is the MediaStore id (stable across rescans). App-specific flags
/// (`isFavorite`, `isHidden`, `trashedAt`) live in the local database and are
/// merged in by the repository.
class MediaItem {
  MediaItem({
    required this.id,
    required this.path,
    required this.displayName,
    required this.albumId,
    required this.albumName,
    required this.type,
    required this.sizeBytes,
    required this.createdAt,
    required this.modifiedAt,
    this.duration = Duration.zero,
    this.width,
    this.height,
    this.isFavorite = false,
    this.isHidden = false,
    this.trashedAt,
    this.aiTags = const [],
  });

  final String id;
  final String path;
  final String displayName;
  final String albumId;
  final String albumName;
  final MediaType type;
  final int sizeBytes;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final Duration duration;
  final int? width;
  final int? height;
  final bool isFavorite;
  final bool isHidden;
  final DateTime? trashedAt;
  final List<String> aiTags;

  bool get isVideo => type == MediaType.video;
  bool get isTrashed => trashedAt != null;

  MediaItem copyWith({
    bool? isFavorite,
    bool? isHidden,
    DateTime? trashedAt,
    List<String>? aiTags,
  }) =>
      MediaItem(
        id: id,
        path: path,
        displayName: displayName,
        albumId: albumId,
        albumName: albumName,
        type: type,
        sizeBytes: sizeBytes,
        createdAt: createdAt,
        modifiedAt: modifiedAt,
        duration: duration,
        width: width,
        height: height,
        isFavorite: isFavorite ?? this.isFavorite,
        isHidden: isHidden ?? this.isHidden,
        trashedAt: trashedAt ?? this.trashedAt,
        aiTags: aiTags ?? this.aiTags,
      );

  factory MediaItem.fromAsset(AssetEntity asset, String albumName) {
    return MediaItem(
      id: asset.id,
      path: asset.relativePath ?? '',
      displayName: asset.title ?? asset.id,
      albumId: '',
      albumName: albumName,
      type: _mapType(asset.type),
      sizeBytes: asset.size is Size ? (asset.size as Size).width.toInt() : 0,
      createdAt: asset.createDateTime,
      modifiedAt: asset.modifiedDateTime,
      duration: asset.videoDuration ?? Duration.zero,
      width: asset.width,
      height: asset.height,
    );
  }

  factory MediaItem.fromAssetEntity(AssetEntity asset) {
    return MediaItem(
      id: asset.id,
      path: asset.relativePath ?? '',
      displayName: asset.title ?? asset.id,
      albumId: '',
      albumName: '',
      type: _mapType(asset.type),
      sizeBytes: asset.size is Size ? (asset.size as Size).width.toInt() : 0,
      createdAt: asset.createDateTime,
      modifiedAt: asset.modifiedDateTime,
      duration: asset.videoDuration ?? Duration.zero,
      width: asset.width,
      height: asset.height,
    );
  }

  static MediaType _mapType(AssetType t) => switch (t) {
        AssetType.image => MediaType.image,
        AssetType.video => MediaType.video,
        _ => MediaType.unknown,
      };

  Map<String, Object?> toDbRow() => {
        'id': id,
        'path': path,
        'display_name': displayName,
        'album_id': albumId,
        'album_name': albumName,
        'type': type.name,
        'size_bytes': sizeBytes,
        'created_at': createdAt.millisecondsSinceEpoch,
        'modified_at': modifiedAt.millisecondsSinceEpoch,
        'duration_ms': duration.inMilliseconds,
        'width': width,
        'height': height,
        'is_favorite': isFavorite ? 1 : 0,
        'is_hidden': isHidden ? 1 : 0,
        'trashed_at': trashedAt?.millisecondsSinceEpoch,
        'ai_tags': aiTags.join(','),
      };
}
