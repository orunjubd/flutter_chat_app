// lib/features/people/providers/people_search_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/chat/data/models/app_user.dart';
import 'package:chat_app/features/peoples/providers/peoples_provider.dart';

class PeopleSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
  }

  void clear() {
    state = '';
  }
}

final peopleSearchTextProvider =
    NotifierProvider.autoDispose<PeopleSearchNotifier, String>(
      PeopleSearchNotifier.new,
    );

/// Same filter logic as UserSelectionScreen
/// (username OR email contains, case-insensitive).
///
/// Kept deliberately identical so search behaves
/// the same in both places.
final filteredPeopleProvider = Provider<AsyncValue<List<AppUser>>>((ref) {
  final usersAsync = ref.watch(peoplesProvider);
  final query = ref.watch(peopleSearchTextProvider).trim().toLowerCase();

  return usersAsync.whenData((users) {
    if (query.isEmpty) {
      return users;
    }

    return users
        .where(
          (user) =>
              user.username.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query),
        )
        .toList();
  });
});
