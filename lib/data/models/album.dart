import 'package:photo_manager/photo_manager.dart';

/// A device folder/album or a user-created album.
class Album {
  Album({
    required this.id,
    required this.name,
    required this.path,
    required this.coverId,
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

  Album copyWith({String? name, bool? isHidden, int? count, String? coverId}) =>
      Album(
        id: id,
        name: name ?? this.name,
        path: path,
        coverId: coverId ?? this.coverId,
        count: count ?? this.count,
        isUserCreated: isUserCreated,
        isHidden: isHidden ?? this.isHidden,
      );

  factory Album.fromPathEntity(PathEntity p) {
    return Album(
      id: p.id,
      name: p.name,
      path: p.path ?? '',
      coverId: null,
      count: p.assetCount,
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
