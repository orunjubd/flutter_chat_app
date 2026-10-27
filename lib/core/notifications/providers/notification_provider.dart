import 'package:chat_app/core/notifications/models/global_notification_settings.dart';
import 'package:chat_app/core/notifications/repositories/global_notification_settings_repository.dart';
import 'package:chat_app/core/notifications/services/notification_badge_service.dart';
import 'package:chat_app/core/notifications/services/notification_service.dart';
import 'package:chat_app/core/notifications/services/notification_sound_service.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/features/chat/providers/conversation_settings_provider.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// + imports: services above, conversationsProvider, conversationSettingsMapProvider, currentUserIdProvider

final notificationServiceProvider = Provider((ref) => NotificationService());

final notificationSoundServiceProvider = Provider((ref) {
  final s = NotificationSoundService();
  ref.onDispose(s.dispose);
  return s;
});

final notificationBadgeServiceProvider = Provider(
  (ref) => NotificationBadgeService(),
);

/// The conversation currently open on screen (set by ChatScreen).
final activeConversationProvider =
    NotifierProvider<ActiveConversationNotifier, String?>(
      ActiveConversationNotifier.new,
    );

class ActiveConversationNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void enter(String id) => state = id;
  void leave(String id) {
    if (state == id) {
      state = null;
    } // don't clear a newer chat that already opened
  }
}

/// Unread total for the launcher badge: muted and archived chats are not counted.
final unreadTotalProvider = Provider.autoDispose<int>((ref) {
  final me = ref.watch(currentUserIdProvider);
  final convs = ref.watch(conversationsProvider).value ?? const [];
  final settings = ref.watch(conversationSettingsMapProvider).value ?? const {};
  var total = 0;
  for (final c in convs) {
    final s = settings[c.id];
    if (s != null && (s.isMuted || s.archived)) continue;
    total += c.unreadCounts[me] ?? 0;
  }
  return total;
});
final globalNotificationSettingsRepositoryProvider = Provider(
  (ref) => GlobalNotificationSettingsRepository(),
);

final globalNotificationSettingsProvider =
    StreamProvider<GlobalNotificationSettings>((ref) {
      final uid = ref.watch(currentUserIdProvider);
      if (uid == null) return Stream.value(const GlobalNotificationSettings());
      return ref.watch(globalNotificationSettingsRepositoryProvider).watch(uid);
    });
