import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/album.dart';

class AlbumDataSource {
  AlbumDataSource._();
  static final AlbumDataSource instance = AlbumDataSource._();

  Future<Database> get _db => AppDatabase.instance.database;

  Future<void> upsert(Album a) async {
    final db = await _db;
    await db.insert('albums', a.toDbRow(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> rename(String id, String name) async {
    final db = await _db;
    await db.update('albums', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setHidden(String id, bool hidden) async {
    final db = await _db;
    await db.update('albums', {'is_hidden': hidden ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('albums', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Album>> all({bool includeHidden = false}) async {
    final db = await _db;
    final where = includeHidden ? null : 'is_hidden = 0';
    final rows = await db.query('albums', where: where);
    return rows
        .map((r) => Album(
              id: r['id'] as String,
              name: r['name'] as String,
              path: r['path'] as String,
              coverId: null,
              count: 0,
              isUserCreated: (r['is_user_created'] as int) == 1,
              isHidden: (r['is_hidden'] as int) == 1,
            ))
        .toList();
  }
}
