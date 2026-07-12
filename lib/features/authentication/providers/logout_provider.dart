import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/services/logout_service.dart';
import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/features/chat/providers/presence_provider.dart';
import 'package:chat_app/features/chat/providers/typing_provider.dart';

final logoutServiceProvider = Provider<LogoutService>((ref) {
  return LogoutService(
    authRepository: ref.read(authRepositoryProvider),
    presenceRepository: ref.read(presenceRepositoryProvider),
    typingRepository: ref.read(typingRepositoryProvider),
  );
});
