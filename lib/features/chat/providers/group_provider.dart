import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/chat/data/models/conversation.dart';
import 'package:chat_app/features/chat/data/repositories/group_repository.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';

final groupRepositoryProvider = Provider((ref) => GroupRepository());
final conversationByIdProvider = Provider.autoDispose
    .family<Conversation?, String>(
      (ref, id) => ref
          .watch(conversationsProvider)
          .value
          ?.where((c) => c.id == id)
          .firstOrNull,
    );

/// uid -> username for the other members of a group.
final groupMemberNamesProvider = FutureProvider.autoDispose
    .family<Map<String, String>, String>((ref, groupId) async {
      final me = ref.watch(currentUserIdProvider);
      final c = ref.watch(conversationByIdProvider(groupId));
      if (c == null || !c.isGroup) return const {};
      final repo = ref.read(firestoreRepositoryProvider);
      final entries = await Future.wait(
        c.participantIds.where((id) => id != me).map((id) async {
          try {
            final u = await repo
                .getUser(id)
                .timeout(const Duration(seconds: 4));
            return MapEntry(id, (u?.username ?? '').isEmpty ? id : u!.username);
          } catch (_) {
            return MapEntry(id, id);
          }
        }),
      );
      return {
        for (final e in entries)
          if (!(e.key.length > 20 && e.value == e.key)) e.key: e.value,
      };
    });
