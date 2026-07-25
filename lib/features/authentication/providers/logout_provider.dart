import 'package:flutter_riverpod/flutter_riverpod.dart';

//import 'package:chat_app/features/authentication/data/repositories/auth_repository.dart';
import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/core/services/logout_service.dart';

import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/features/chat/providers/presence_provider.dart';
import 'package:chat_app/features/chat/providers/typing_provider.dart';
import 'package:chat_app/features/chat/providers/user_directory_provider.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';

final logoutServiceProvider = Provider<LogoutService>((ref) {
  return LogoutService(
    //ref: ref,
    authRepository: ref.read(authRepositoryProvider),
    presenceRepository: ref.read(presenceRepositoryProvider),
    typingRepository: ref.read(typingRepositoryProvider),
  );
});

/// ---------------------------------------------------------------------------
/// Logout Coordinator
/// ---------------------------------------------------------------------------
///
/// Centralizes the complete logout workflow.
///
/// Responsibilities:
/// • Dispose active UI streams.
/// • Clear Riverpod cached state.
/// • Delegate Firebase sign-out to LogoutService.
///
/// Keeping this logic outside the UI keeps AppDrawer and future logout buttons
/// clean and maintainable.
/// ---------------------------------------------------------------------------
final logoutCoordinatorProvider = Provider<LogoutCoordinator>((ref) {
  return LogoutCoordinator(ref);
});

class LogoutCoordinator {
  LogoutCoordinator(this._ref);

  final Ref _ref;

  Future<void> logout() async {
    // -----------------------------------------------------------------------
    // Dispose all active Firestore listeners BEFORE sign out.
    // -----------------------------------------------------------------------

    _ref.invalidate(currentUserProvider);

    _ref.invalidate(conversationsProvider);

    _ref.invalidate(usersDirectoryProvider);

    _ref.invalidate(typingProvider);

    _ref.invalidate(currentUserPresenceProvider);

    _ref.invalidate(emailVerifiedProvider);

    // Allow Riverpod one event loop to dispose listeners.
    await Future<void>.delayed(Duration.zero);

    // Delegate actual Firebase logout.
    await _ref.read(logoutServiceProvider).logout();
  }
}
