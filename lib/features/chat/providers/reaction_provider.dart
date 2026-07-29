import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';

/// ======================================================================
/// REACTION PROVIDER
/// ======================================================================
///
/// Stores the user's currently selected reaction while the UI is interacting.
/// This provider is intentionally independent from Firestore.
///
/// Flow:
///
/// ChatBubble
///     ↓
/// ReactionPicker
///     ↓
/// reactionProvider
///     ↓
/// Repository
///     ↓
/// Firestore
///
/// ======================================================================

final reactionProvider = NotifierProvider<ReactionNotifier, String?>(
  ReactionNotifier.new,
);

class ReactionNotifier extends Notifier<String?> {
  // ✅ 2. MANDATORY BUILD METHOD: Establishes the clean initial baseline state loop
  @override
  String? build() => null;

  /// Select an emoji
  void select(String emoji) {
    state = emoji;
  }

  /// Remove current selection
  void clear() {
    state = null;
  }

  /// Toggle reaction
  ///
  /// Selecting the same emoji twice removes it.
  void toggle(String emoji) {
    if (state == emoji) {
      state = null;
    } else {
      state = emoji;
    }
  }

  bool isSelected(String emoji) {
    return state == emoji;
  }
}
