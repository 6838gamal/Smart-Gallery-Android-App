import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';

/// Singleton SQLite wrapper. Stores metadata only — never blobs.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final docs = await getApplicationDocumentsDirectory();
    final path = p.join(docs.path, AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int v) async {
    await db.execute('''
      CREATE TABLE media (
        id TEXT PRIMARY KEY,
        path TEXT NOT NULL,
        display_name TEXT NOT NULL,
        album_id TEXT NOT NULL,
        album_name TEXT NOT NULL,
        type TEXT NOT NULL,
        size_bytes INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        modified_at INTEGER NOT NULL,
        duration_ms INTEGER NOT NULL DEFAULT 0,
        width INTEGER,
        height INTEGER,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        is_hidden INTEGER NOT NULL DEFAULT 0,
        trashed_at INTEGER,
        ai_tags TEXT,
        last_seen_scan INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX idx_media_album ON media(album_id)');
    await db.execute('CREATE INDEX idx_media_created ON media(created_at)');
    await db.execute('CREATE INDEX idx_media_trashed ON media(trashed_at)');

    await db.execute('''
      CREATE TABLE albums (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        path TEXT NOT NULL,
        is_user_created INTEGER NOT NULL DEFAULT 0,
        is_hidden INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE scan_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    // Future migrations go here. v1 is the initial schema.
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
