import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../core/constants/app_constants.dart';

/// On-disk thumbnail cache keyed by asset id. Avoids re-decoding full images.
class ThumbnailService {
  ThumbnailService._();
  static final ThumbnailService instance = ThumbnailService._();

  Directory? _cacheDir;

  Future<Directory> get _dir async {
    if (_cacheDir != null) return _cacheDir!;
    final tmp = await getTemporaryDirectory();
    final d = Directory(p.join(tmp.path, AppConstants.thumbDir));
    if (!d.existsSync()) d.createSync(recursive: true);
    _cacheDir = d;
    return d;
  }

  Future<File> _path(String id) async {
    final dir = await _dir;
    return File(p.join(dir.path, '$id.jpg'));
  }

  /// Returns a cached file if present, otherwise generates and stores one.
  Future<File?> get(AssetEntity asset) async {
    final file = await _path(asset.id);
    if (file.existsSync()) return file;
    final bytes = await asset.thumbnailDataWithSize(
      const ThumbnailSize.square(AppConstants.thumbSize),
    );
    if (bytes == null) return null;
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Builds a cached `ImageProvider` for the asset.
  Future<ImageProvider?> provider(AssetEntity asset) async {
    final file = await get(asset);
    return file == null ? null : FileImage(file);
  }

  Future<void> clear() async {
    final dir = await _dir;
    if (dir.existsSync()) await dir.delete(recursive: true);
  }
}
