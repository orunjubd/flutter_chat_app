// lib/features/peoples/presentation/widgets/people_search_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/peoples/providers/people_search_provider.dart';

class PeopleSearchField extends ConsumerStatefulWidget {
  const PeopleSearchField({super.key});

  @override
  ConsumerState<PeopleSearchField> createState() => _PeopleSearchFieldState();
}

class _PeopleSearchFieldState extends ConsumerState<PeopleSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Safely parse initial parameters from our modern Notifier block [INDEX]
    final initialQuery = ref.read(peopleSearchTextProvider);
    _controller = TextEditingController(text: initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch current state to dynamically show/hide the clear action shield [INDEX]
    final query = ref.watch(peopleSearchTextProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          // 🚀 FIXED: Invoking your encapsulated business logic updater securely! [INDEX]
          ref.read(peopleSearchTextProvider.notifier).setQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'Search people...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _controller.clear();
                    // 🚀 FIXED: Calling the formal clear action circuit-breaker! [INDEX]
                    ref.read(peopleSearchTextProvider.notifier).clear();
                  },
                )
              : null,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
