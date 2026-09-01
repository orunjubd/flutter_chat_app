// lib/features/peoples/presentation/widgets/people_sort_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/peoples/data/models/people_sort_option.dart';
import 'package:chat_app/features/peoples/providers/people_sort_provider.dart';

class PeopleSortButton extends ConsumerWidget {
  const PeopleSortButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(peopleSortOptionProvider);

    return PopupMenuButton<PeopleSortOption>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sort',
      initialValue: selected,
      onSelected: (option) =>
          ref.read(peopleSortOptionProvider.notifier).setOption(option),
      itemBuilder: (context) => PeopleSortOption.values.map((option) {
        return PopupMenuItem(
          value: option,
          child: Row(
            children: [
              Icon(option == selected ? Icons.check : null, size: 18),
              const SizedBox(width: 8),
              Text(option.label),
            ],
          ),
        );
      }).toList(),
    );
  }
}
