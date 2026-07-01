import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/features/authentication/data/repositories/auth_repository.dart';
import 'package:chat_app/features/chat/data/models/app_user.dart';
import 'package:chat_app/features/chat/data/repositories/firestore_repository.dart';

class RegistrationService {
  RegistrationService({
    required AuthRepository authRepository,
    required FirestoreRepository firestoreRepository,
  }) : _authRepository = authRepository,
       _firestoreRepository = firestoreRepository;

  final AuthRepository _authRepository;
  final FirestoreRepository _firestoreRepository;

  Future<AppUser> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // --------------------------------------------------
      // STEP 1
      // Create Firebase Authentication account
      // --------------------------------------------------

      final userCredential = await _authRepository.signUp(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('User creation failed.');
      }

      // --------------------------------------------------
      // STEP 2
      // Create Firestore model
      // --------------------------------------------------

      final appUser = AppUser(
        id: firebaseUser.uid,
        username: username,
        email: email,
        imageUrl: '',
        createdAt: Timestamp.now(),
        isOnline: true,
      );

      // --------------------------------------------------
      // STEP 3
      // Save profile into FireStore  [Create Firestore document]
      // --------------------------------------------------
      await _firestoreRepository.createUser(appUser);

      // --------------------------------------------------
      // SUCCESS
      // --------------------------------------------------
      return appUser;
    } catch (e) {
      // --------------------------------------------------
      // ENTERPRISE ROLLBACK
      // --------------------------------------------------
      try {
        await _authRepository.deleteCurrentUser();
      } catch (_) {
        // ignore: rollback error/failures.
      }
      rethrow;
    }
  }
}
