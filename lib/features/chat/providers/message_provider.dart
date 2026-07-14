import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/data/repositories/message_repository.dart';

/// ------------------------------------------------------------
/// Generic Message Repository
/// ------------------------------------------------------------
///
/// This repository contains reusable message operations.
/// It is conversation-agnostic.
///
/// Conversation-specific providers live in:
/// conversation_message_provider.dart
///
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository();
});
