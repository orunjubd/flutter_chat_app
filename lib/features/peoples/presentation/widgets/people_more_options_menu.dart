// lib/features/peoples/presentation/widgets/people_more_options_menu.dart
import 'package:flutter/material.dart';

enum PeopleMoreOption { newGroup, newCommunity }

/// Both items are stubs until their owning phase exists:
/// - New Group    → Phase 6 (Group Chat) — not started
/// - New Community → future, beyond Phase 6
///
/// When Phase 6 begins, swap _handleSelection's newGroup case for a
/// real Navigator.push to Phase 6's entry screen. Nothing else here
/// needs to change.
class PeopleMoreOptionsMenu extends StatelessWidget {
  const PeopleMoreOptionsMenu({super.key});

  void _handleSelection(BuildContext context, PeopleMoreOption option) {
    final message = switch (option) {
      PeopleMoreOption.newGroup => 'Group chat is coming soon.',
      PeopleMoreOption.newCommunity => 'Communities are coming soon.',
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PeopleMoreOption>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'More options',
      onSelected: (option) => _handleSelection(context, option),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: PeopleMoreOption.newGroup,
          child: ListTile(
            leading: Icon(Icons.group_add_outlined),
            title: Text('New Group'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: PeopleMoreOption.newCommunity,
          child: ListTile(
            leading: Icon(Icons.diversity_3_outlined),
            title: Text('New Community'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
