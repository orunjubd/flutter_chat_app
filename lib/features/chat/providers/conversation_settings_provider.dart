import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/chat/data/models/conversation_settings.dart';
import 'package:chat_app/features/chat/policies/conversation_settings_policy.dart';
import 'package:chat_app/features/chat/data/repositories/conversation_settings_repository.dart';

final conversationSettingsRepositoryProvider = Provider(
  (ref) => ConversationSettingsRepository(),
);

final conversationSettingsMapProvider =
    StreamProvider.autoDispose<Map<String, ConversationSettings>>((ref) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return Stream.value(const {});
      return ref.watch(conversationSettingsRepositoryProvider).watchAll(uid);
    });

/// One conversation's settings; rebuilds only when that one changes.
final conversationSettingsProvider = Provider.autoDispose
    .family<ConversationSettings, String>((ref, id) {
      final s = ref.watch(
        conversationSettingsMapProvider.select((a) => a.value?[id]),
      );
      return s ?? ConversationSettings.defaults(id);
    });

final conversationSettingsActionsProvider = Provider(
  (ref) => ConversationSettingsActions(ref),
);

class ConversationSettingsActions {
  ConversationSettingsActions(this._ref);
  final Ref _ref;
  static const _policy = ConversationSettingsPolicy();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  Map<String, ConversationSettings> get _all =>
      _ref.read(conversationSettingsMapProvider).value ?? const {};
  ConversationSettings _current(String id) =>
      _all[id] ?? ConversationSettings.defaults(id);

  Future<void> _save(ConversationSettings s) async {
    final uid = _uid;
    if (uid == null) return;
    await _ref.read(conversationSettingsRepositoryProvider).save(uid, s);
  }

  /// Returns a user-facing error, or null on success.
  Future<String?> togglePin(String id) async {
    final s = _current(id);
    if (s.pinned) {
      await _save(s.copyWith(clearPin: true));
      return null;
    }
    final problem = _policy.validatePin(
      _all.values.where((e) => e.pinned).length,
    );
    if (problem != null) return problem;
    await _save(s.copyWith(pinnedAt: Timestamp.now()));
    return null;
  }

  Future<void> toggleArchive(String id) {
    final s = _current(id);
    return _save(
      s.archived
          ? s.copyWith(archived: false)
          : s.copyWith(archived: true, clearPin: true),
    ); // archiving unpins
  }

  Future<void> toggleFavorite(String id) {
    final s = _current(id);
    return _save(s.copyWith(favorite: !s.favorite));
  }

  /// [duration] null = always.
  Future<void> mute(String id, {Duration? duration}) {
    final until = duration == null
        ? Timestamp.fromDate(DateTime(2100))
        : Timestamp.fromDate(DateTime.now().add(duration));
    return _save(_current(id).copyWith(mutedUntil: until));
  }

  Future<void> unmute(String id) =>
      _save(_current(id).copyWith(clearMute: true));
}
