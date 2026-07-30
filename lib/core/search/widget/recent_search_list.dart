import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_history_provider.dart';

class RecentSearchList extends ConsumerWidget {
  const RecentSearchList({super.key, required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(searchHistoryProvider);

    return historyAsync.when(
      loading: () => const SizedBox.shrink(),

      error: (_, _) => const SizedBox.shrink(),

      data: (history) {
        if (history.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'No Recent Searches',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Search messages to quickly find past conversations.\n'
                    'Your recent searches will appear here.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 6),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  TextButton.icon(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Clear'),

                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text('Clear search history'),
                            content: const Text('Remove all recent searches?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text('Cancel'),
                              ),

                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text('Clear'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        await ref.read(searchHistoryProvider.notifier).clear();
                      }
                    },
                  ),
                ],
              ),
            ),

            ...history.map(
              (query) => ListTile(
                leading: const Icon(Icons.history),

                title: Text(query),

                trailing: IconButton(
                  icon: const Icon(Icons.close),

                  onPressed: () {
                    ref.read(searchHistoryProvider.notifier).remove(query);
                  },
                ),

                onTap: () {
                  onSelected(query);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
