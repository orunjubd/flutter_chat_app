import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/data/models/message.dart';

/// ===============================================================
/// Forward Provider
/// ===============================================================
///
/// Holds the message currently selected for forwarding.
///
/// Only one message can be forwarded at a time.
/// ===============================================================

class ForwardNotifier extends Notifier<Message?> {
  @override
  Message? build() => null;

  /// Select a message to forward
  void forward(Message message) {
    state = message;
  }

  /// Clear current forward selection
  void clear() {
    state = null;
  }

  bool get hasForward => state != null;
}

final forwardProvider = NotifierProvider<ForwardNotifier, Message?>(
  ForwardNotifier.new,
);
