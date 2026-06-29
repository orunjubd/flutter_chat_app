import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository();

  final FirebaseAuth _firebase = FirebaseAuth.instance;

  Future<void> signIn({required String email, required String password}) async {
    await _firebase.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    await _firebase.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebase.signOut();
  }

  User? get currentUser => _firebase.currentUser;

  Stream<User?> authStateChanges() {
    return _firebase.authStateChanges();
  }
}
