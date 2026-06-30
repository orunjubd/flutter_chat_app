import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/authentication/services/registration_service.dart';
import 'package:chat_app/features/authentication/providers/auth_provider.dart';

final registrationServiceProvider = Provider<RegistrationService>((ref) {
  return RegistrationService(
    authRepository: ref.read(authRepositoryProvider),
    firestoreRepository: ref.read(firestoreRepositoryProvider),
  );
});
