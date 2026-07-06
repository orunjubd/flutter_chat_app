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
final typingProvider = StreamProvider<List<TypingStatus>>((ref) {
  final repository = ref.watch(typingRepositoryProvider);

  return repository.typingStream();
});
