import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/media_data_source.dart';
import '../../../data/models/media_item.dart';
import '../models/ai_result.dart';
import '../services/ai_provider.dart';

class AiSearchController extends Notifier<AiSearchState> {
  late final AIProvider _provider;

  @override
  AiSearchState build() {
    _provider = LocalAIProvider();
    return const AiSearchState();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AiSearchState();
      return;
    }
    state = state.copyWith(query: query, loading: true);
    try {
      final candidates = await MediaDataSource.instance.query(
        where: 'trashed_at IS NULL AND is_hidden = 0',
        orderBy: 'created_at DESC',
        limit: 1000,
      );
      final results = await _provider.search(query, candidates);
      state = state.copyWith(results: results, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: '$e');
    }
  }
}

class AiSearchState {
  const AiSearchState({
    this.query = '',
    this.results = const [],
    this.loading = false,
    this.error,
  });
  final String query;
  final List<AiResult> results;
  final bool loading;
  final String? error;
  AiSearchState copyWith({
    String? query,
    List<AiResult>? results,
    bool? loading,
    String? error,
  }) =>
      AiSearchState(
        query: query ?? this.query,
        results: results ?? this.results,
        loading: loading ?? this.loading,
        error: error ?? this.error,
      );
}

final aiSearchControllerProvider =
    NotifierProvider<AiSearchController, AiSearchState>(AiSearchController.new);

/// Quick suggestions shown as chips above the search bar.
final aiSuggestionProvider = Provider<List<String>>((_) => const [
      'cars',
      'sea',
      'cats',
      'food',
      'people',
    ]);
