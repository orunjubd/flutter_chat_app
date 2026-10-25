import 'package:chat_app/core/theme/app_colors.dart';
import 'package:chat_app/features/calls/core/constants/call_strings.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';
import 'package:chat_app/features/calls/core/providers/joinable_group_call_provider.dart';
import 'package:chat_app/features/calls/core/widgets/group_call_join_button.dart';
import 'package:chat_app/features/calls/core/widgets/pulsing_dot.dart';
import 'package:chat_app/features/chat/presentation/widgets/conversation_actions_sheet.dart';
import 'package:chat_app/features/chat/presentation/widgets/group_avatar.dart';
import 'package:chat_app/features/chat/providers/conversation_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/data/models/conversation.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';

import 'conversation_avatar.dart';
import 'package:chat_app/features/chat/presentation/widgets/conversation_preview.dart';
import 'conversation_time.dart';
import 'unread_badge.dart';
//import 'package:chat_app/core/utils/date_time_formatter.dart';

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
    final live = ref.watch(
      liveGroupCallForConversationProvider(conversation.id),
    );
    final settings = ref.watch(conversationSettingsProvider(conversation.id));
    final currentUserId = ref.read(currentUserIdProvider);
    final unreadCount = conversation.unreadCounts[currentUserId] ?? 0;

    Widget tile({
      required Widget avatar,
      required String title,
      required String preview,
    }) {
      return ListTile(
        onTap: onTap,
        onLongPress: () =>
            showConversationActions(context, ref, conversation.id),
        leading: Stack(
          children: [
            avatar,
            if (live != null)
              const Positioned(
                right: 0,
                bottom: 0,
                child: PulsingDot(color: AppColors.online),
              ),
          ],
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: live != null
            ? Text(
                live.type == CallType.video
                    ? CallStrings.liveGroupVideo
                    : CallStrings.liveGroupVoice,
                style: const TextStyle(
                  color: AppColors.online,
                  fontWeight: FontWeight.w500,
                ),
              )
            : ConversationPreview(message: preview),
        trailing: live != null
            ? GroupCallJoinButton(session: live)
            : IntrinsicWidth(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (settings.favorite) const Icon(Icons.star, size: 14),
                        if (settings.isMuted)
                          const Icon(Icons.notifications_off, size: 14),
                        if (settings.pinned)
                          const Icon(Icons.push_pin, size: 14),
                      ],
                    ),
                    ConversationTime(timestamp: conversation.lastMessageTime),
                    const SizedBox(height: 2),
                    UnreadBadge(
                      unreadCount: unreadCount,
                      muted: settings.isMuted,
                    ),
                  ],
                ),
              ),
      );
    }

    // Group: no peer lookup at all.
    if (conversation.isGroup) {
      final sender = conversation.lastSenderName;
      final last = conversation.lastMessage;
      final preview = (sender != null && sender.isNotEmpty && last.isNotEmpty)
          ? '$sender: $last'
          : last;
      final name = conversation.name ?? 'Group Chat';
      return tile(
        avatar: GroupAvatar(name: name, imageUrl: conversation.avatarUrl),
        title: name,
        preview: preview,
      );
    }

    final otherUserId = conversation.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => conversation.participantIds.isNotEmpty
          ? conversation.participantIds.first
          : '',
    );
    return ref
        .watch(userByIdProvider(otherUserId))
        .when(
          loading: () => const ListTile(
            leading: CircleAvatar(child: CircularProgressIndicator()),
            title: Text('Loading...'),
          ),
          error: (_, _) => const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Unknown User'),
          ),
          data: (user) => tile(
            avatar: ConversationAvatar(user: user),
            title: user?.username ?? 'Unknown User',
            preview: conversation.lastMessage,
          ),
        );
  }
}
