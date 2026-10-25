import 'dart:async';
import 'dart:convert';
import 'package:chat_app/core/notifications/models/notification_payload.dart';
import 'package:chat_app/core/notifications/services/notification_channel_service.dart';
import 'package:chat_app/core/notifications/utils/notification_payload_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// + imports: NotificationChannelService, NotificationPayload, NotificationPayloadParser

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Taps with the app dead launch the app; the host reads the launch details.
}

class LocalNotificationService {
  LocalNotificationService._();
  static final instance = LocalNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<String>.broadcast();
  bool _ready = false;

  Stream<String> get taps => _taps.stream;

  Future<void> init() async {
    if (_ready) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        final p = r.payload;
        if (p != null && p.isNotEmpty) _taps.add(p);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    await NotificationChannelService.createAll(_plugin);
    _ready = true;
  }

  Future<void> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
  }

  /// Payload of the notification that launched the app, if any (cold start).
  Future<String?> launchPayload() async {
    final d = await _plugin.getNotificationAppLaunchDetails();
    return (d?.didNotificationLaunchApp ?? false)
        ? d?.notificationResponse?.payload
        : null;
  }

  /// Stable per conversation, so a new message replaces the previous one.
  static int _idFor(String conversationId) {
    var h = 0;
    for (final c in conversationId.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h;
  }

  Future<void> showMessage(Map<String, dynamic> data) async {
    final payload = NotificationPayloadParser.fromMap(data);
    final convId = payload.conversationId;
    if (payload.type != NotificationType.message || convId == null) return;
    await init();

    final channel = payload.isGroup
        ? NotificationChannelService.groups
        : NotificationChannelService.messages;
    final title = (data['title'] as String?)?.trim();
    final body = (data['body'] as String?)?.trim();

    await _plugin.show(
      id: _idFor(convId),
      title: (title == null || title.isEmpty) ? 'New message' : title,
      body: body ?? '',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          groupKey: convId,
        ),
      ),
      payload: jsonEncode(payload.toMap()),
    );
    debugPrint('🔔 [Notify] shown for $convId');
  }

  Future<void> cancelForConversation(String conversationId) =>
      _plugin.cancel(id: _idFor(conversationId));
}
