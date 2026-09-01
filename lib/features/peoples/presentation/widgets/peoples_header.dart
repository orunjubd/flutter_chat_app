// lib/features/peoples/presentation/widgets/peoples_header.dart
import 'package:flutter/material.dart';

/// Minimal header for now — deliberately no search/sort actions here
/// yet; those are separate, later steps (4.8.3 / 4.8.4).
class PeoplesHeader extends StatelessWidget implements PreferredSizeWidget {
  const PeoplesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Peoples'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
