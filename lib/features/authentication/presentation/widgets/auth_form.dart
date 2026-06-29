import 'package:flutter/material.dart';

// ✅ IMPORT YOUR SEPARATED CHILD SUB-WIDGETS HERE
import 'package:chat_app/features/authentication/presentation/widgets/email_field.dart';
import 'package:chat_app/features/authentication/presentation/widgets/password_field.dart';
import 'package:chat_app/features/authentication/presentation/widgets/username_field.dart';
import 'package:chat_app/features/authentication/presentation/widgets/confirm_password_field.dart';
import 'package:chat_app/features/authentication/presentation/widgets/auth_button.dart';
import 'package:chat_app/features/authentication/presentation/widgets/auth_switch_button.dart';
import 'package:chat_app/features/authentication/presentation/widgets/logo.dart'
    as auth_logo;
//import 'package:chat_app/features/authentication/data/repositories/auth_repository.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;

  //final _authRepository = AuthRepository();

  // ✅ 2. CENTRALIZED SECURITY REGULAR EXPRESSIONS MATRIX
  // ✅ সব রেগুলার এক্সপ্রেশন এই এক মাস্টার ফাইলেই সুরক্ষিত থাকছে
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
  );
  final usernameRegex = RegExp(r'^[a-zA-Z0-9_\.]{4,15}$');

  // ✅ 3. CENTRALIZED DATA CONTROLLERS INSTANT MEMORY POOL
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ✅ 4. THE SUBMISSION ENGINE VALIDATION PIPELINE
  void _submitForm() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    final enteredEmail = _emailController.text.trim();
    final enteredPassword = _passwordController.text.trim();
    final enteredUsername = _isLogin ? '' : _usernameController.text.trim();

    debugPrint('Validation Passed! Processing Backend Request...');
    debugPrint('Email: $enteredEmail');
    debugPrint('Password: $enteredPassword');
    if (!_isLogin) {
      debugPrint('Username: $enteredUsername');
    }

    // TODO: Trigger Firebase Authentication Service call pipeline here!
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // A. Isolated App Logo Canvas Unit
          const auth_logo.AuthLogo(),

          const SizedBox(height: 10),

          // B. Conditional Username Node Injection
          if (!_isLogin) ...[
            UsernameField(
              controller: _usernameController,
              usernameRegex: usernameRegex,
            ),
            const SizedBox(height: 14),
          ],

          // C. Core Isolated Email Field Component
          EmailField(controller: _emailController, emailRegex: emailRegex),

          const SizedBox(height: 14),

          // D. Core Isolated Password Field Component
          PasswordField(
            controller: _passwordController,
            passwordRegex: passwordRegex,
          ),

          const SizedBox(height: 14),

          // E. Conditional Confirm Password Node Injection
          if (!_isLogin) ...[
            ConfirmPasswordTextField(
              controller: _confirmPasswordController,
              passwordController: _passwordController,
            ),
            const SizedBox(height: 14),
          ],

          const SizedBox(height: 20),

          // F. Isolated Primary Submit Button Unit
          AuthButton(
            isLogin: _isLogin,
            onTap: _submitForm, // Passing function pointer handle cleanly
          ),

          const SizedBox(height: 12),

          // G. Isolated Authentication Mode Switcher Link Unit
          AuthSwitchButton(
            isLogin: _isLogin,
            onTap: () {
              setState(() {
                _isLogin =
                    !_isLogin; // Reverse internal toggler flag status state

                _formKey.currentState!.reset();

                _usernameController.clear();
                _emailController.clear();
                _passwordController.clear();
                _confirmPasswordController.clear();
              });
            },
          ),
        ],
      ),
    );
  }
}
