import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/calls/core/controllers/group_call_controller.dart';
import 'package:chat_app/features/calls/core/models/group_call_session.dart';

final joinableGroupCallsProvider =
    StreamProvider.autoDispose<List<GroupCallSession>>((ref) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return Stream.value(const []);
      return ref.watch(groupCallSignalingRepositoryProvider).watchJoinable(uid);
    });

/// For a conversation tile: live call tied to this conversation, if any.
/// Dormant until group chats exist (ad-hoc calls have no conversationId).
final liveGroupCallForConversationProvider = Provider.autoDispose
    .family<GroupCallSession?, String>((ref, conversationId) {
      final calls = ref.watch(joinableGroupCallsProvider).value ?? const [];
      for (final c in calls) {
        if (c.conversationId == conversationId) return c;
      }
      return null;
    });
