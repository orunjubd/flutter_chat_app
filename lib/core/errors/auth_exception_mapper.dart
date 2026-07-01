import 'package:firebase_auth/firebase_auth.dart';

class AuthExceptionMapper {
  static String map(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';

      case 'invalid-email':
        return 'The email address is invalid.';

      case 'weak-password':
        return 'The password is too weak.';

      case 'user-not-found':
        return 'No account was found for this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Network connection failed.';

      default:
        return exception.message ?? 'Authentication failed. Please try again.';
    }
  }
}
