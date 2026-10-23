import 'dart:async';
import 'package:chat_app/core/notifications/services/notification_deep_link_service.dart';
import 'package:chat_app/core/notifications/utils/notification_payload_parser.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// + imports: parser, deep link service provider

class NotificationDeepLinkHost extends ConsumerStatefulWidget {
  const NotificationDeepLinkHost({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<NotificationDeepLinkHost> createState() => _HostState();
}

class _HostState extends ConsumerState<NotificationDeepLinkHost> {
  StreamSubscription<RemoteMessage>? _sub;
  static final Set<String> _handled = {};

  @override
  void initState() {
    super.initState();
    _sub = FirebaseMessaging.onMessageOpenedApp.listen(
      _handle,
    ); // background tap
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initial = await FirebaseMessaging.instance
          .getInitialMessage(); // cold start
      if (initial != null) _handle(initial);
    });
  }

  void _handle(RemoteMessage m) {
    final id = m.messageId;
    if (id != null && !_handled.add(id)) return; // already processed
    final payload = NotificationPayloadParser.fromMap(m.data);
    unawaited(ref.read(notificationDeepLinkServiceProvider).open(payload));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
