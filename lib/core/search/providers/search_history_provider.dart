import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/search/repositories/search_history_repository.dart';

final searchHistoryRepositoryProvider = Provider<SearchHistoryRepository>((
  ref,
) {
  return SearchHistoryRepository();
});

final searchHistoryProvider =
    AsyncNotifierProvider<SearchHistoryNotifier, List<String>>(
      SearchHistoryNotifier.new,
    );

class SearchHistoryNotifier extends AsyncNotifier<List<String>> {
  static const int _maxItems = 20;

  late final SearchHistoryRepository _repository;

  @override
  Future<List<String>> build() async {
    _repository = ref.read(searchHistoryRepositoryProvider);

    return _repository.load();
  }

  /// Adds a new search query.
  Future<void> add(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) return;

    final history = [...(state.value ?? <String>[])];

    // Remove duplicate (case-insensitive)
    history.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());

    // Newest first
    history.insert(0, trimmed);

    // Limit history size
    if (history.length > _maxItems) {
      history.removeRange(_maxItems, history.length);
    }

    await _repository.save(history);
    debugPrint('Search history: $history');

    state = AsyncData(history);
  }

  /// Remove a single search.
  Future<void> remove(String query) async {
    final history = [...(state.value ?? <String>[])];

    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());

    await _repository.save(history);

    state = AsyncData(history);
  }

  /// Clear all history.
  Future<void> clear() async {
    await _repository.clear();

    state = AsyncData(<String>[]);
  }
}
