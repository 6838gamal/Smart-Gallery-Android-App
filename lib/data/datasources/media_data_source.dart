import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../models/media_item.dart';

/// CRUD for the `media` table. App-only flags (favorite, hidden, trash) are
/// upserted separately so a rescan never overwrites user state.
class MediaDataSource {
  MediaDataSource._();
  static final MediaDataSource instance = MediaDataSource._();

  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath;
    
    if (kIsWeb) {
      // ✅ على الويب: استخدم مساراً مؤقتاً (يعمل على المتصفح)
      // يمكنك استخدام أي مسار، sqflite سيتعامل معه كقاعدة بيانات في الذاكرة
      dbPath = 'smart_gallery.db';
    } else {
      // ✅ على الأجهزة المحمولة: استخدم مسار المستندات
      final directory = await getApplicationDocumentsDirectory();
      dbPath = join(directory.path, 'media.db');
    }
    
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        return _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE media(
        id TEXT PRIMARY KEY,
        path TEXT,
        display_name TEXT,
        album_id TEXT,
        album_name TEXT,
        type TEXT,
        size_bytes INTEGER,
        created_at INTEGER,
        modified_at INTEGER,
        duration_ms INTEGER,
        width INTEGER,
        height INTEGER,
        is_favorite INTEGER DEFAULT 0,
        is_hidden INTEGER DEFAULT 0,
        trashed_at INTEGER,
        ai_tags TEXT,
        last_seen_scan INTEGER
      )
    ''');
  }

  /// Upserts scan-derived columns, preserving favorite/hidden/trash/ai_tags.
  Future<void> upsertScanRow(MediaItem m, int scanVersion) async {
    final db = await _db;
    await db.insert(
      'media',
      {
        ...m.toDbRow(),
        'last_seen_scan': scanVersion,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    // Update mutable scan columns for existing rows without touching flags.
    await db.update(
      'media',
      {
        'path': m.path,
        'display_name': m.displayName,
        'album_id': m.albumId,
        'album_name': m.albumName,
        'type': m.type.name,
        'size_bytes': m.sizeBytes,
        'created_at': m.createdAt.millisecondsSinceEpoch,
        'modified_at': m.modifiedAt.millisecondsSinceEpoch,
        'duration_ms': m.duration.inMilliseconds,
        'width': m.width,
        'height': m.height,
        'last_seen_scan': scanVersion,
      },
      where: 'id = ?',
      whereArgs: [m.id],
    );
  }

  /// Marks rows not seen in the latest scan as deleted (incremental sync).
  Future<int> markMissingAsTrashed(int scanVersion) async {
    final db = await _db;
    return db.update(
      'media',
      {'trashed_at': DateTime.now().millisecondsSinceEpoch},
      where: 'last_seen_scan < ? AND trashed_at IS NULL',
      whereArgs: [scanVersion],
    );
  }

  Future<void> setFavorite(String id, bool favorite) async {
    final db = await _db;
    await db.update('media', {'is_favorite': favorite ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setHidden(String id, bool hidden) async {
    final db = await _db;
    await db.update('media', {'is_hidden': hidden ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> moveToTrash(String id) async {
    final db = await _db;
    await db.update('media', {'trashed_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> restoreFromTrash(String id) async {
    final db = await _db;
    await db.update('media', {'trashed_at': null}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deletePermanently(String id) async {
    final db = await _db;
    await db.delete('media', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setAiTags(String id, List<String> tags) async {
    final db = await _db;
    await db.update('media', {'ai_tags': tags.join(',')},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<MediaItem?> getById(String id) async {
    final db = await _db;
    final rows = await db.query('media', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _rowToItem(rows.first);
  }

  Future<List<MediaItem>> query({
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'media',
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return rows.map(_rowToItem).toList();
  }

  Future<int> count({String? where, List<Object?>? whereArgs}) async {
    final db = await _db;
    final r = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM media${where == null ? '' : ' WHERE $where'}',
      whereArgs,
    );
    return r.first['c'] as int? ?? 0;
  }

  MediaItem _rowToItem(Map<String, Object?> r) {
    return MediaItem(
      id: r['id'] as String,
      path: r['path'] as String,
      displayName: r['display_name'] as String,
      albumId: r['album_id'] as String,
      albumName: r['album_name'] as String,
      type: MediaType.values.byName(r['type'] as String),
      sizeBytes: r['size_bytes'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(r['modified_at'] as int),
      duration: Duration(milliseconds: (r['duration_ms'] as int?) ?? 0),
      width: r['width'] as int?,
      height: r['height'] as int?,
      isFavorite: (r['is_favorite'] as int) == 1,
      isHidden: (r['is_hidden'] as int) == 1,
      trashedAt: r['trashed_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(r['trashed_at'] as int),
      aiTags: ((r['ai_tags'] as String?) ?? '').split(',').where((s) => s.isNotEmpty).toList(),
    );
  }
}
