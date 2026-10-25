import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationChannelService {
  static const messages = AndroidNotificationChannel(
    'messages',
    'Messages',
    description: 'New direct messages',
    importance: Importance.high,
  );
  static const groups = AndroidNotificationChannel(
    'group_messages',
    'Group messages',
    description: 'New group messages',
    importance: Importance.high,
  );

  static Future<void> createAll(FlutterLocalNotificationsPlugin plugin) async {
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(messages);
    await android?.createNotificationChannel(groups);
    // The call channel is created by flutter_callkit_incoming.
  }
}
