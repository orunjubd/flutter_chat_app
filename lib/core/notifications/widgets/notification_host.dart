import 'dart:async';
//import 'package:chat_app/core/navigation/app_navigator_key.dart';
import 'package:chat_app/core/notifications/models/notification_payload.dart';
import 'package:chat_app/core/notifications/providers/notification_provider.dart';
import 'package:chat_app/core/notifications/services/local_notification_service.dart';
import 'package:chat_app/core/notifications/services/notification_deep_link_service.dart';
import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/features/calls/core/controllers/call_controller.dart';
import 'package:chat_app/features/calls/core/controllers/group_call_controller.dart';
import 'package:chat_app/features/calls/core/models/call_state.dart';
import 'package:chat_app/features/calls/core/utils/app_lifecycle_utils.dart';
import 'package:chat_app/features/chat/data/models/conversation.dart';
//import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/features/chat/providers/conversation_settings_provider.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// + imports: providers, ChatScreen, appNavigatorKey, isAppInForeground,
//   callProvider, groupCallProvider, firestoreRepositoryProvider, Conversation

class NotificationHost extends ConsumerStatefulWidget {
  const NotificationHost({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<NotificationHost> createState() => _NotificationHostState();
}

class _NotificationHostState extends ConsumerState<NotificationHost> {
  final Map<String, int> _last = {}; // conversationId -> last seen unread
  String? _baselineFor; // uid the baseline belongs to

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(notificationBadgeServiceProvider)
          .update(ref.read(unreadTotalProvider));
    });
  }

  void _onConversations(
    AsyncValue<List<Conversation>>? _,
    AsyncValue<List<Conversation>> next,
  ) {
    final list = next.value;
    if (list == null) return;
    final me = ref.read(currentUserIdProvider);
    if (me == null) {
      _last.clear();
      _baselineFor = null;
      return;
    }
    if (_baselineFor != me) {
      // first data for this account: remember, don't alert
      _baselineFor = me;
      _last
        ..clear()
        ..addAll({for (final c in list) c.id: c.unreadCounts[me] ?? 0});
      return;
    }
    for (final c in list) {
      final now = c.unreadCounts[me] ?? 0;
      final before = _last[c.id] ?? 0;
      _last[c.id] = now;
      if (now > before) unawaited(_maybeAlert(c, me));
    }
  }

  Future<void> _maybeAlert(Conversation c, String me) async {
    if (!isAppInForeground) return;
    if (ref.read(activeConversationProvider) == c.id) return;
    final g = ref.read(globalNotificationSettingsProvider).value;
    if (g?.isMuted ?? false) return;

    if (ref.read(conversationSettingsProvider(c.id)).isMuted) return;
    if (ref.read(callProvider).phase.isBusy ||
        ref.read(groupCallProvider).phase.isBusy) {
      return;
    }
    debugPrint(
      '🔔 [Notify] active=${ref.read(activeConversationProvider)} conv=${c.id}',
    );
    final title = await _title(c, me);
    if (!mounted) return;
    if (ref.read(activeConversationProvider) == c.id) return;

    if (g?.messageSound ?? true) {
      unawaited(ref.read(notificationSoundServiceProvider).playMessage());
    }

    final sender = c.lastSenderName ?? '';
    final body = (c.isGroup && sender.isNotEmpty)
        ? '$sender: ${c.lastMessage}'
        : c.lastMessage;
    ref
        .read(notificationServiceProvider)
        .show(
          body.isEmpty ? title : '$title: $body',
          actionLabel: 'Open',
          onAction: () => ref
              .read(notificationDeepLinkServiceProvider)
              .open(
                NotificationPayload(
                  type: NotificationType.message,
                  conversationId: c.id,
                  isGroup: c.isGroup,
                ),
              ),
        );
  }

  Future<String> _title(Conversation c, String me) async {
    if (c.isGroup) return c.name ?? 'Group';
    final otherId = c.participantIds.firstWhere(
      (id) => id != me,
      orElse: () => '',
    );
    if (otherId.isEmpty) return 'New message';
    try {
      final u = await ref
          .read(firestoreRepositoryProvider)
          .getUser(otherId)
          .timeout(const Duration(seconds: 3));
      return (u?.username ?? '').isEmpty ? 'New message' : u!.username;
    } catch (_) {
      return 'New message';
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(activeConversationProvider, (_, id) {
      if (id != null) {
        unawaited(LocalNotificationService.instance.cancelForConversation(id));
      }
    });
    ref.listen<AsyncValue<List<Conversation>>>(
      conversationsProvider,
      _onConversations,
    );
    ref.listen<int>(
      unreadTotalProvider,
      (_, n) => ref.read(notificationBadgeServiceProvider).update(n),
    );
    return widget.child;
  }
}
