import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/calls/core/controllers/group_call_controller.dart';
import 'package:chat_app/features/calls/core/models/group_call_history_entry.dart';

final groupCallHistoryProvider =
    StreamProvider.autoDispose<List<GroupCallHistoryEntry>>((ref) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return Stream.value(const []);
      return ref.watch(groupCallHistoryRepositoryProvider).watch(uid);
    });
