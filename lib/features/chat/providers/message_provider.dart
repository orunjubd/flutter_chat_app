import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/data/repositories/message_repository.dart';

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
