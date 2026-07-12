import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/data/models/conversation.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';

import 'conversation_avatar.dart';
import 'conversation_preview.dart';
import 'conversation_time.dart';
import 'unread_badge.dart';

class ConversationTile extends ConsumerWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.read(currentUserIdProvider);

    final unreadCount = conversation.unreadCounts[currentUserId] ?? 0;

    final otherUserId = conversation.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => conversation.participantIds.isNotEmpty
          ? conversation.participantIds.first
          : '',
    );

    final otherUserAsync = ref.watch(userByIdProvider(otherUserId));

    return otherUserAsync.when(
      loading: () => const ListTile(
        leading: CircleAvatar(child: CircularProgressIndicator(strokeWidth: 2)),
        title: Text('Loading...'),
      ),

      error: (_, __) => const ListTile(
        leading: CircleAvatar(child: Icon(Icons.person)),
        title: Text('Unknown'),
      ),

      data: (user) {
        return ListTile(
          onTap: onTap,

          leading: ConversationAvatar(user: user),

          title: Text(
            user?.username ?? 'Unknown',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          subtitle: ConversationPreview(message: conversation.lastMessage),

          trailing: IntrinsicWidth(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConversationTime(timestamp: conversation.lastMessageTime),

                const SizedBox(height: 6),

                UnreadBadge(unreadCount: unreadCount),
              ],
            ),
          ),
        );
      },
    );
  }
}
