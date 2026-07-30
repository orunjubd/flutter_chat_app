import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchProvider = NotifierProvider<SearchNotifier, String>(
  SearchNotifier.new,
);

class SearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) {
    state = value;
  }

  void clear() {
    state = '';
  }

  bool get hasQuery => state.trim().isNotEmpty;
}
