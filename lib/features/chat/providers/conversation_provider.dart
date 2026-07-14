import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
final conversationsProvider = StreamProvider.autoDispose<List<Conversation>>((
  ref,
) {
  // final repository = ref.read(conversationRepositoryProvider);

  // return repository.conversationStream();

  final repository = ref.watch(conversationRepositoryProvider);
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  if (currentUserId == null) {
    return Stream.value(
      [],
    ); // Return an empty stream if no user is authenticated
  }

  // Passes the required identifier key down to lock down data isolation boundaries
  return repository.conversationStream(currentUserId: currentUserId);
});
