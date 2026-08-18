import 'package:photo_manager/photo_manager.dart';

/// A device folder/album or a user-created album.
class Album {
  Album({
    required this.id,
    required this.name,
    required this.path,
    this.coverId,
    required this.count,
    this.isUserCreated = false,
    this.isHidden = false,
  });

  final String id;
  final String name;
  final String path;
  final String? coverId;
  final int count;
  final bool isUserCreated;
  final bool isHidden;

  Album copyWith({
    String? name,
    bool? isHidden,
    int? count,
    String? coverId,
  }) =>
      Album(
        id: id,
        name: name ?? this.name,
        path: path,
        coverId: coverId ?? this.coverId,
        count: count ?? this.count,
        isUserCreated: isUserCreated,
        isHidden: isHidden ?? this.isHidden,
      );

  // ✅ التصحيح: استخدام الخصائص المتاحة في AssetPathEntity
  factory Album.fromPathEntity(AssetPathEntity p) {
    return Album(
      id: p.id,
      name: p.name,
      path: p.name, // ✅ استخدم p.name بدلاً من p.path (غير موجود)
      coverId: null,
      count: 0, // ✅ استخدم 0 مؤقتاً (p.assetCount غير موجود في 3.x)
      isUserCreated: false,
    );
  }

  // ✅ إضافة مُنشئ للحصول على count بشكل صحيح (غير متزامن)
  static Future<Album> fromPathEntityAsync(AssetPathEntity p) async {
    final count = await p.assetCountAsync; // ✅ الطريقة الصحيحة للحصول على count
    return Album(
      id: p.id,
      name: p.name,
      path: p.name,
      coverId: null,
      count: count,
      isUserCreated: false,
    );
  }

  Map<String, Object?> toDbRow() => {
        'id': id,
        'name': name,
        'path': path,
        'is_user_created': isUserCreated ? 1 : 0,
        'is_hidden': isHidden ? 1 : 0,
      };
}
