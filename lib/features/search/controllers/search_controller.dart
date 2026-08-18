import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/media_data_source.dart';
import '../../../data/models/media_item.dart';
import '../../gallery/models/sort_field.dart';
import '../../gallery/providers/sort_provider.dart';

/// Traditional keyword search over the local DB (name/album/type).
class SearchController extends Notifier<SearchState> {
  @override
  SearchState build() => const SearchState();

  void setQuery(String q) async {
    state = state.copyWith(query: q, loading: true);
    final sort = ref.read(sortProvider);
    final where = q.isEmpty
        ? 'trashed_at IS NULL AND is_hidden = 0'
        : 'trashed_at IS NULL AND is_hidden = 0 AND (display_name LIKE ? OR album_name LIKE ?)';
    final args = q.isEmpty ? null : ['%$q%', '%$q%'];
    final results = await MediaDataSource.instance.query(
      where: where,
      whereArgs: args,
      orderBy: sort.sqlOrder,
      limit: 200,
    );
    state = state.copyWith(results: results, loading: false);
  }
}

class SearchState {
  const SearchState({this.query = '', this.results = const [], this.loading = false});
  final String query;
  final List<MediaItem> results;
  final bool loading;
  SearchState copyWith({String? query, List<MediaItem>? results, bool? loading}) =>
      SearchState(
        query: query ?? this.query,
        results: results ?? this.results,
        loading: loading ?? this.loading,
      );
}

final searchControllerProvider =
    NotifierProvider<SearchController, SearchState>(SearchController.new);
