import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/data/models/message.dart';

/// ---------------------------------------------------------------------------
/// Reply Provider
/// ---------------------------------------------------------------------------
///
/// Holds the message currently being replied to.
///
/// null
///   ↓
/// User long-presses a message
///   ↓
/// Message stored here
///   ↓
/// MessageInput shows reply preview
///   ↓
/// User sends message
///   ↓
/// Provider cleared
/// ---------------------------------------------------------------------------

class ReplyNotifier extends Notifier<Message?> {
  @override
  Message? build() => null;

  /// Start replying to a message.
  void replyTo(Message message) {
    state = message;
  }

  /// Cancel reply.
  void clear() {
    state = null;
  }
}

final replyProvider = NotifierProvider<ReplyNotifier, Message?>(
  ReplyNotifier.new,
);
