import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/features/authentication/data/repositories/auth_repository.dart';
import 'package:chat_app/features/chat/data/repositories/presence_repository.dart';
import 'package:chat_app/features/chat/data/repositories/typing_repository.dart';

class LogoutService {
  LogoutService({
    required AuthRepository authRepository,
    required PresenceRepository presenceRepository,
    required TypingRepository typingRepository,
  }) : _authRepository = authRepository,
       _presenceRepository = presenceRepository,
       _typingRepository = typingRepository;

  final AuthRepository _authRepository;
  final PresenceRepository _presenceRepository;
  final TypingRepository _typingRepository;

  /// ------------------------------------------------------------
  /// Clean logout pipeline
  /// ------------------------------------------------------------
  Future<void> logout() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Stop typing first
        await _typingRepository.stopTyping(user.uid);

        // Mark offline
        await _presenceRepository.setOffline(user.uid);
      } catch (_) {
        // Ignore cleanup failures.
        // We still want the user to be signed out.
      }
    }

    // Finally sign out
    await _authRepository.signOut();
  }
}
