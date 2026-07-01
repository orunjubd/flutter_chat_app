import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository();

  final FirebaseAuth _firebase = FirebaseAuth.instance;

  User? get currentUser => _firebase.currentUser;

  Stream<User?> authStateChanges() {
    return _firebase.authStateChanges();
  }

  Future<void> signIn({required String email, required String password}) async {
    await _firebase.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _firebase.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebase.signOut();
  }

  Future<void> deleteCurrentUser() async {
    final user = _firebase.currentUser;

    if (user != null) {
      await user.delete();
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _firebase.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    await user.sendEmailVerification();
  }
}
