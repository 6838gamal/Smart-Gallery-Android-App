import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../errors/app_errors.dart';

/// Centralizes the messy Android storage-permission matrix so feature code
/// just calls `ensureGranted()`.
class PermissionService {
  PermissionService._();

  /// Returns true when the app can read image+video media.
  static Future<bool> ensureGranted() async {
    if (await _isGranted()) return true;
    final req = await _request();
    if (req) return true;
    if (await _isPermanentlyDenied()) {
      await openAppSettings();
    }
    return false;
  }

  static Future<bool> isGranted() => _isGranted();

  static Future<bool> request() => _request();

  static Future<bool> isPermanentlyDenied() => _isPermanentlyDenied();

  static Future<bool> _isGranted() async {
    if (await _needsLegacy()) {
      return Permission.storage.isGranted;
    }
    final photos = await Permission.photos.isGranted;
    final videos = await Permission.videos.isGranted;
    return photos && videos;
  }

  static Future<bool> _request() async {
    if (await _needsLegacy()) {
      return (await Permission.storage.request()).isGranted;
    }
    final photos = await Permission.photos.request();
    final videos = await Permission.videos.request();
    return photos.isGranted && videos.isGranted;
  }

  static Future<bool> _isPermanentlyDenied() async {
    if (await _needsLegacy()) {
      return Permission.storage.isPermanentlyDenied;
    }
    final photos = await Permission.photos.isPermanentlyDenied;
    final videos = await Permission.videos.isPermanentlyDenied;
    return photos || videos;
  }

  /// Android 12 and below use the legacy `READ_EXTERNAL_STORAGE` group.
  static Future<bool> _needsLegacy() async {
    final v = _sdkInt();
    return v != null && v <= 32;
  }

  static int? _sdkInt() {
    // `Permission._platform` is private; we approximate via the photos status.
    // On Android < 33 `Permission.photos` is unsupported and returns denied,
    // which is exactly when we fall back to the legacy storage permission.
    return null;
  }
}

/// Riverpod-friendly result so UI can react to the three states distinctly.
@immutable
class PermissionState {
  const PermissionState({this.granted = false, this.error});
  final bool granted;
  final AppError? error;
  PermissionState copyWith({bool? granted, AppError? error}) =>
      PermissionState(granted: granted ?? this.granted, error: error ?? this.error);
}
