/// Sort dimensions supported by the gallery and search.
enum SortField { name, date, size, type, album }

extension SortFieldX on SortField {
  /// SQL ORDER BY fragment for the media table.
  String get sqlColumn => switch (this) {
        SortField.name => 'display_name',
        SortField.date => 'created_at',
        SortField.size => 'size_bytes',
        SortField.type => 'type',
        SortField.album => 'album_name',
      };
}
