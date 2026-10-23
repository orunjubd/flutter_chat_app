import 'package:chat_app/core/navigation/app_navigator_key.dart';
import 'package:chat_app/core/notifications/models/notification_payload.dart';
import 'package:chat_app/core/notifications/providers/notification_provider.dart';
import 'package:chat_app/features/chat/data/models/conversation.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// + imports: appNavigatorKey, Conversation, ChatScreen, activeConversationProvider, payload model

enum DeepLinkResult {
  opened,
  alreadyOpen,
  callHandledByCallUi,
  invalid,
  notSignedIn,
  unavailable,
}

final notificationDeepLinkServiceProvider = Provider(
  (ref) => NotificationDeepLinkService(ref),
);

class NotificationDeepLinkService {
  NotificationDeepLinkService(this._ref);
  final Ref _ref;

  Future<DeepLinkResult> open(NotificationPayload p) async {
    switch (p.type) {
      case NotificationType.unknown:
        debugPrint('🔗 [DeepLink] ignored: unknown payload');
        return DeepLinkResult.invalid;
      case NotificationType.call:
        // The incoming-call UI (CallKit / in-app card) already handles calls.
        debugPrint('🔗 [DeepLink] call payload: app opened, no navigation');
        return DeepLinkResult.callHandledByCallUi;
      case NotificationType.message:
        return _openConversation(p.conversationId!);
    }
  }

  Future<DeepLinkResult> _openConversation(String conversationId) async {
    final uid = await _signedInUid();
    if (uid == null) return DeepLinkResult.notSignedIn;

    if (_ref.read(activeConversationProvider) == conversationId) {
      return DeepLinkResult.alreadyOpen;
    }

    // Validate against the real document, never trust the payload.
    Conversation conversation;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .get();
      final data = doc.data();
      if (data == null) return DeepLinkResult.invalid;
      final members = List<String>.from(data['participantIds'] ?? const []);
      final removed = List<String>.from(data['removedFor'] ?? const []);
      if (!members.contains(uid) ||
          removed.contains(uid) ||
          data['deletedAt'] != null) {
        debugPrint(
          '🔗 [DeepLink] not a member / removed / deleted → $conversationId',
        );
        return DeepLinkResult.invalid;
      }
      conversation = Conversation.fromFirestore(doc);
    } on FirebaseException catch (e) {
      // permission-denied means we are not a member
      debugPrint('🔗 [DeepLink] read failed: ${e.code}');
      return DeepLinkResult.invalid;
    }

    final navigator = await _navigator();
    if (navigator == null) return DeepLinkResult.unavailable;

    navigator.push(
      MaterialPageRoute(builder: (_) => ChatScreen(conversation: conversation)),
    );
    debugPrint('🔗 [DeepLink] opened $conversationId');
    return DeepLinkResult.opened;
  }

  /// On a cold start the user may not be restored yet.
  Future<String?> _signedInUid() async {
    final now = FirebaseAuth.instance.currentUser?.uid;
    if (now != null) return now;
    try {
      final user = await FirebaseAuth.instance
          .authStateChanges()
          .firstWhere((u) => u != null)
          .timeout(const Duration(seconds: 8));
      return user?.uid;
    } catch (_) {
      return null;
    }
  }

  /// On a cold start the navigator may not be mounted yet.
  Future<NavigatorState?> _navigator() async {
    for (var i = 0; i < 20; i++) {
      final nav = appNavigatorKey.currentState;
      if (nav != null) return nav;
      await Future.delayed(const Duration(milliseconds: 250));
    }
    return null;
  }
}
