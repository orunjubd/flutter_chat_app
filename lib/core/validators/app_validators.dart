//import 'package:flutter/material.dart';

class AppValidators {
  AppValidators._();

  // ----------------------------------------------------------
  // Centralized Regular Expressions
  // ----------------------------------------------------------

  static final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
  );

  static final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9_.]{4,15}$');

  // ----------------------------------------------------------
  // Email
  // ----------------------------------------------------------

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email.';
    }

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  // ----------------------------------------------------------
  // Username
  // ----------------------------------------------------------

  static String? validateUsername(String? value) {
    final username = value?.trim() ?? '';

    if (username.isEmpty) {
      return 'Please enter a username.';
    }

    if (!usernameRegex.hasMatch(username)) {
      return 'Username must contain 4–15 letters, numbers, "_" or ".".';
    }

    return null;
  }

  // ----------------------------------------------------------
  // Password
  // ----------------------------------------------------------

  static String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter your password.';
    }

    if (!passwordRegex.hasMatch(password)) {
      return 'Password must contain:\n'
          '• 8+ characters\n'
          '• Uppercase letter\n'
          '• Lowercase letter\n'
          '• Number\n'
          '• Special character';
    }

    return null;
  }

  // ----------------------------------------------------------
  // Confirm Password
  // ----------------------------------------------------------

  static String? validateConfirmPassword({
    required String? password,
    required String? confirmPassword,
  }) {
    if ((confirmPassword ?? '').isEmpty) {
      return 'Please confirm your password.';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }

    return null;
  }

  // ----------------------------------------------------------
  // Required Field
  // ----------------------------------------------------------

  static String? requiredField(String? value, {String fieldName = 'Field'}) {
    if ((value ?? '').trim().isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }
}
