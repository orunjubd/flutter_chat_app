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
