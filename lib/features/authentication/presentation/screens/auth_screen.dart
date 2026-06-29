import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      body: const Center(child: SingleChildScrollView(child: AuthForm())),
    );
  }
}
