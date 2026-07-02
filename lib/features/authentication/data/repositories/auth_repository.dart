import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/foundation.dart';

class AuthRepository {
  AuthRepository();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<void> signIn({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> deleteCurrentUser() async {
    final user = _firebaseAuth.currentUser;

    if (user != null) {
      await user.delete();
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    await user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return false;
    }

    await user.reload();

    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  Future<void> resetPassword({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
