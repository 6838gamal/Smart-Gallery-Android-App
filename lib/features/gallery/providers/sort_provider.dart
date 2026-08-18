import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sort_field.dart';

/// Sort preferences shared by gallery, search, albums, favorites.
class SortState {
  const SortState({this.field = SortField.date, this.ascending = false});
  final SortField field;
  final bool ascending;

  String get sqlOrder => '${field.sqlColumn} ${ascending ? 'ASC' : 'DESC'}';
  SortState copyWith({SortField? field, bool? ascending}) =>
      SortState(field: field ?? this.field, ascending: ascending ?? this.ascending);
}

class SortNotifier extends Notifier<SortState> {
  @override
  SortState build() => const SortState();

  void setField(SortField f) => state = state.copyWith(field: f);
  void toggleDirection() => state = state.copyWith(ascending: !state.ascending);
}

final sortProvider =
    NotifierProvider<SortNotifier, SortState>(SortNotifier.new);
