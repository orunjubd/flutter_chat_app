// lib/features/peoples/presentation/screens/peoples_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/peoples/presentation/widgets/peoples_header.dart';
import 'package:chat_app/features/peoples/presentation/widgets/peoples_section_title.dart';
import 'package:chat_app/features/peoples/providers/people_search_provider.dart';
import 'package:chat_app/features/peoples/presentation/widgets/app_user_tile.dart';

class PeoplesScreen extends ConsumerWidget {
  const PeoplesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(filteredPeopleProvider);

    return Scaffold(
      appBar: const PeoplesHeader(),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Unable to load contacts: $e')),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No other users yet.'));
          }
          return ListView(
            children: [
              const PeoplesSectionTitle(title: 'App Users'),
              ...users.map((u) => AppUserTile(user: u)),
            ],
          );
        },
      ),
    );
  }
}
