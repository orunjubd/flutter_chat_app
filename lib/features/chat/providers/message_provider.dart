import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/data/repositories/message_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ------------------------------------------------------------
/// Repository Provider
/// ------------------------------------------------------------
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository();
});

/// ------------------------------------------------------------
/// Real-time Messages Stream Provider
/// ------------------------------------------------------------
final messagesProvider = StreamProvider<List<Message>>((ref) {
  final repository = ref.read(messageRepositoryProvider);

  return repository.messageStream();
});

final currentUserIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});
