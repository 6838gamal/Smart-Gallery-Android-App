abstract class AppConstants {
  AppConstants._();

  static const String appName = 'Smart Gallery';
  static const int dbVersion = 1;
  static const String dbName = 'smart_gallery.db';

  /// Thumbnail cache subdirectory under the app's cache dir.
  static const String thumbDir = 'thumbnails';

  /// Maximum thumbnail dimension in pixels.
  static const int thumbSize = 256;

  /// Page size used by lazy-loading grids.
  static const int pageLimit = 60;

  /// Batch size when scanning MediaStore to avoid UI jank.
  static const int scanBatch = 200;
}
