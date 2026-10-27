import 'package:flutter/material.dart';
import 'group_avatar.dart';

class MentionSuggestions extends StatelessWidget {
  const MentionSuggestions({
    super.key,
    required this.matches,
    required this.onPick,
  });
  final List<MapEntry<String, String>> matches; // uid -> name
  final void Function(String uid, String name) onPick;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) return const SizedBox.shrink();
    return Material(
      elevation: 2,
      color: Theme.of(context).cardColor,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            for (final m in matches)
              ListTile(
                dense: true,
                leading: GroupAvatar(name: m.value, radius: 14),
                title: Text(m.value),
                onTap: () => onPick(m.key, m.value),
              ),
          ],
        ),
      ),
    );
  }
}
