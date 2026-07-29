import 'package:flutter/material.dart';

class ReactionPicker extends StatelessWidget {
  const ReactionPicker({super.key, required this.onSelected});

  final ValueChanged<String> onSelected;

  static const List<String> emojis = ['👍', '❤️', '😂', '😮', '😢', '😡'];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .15),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: emojis.map((emoji) {
            return InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () => onSelected(emoji),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
