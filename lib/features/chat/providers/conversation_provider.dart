import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/data/models/conversation.dart';
import 'package:chat_app/features/chat/data/repositories/conversation_repository.dart';

///------------------------------------------------------------
/// Repository Provider
///------------------------------------------------------------
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepository();
});

///------------------------------------------------------------
/// Conversation Stream Provider
///------------------------------------------------------------
final conversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final repository = ref.read(conversationRepositoryProvider);

  return repository.conversationStream();
});
