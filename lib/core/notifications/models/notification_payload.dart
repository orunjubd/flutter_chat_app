enum NotificationType { message, call, unknown }

class NotificationPayload {
  const NotificationPayload({
    required this.type,
    this.conversationId,
    this.callId,
    this.isGroup = false,
  });

  final NotificationType type;
  final String? conversationId;
  final String? callId;
  final bool isGroup;

  /// Used as the payload string of a local notification (7.2).
  Map<String, String> toMap() => {
    'type': type == NotificationType.message ? 'new_message' : 'incoming_call',
    'conversationId': ?conversationId,
    'callId': ?callId,
    'isGroup': '$isGroup',
  };
}
