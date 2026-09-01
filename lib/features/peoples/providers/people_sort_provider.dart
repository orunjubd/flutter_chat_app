// lib/features/peoples/providers/people_sort_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/peoples/data/models/people_sort_option.dart';
import 'package:chat_app/features/peoples/providers/people_search_provider.dart';
import 'package:chat_app/features/chat/data/models/app_user.dart';

class PeopleSortNotifier extends Notifier<PeopleSortOption> {
  @override
  PeopleSortOption build() => PeopleSortOption.nameAsc;
  void setOption(PeopleSortOption option) => state = option;
}

final peopleSortOptionProvider =
    NotifierProvider.autoDispose<PeopleSortNotifier, PeopleSortOption>(
      PeopleSortNotifier.new,
    );

/// Layers sorting on top of the already-filtered (searched) list —
/// filteredPeopleProvider's search logic is unchanged; this only
/// reorders its output.
final sortedPeopleProvider = Provider<AsyncValue<List<AppUser>>>((ref) {
  final filteredAsync = ref.watch(filteredPeopleProvider);
  final sortOption = ref.watch(peopleSortOptionProvider);

  return filteredAsync.whenData((users) {
    final sorted = [...users];
    debugPrint('📦 [ECE-Sorter] Incoming raw list length: ${users.length}');
    switch (sortOption) {
      case PeopleSortOption.nameAsc:
        sorted.sort(
          (a, b) =>
              a.username.toLowerCase().compareTo(b.username.toLowerCase()),
        );
        break;
      case PeopleSortOption.nameDesc:
        sorted.sort(
          (a, b) =>
              b.username.toLowerCase().compareTo(a.username.toLowerCase()),
        );
        break;
      case PeopleSortOption.onlineFirst:
        sorted.sort((a, b) {
          if (a.isOnline == b.isOnline) {
            return a.username.toLowerCase().compareTo(b.username.toLowerCase());
          }
          return a.isOnline ? -1 : 1;
        });
        break;
    }

    // Log the order of usernames to verify the sort mathematically
    final orderDiagnostic = sorted
        .map((u) => '${u.username}(Online:${u.isOnline})')
        .join(' -> ');
    debugPrint('🏆 [ECE-Sorter] Resulting Array Order: $orderDiagnostic');

    return sorted;
  });
});
