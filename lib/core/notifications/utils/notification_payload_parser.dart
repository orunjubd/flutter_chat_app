import 'dart:convert';
import '../models/notification_payload.dart';

class NotificationPayloadParser {
  static const _callTypes = {
    'incoming_call',
    'incoming_group_call',
    'group_call_cancelled',
  };

  static String? _id(Object? v) {
    if (v is! String) return null;
    final s = v.trim();
    if (s.isEmpty || s.length > 128 || s.contains('/')) {
      return null;
    } // no path injection
    return s;
  }

  static NotificationPayload fromMap(Map<String, dynamic> data) {
    final type = data['type'];
    if (type == 'new_message') {
      final conv = _id(data['conversationId']);
      if (conv == null) {
        return const NotificationPayload(type: NotificationType.unknown);
      }
      return NotificationPayload(
        type: NotificationType.message,
        conversationId: conv,
        isGroup: data['isGroup'] == 'true' || data['isGroup'] == true,
      );
    }
    if (_callTypes.contains(type)) {
      return NotificationPayload(
        type: NotificationType.call,
        callId: _id(data['callId']),
        isGroup: type != 'incoming_call',
      );
    }
    return const NotificationPayload(type: NotificationType.unknown);
  }

  /// For local notifications, whose payload is a JSON string.
  static NotificationPayload fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const NotificationPayload(type: NotificationType.unknown);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return fromMap(Map<String, dynamic>.from(decoded));
    } catch (_) {}
    return const NotificationPayload(type: NotificationType.unknown);
  }
}
