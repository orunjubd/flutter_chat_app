import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/chat/data/models/conversation.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
// + imports: conversationsProvider, currentUserIdProvider, userByIdProvider, Conversation

/// Conversations whose other participant's name, or last message, matches [query].
/// An empty query returns everything.
final filteredConversationsProvider = FutureProvider.autoDispose
    .family<List<Conversation>, String>((ref, query) async {
      final all = await ref.watch(conversationsProvider.future);
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return all;

      final myUid = ref.watch(currentUserIdProvider);
      final matches = await Future.wait(
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

      return [
        for (var i = 0; i < all.length; i++)
          if (matches[i]) all[i],
      ];
    });
