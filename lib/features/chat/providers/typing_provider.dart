import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/typing_status.dart';
import '../data/repositories/typing_repository.dart';

/// ------------------------------------------------------------
/// Typing Repository Provider
/// ------------------------------------------------------------
final typingRepositoryProvider = Provider<TypingRepository>((ref) {
  return TypingRepository();
});

/// ------------------------------------------------------------
/// Typing Stream Provider
/// ------------------------------------------------------------
// provider
final typingProvider = StreamProvider.autoDispose
    .family<List<TypingStatus>, String>((ref, conversationId) {
      return ref
          .watch(typingRepositoryProvider)
          .typingStream()
          .map(
            (list) => [
              for (final t in list)
                if (t.conversationId == conversationId &&
                    DateTime.now().difference(t.updatedAt.toDate()).inSeconds <
                        8)
                  t,
            ],
          );
    });
