class FirebaseErrorMapper {
  static String message(Object error) {
    final text = error.toString().toLowerCase();

    if (text.contains('network-request-failed')) {
      return 'No Internet Connection';
    }

    if (text.contains('permission-denied')) {
      return 'Permission denied.';
    }

    if (text.contains('unavailable')) {
      return 'Server unavailable. Please try again.';
    }

    if (text.contains('deadline-exceeded')) {
      return 'Request timed out.';
    }

    if (text.contains('user-not-found')) {
      return 'User not found.';
    }

    if (text.contains('wrong-password')) {
      return 'Incorrect password.';
    }

    if (text.contains('email-already-in-use')) {
      return 'Email already in use.';
    }

    if (text.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }

    return 'Something went wrong.';
  }
}
