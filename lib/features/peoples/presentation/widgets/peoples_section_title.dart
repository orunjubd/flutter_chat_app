// lib/features/peoples/presentation/widgets/peoples_section_title.dart
import 'package:flutter/material.dart';

/// Reusable section header — "App Users" now, "Invite Friends" /
/// "Recent Calls" / etc. will use this same widget in later steps.
class PeoplesSectionTitle extends StatelessWidget {
  const PeoplesSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
