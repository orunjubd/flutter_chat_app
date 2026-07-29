import 'package:flutter/material.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReactionBar extends ConsumerWidget {
  const ReactionBar({
    super.key,
    required this.reactions,
    required this.currentUserId,
    //required this.conversationId,
    //required this.messageId,
  });

  final Map<String, List<String>> reactions;
  final String currentUserId;
  //final String conversationId;
  //final String messageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }
    final sortedReactions = reactions.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,

        children: sortedReactions.where((entry) => entry.value.isNotEmpty).map((
          entry,
        ) {
          final emoji = entry.key;
          final users = entry.value;

          final reactedByMe = users.contains(currentUserId);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: reactedByMe
                  ? context.primaryColor.withValues(alpha: .05)
                  : context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              // border: Border.all(
              //   color: reactedByMe
              //       ? context.primaryColor
              //       : context.colorScheme.outlineVariant,
              // ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  users.length.toString(),
                  style: context.captionText?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
