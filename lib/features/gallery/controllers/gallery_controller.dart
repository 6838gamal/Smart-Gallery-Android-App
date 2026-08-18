import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/media_data_source.dart';
import '../../../data/models/media_item.dart';
import '../providers/sort_provider.dart';

/// Paginated gallery list. Loads [AppConstants.pageLimit] rows at a time,
/// excluding trashed and hidden items.
class GalleryController extends Notifier<GalleryState> {
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;

  @override
  GalleryState build() {
    ref.listen<SortState>(sortProvider, (previous, next) {
  _reset();
});
    // Initial load happens lazily on first read.
    Future.microtask(loadFirst);
    return const GalleryState();
  }

  Future<void> _reset() async {
    _page = 0;
    _hasMore = true;
    state = const GalleryState();
    await loadFirst();
  }

  Future<void> loadFirst() async {
    if (_loading) return;
    _loading = true;
    state = state.copyWith(isRefreshing: true);
    final sort = ref.read(sortProvider);
    final items = await MediaDataSource.instance.query(
      where: 'trashed_at IS NULL AND is_hidden = 0',
      orderBy: sort.sqlOrder,
      limit: 60,
      offset: 0,
    );
    _page = 1;
    _hasMore = items.length >= 60;
    _loading = false;
    state = state.copyWith(items: items, isRefreshing: false);
  }

  Future<void> loadMore() async {
    if (_loading || !_hasMore) return;
    _loading = true;
    final sort = ref.read(sortProvider);
    final items = await MediaDataSource.instance.query(
      where: 'trashed_at IS NULL AND is_hidden = 0',
      orderBy: sort.sqlOrder,
      limit: 60,
      offset: _page * 60,
    );
    _page++;
    _hasMore = items.length >= 60;
    _loading = false;
    state = state.copyWith(items: [...state.items, ...items]);
  }

  bool get hasMore => _hasMore;
}

class GalleryState {
  const GalleryState({this.items = const [], this.isRefreshing = false});
  final List<MediaItem> items;
  final bool isRefreshing;
  GalleryState copyWith({List<MediaItem>? items, bool? isRefreshing}) =>
      GalleryState(items: items ?? this.items, isRefreshing: isRefreshing ?? this.isRefreshing);
}

final galleryControllerProvider =
    NotifierProvider<GalleryController, GalleryState>(GalleryController.new);
