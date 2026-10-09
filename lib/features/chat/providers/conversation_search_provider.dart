import 'package:chat_app/features/chat/data/models/conversation_filter.dart';
import 'package:chat_app/features/chat/providers/conversation_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/chat/data/models/conversation.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
// + imports: conversationsProvider, currentUserIdProvider, userByIdProvider, Conversation

/// Conversations whose other participant's name, or last message, matches [query].
/// An empty query returns everything.
typedef ConversationScope = ({
  String query,
  bool archived,
  ConversationFilter filter,
});

final filteredConversationsProvider = FutureProvider.autoDispose
    .family<List<Conversation>, ConversationScope>((ref, scope) async {
      final all = await ref.watch(conversationsProvider.future);
      final settings = await ref.watch(conversationSettingsMapProvider.future);
      final myUid = ref.read(currentUserIdProvider);
      final q = scope.query.trim().toLowerCase();

      List<Conversation> list;
      if (q.isEmpty) {
        // Browsing: inbox or archive.
        list = all.where((c) {
          if ((settings[c.id]?.archived ?? false) != scope.archived) {
            return false;
          }
          return switch (scope.filter) {
            ConversationFilter.all => true,
            ConversationFilter.unread => (c.unreadCounts[myUid] ?? 0) > 0,
            ConversationFilter.favorites => settings[c.id]?.favorite ?? false,
          };
        }).toList();
      } else {
        // Searching: everything, archived included.
        final hits = await Future.wait(
          all.map((c) async {
            final otherId = c.participantIds.firstWhere(
              (id) => id != myUid,
              orElse: () => '',
            );
            if (otherId.isEmpty) return false;
            final user = await ref.read(userByIdProvider(otherId).future);
            return (user?.username ?? '').toLowerCase().contains(q) ||
                c.lastMessage.toLowerCase().contains(q);
          }),
        );
        list = [
          for (var i = 0; i < all.length; i++)
            if (hits[i]) all[i],
        ];
      }

      // Pinned first (latest pin on top), then newest message.
      list.sort((a, b) {
        final pa = settings[a.id]?.pinnedAt, pb = settings[b.id]?.pinnedAt;
        if (pa != null && pb != null) return pb.compareTo(pa);
        if (pa != null) return -1;
        if (pb != null) return 1;
        return b.lastMessageTime.compareTo(a.lastMessageTime);
      });
      return list;
    });
