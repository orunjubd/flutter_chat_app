import 'package:flutter/material.dart';
import 'package:chat_app/features/chat/constants/conversation_strings.dart';
import 'package:chat_app/features/chat/data/models/conversation_filter.dart';

class ConversationFilterBar extends StatelessWidget {
  const ConversationFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  final ConversationFilter selected;
  final ValueChanged<ConversationFilter> onChanged;

  static const _labels = {
    ConversationFilter.all: ConversationStrings.filterAll,
    ConversationFilter.unread: ConversationStrings.filterUnread,
    ConversationFilter.favorites: ConversationStrings.filterFavorites,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          for (final f in ConversationFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_labels[f]!),
                selected: selected == f,
                onSelected: (_) => onChanged(f),
              ),
            ),
        ],
      ),
    );
  }
}
