import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ IMPORT YOUR SEPARATED CHILD SUB-WIDGETS HERE
import 'package:chat_app/features/authentication/presentation/widgets/email_field.dart';
import 'package:chat_app/features/authentication/presentation/widgets/password_field.dart';
import 'package:chat_app/features/authentication/presentation/widgets/username_field.dart';
import 'package:chat_app/features/authentication/presentation/widgets/confirm_password_field.dart';
import 'package:chat_app/features/authentication/presentation/widgets/auth_button.dart';
import 'package:chat_app/features/authentication/presentation/widgets/auth_switch_button.dart';
import 'package:chat_app/features/authentication/presentation/widgets/logo.dart'
    as auth_logo;

import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/features/authentication/providers/registration_provider.dart';
import 'package:chat_app/core/errors/auth_exception_mapper.dart';
import 'package:chat_app/features/authentication/presentation/widgets/forgot_password_dialog.dart';
import 'package:chat_app/core/dialogs/app_snackbar.dart';
import 'package:chat_app/core/validators/app_validators.dart';

class AuthForm extends ConsumerStatefulWidget {
  const AuthForm({super.key});

  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;

  // ✅ 2. CENTRALIZED SECURITY REGULAR EXPRESSIONS MATRIX
  // ✅ সব রেগুলার এক্সপ্রেশন এই এক মাস্টার ফাইলেই সুরক্ষিত থাকছে

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

  Future<void> _showForgotPasswordDialog() async {
    final authRepository = ref.read(authRepositoryProvider);

    await showDialog(
      context: context,
      builder: (_) {
        return ForgotPasswordDialog(
          onSend: (email) async {
            await authRepository.sendPasswordResetEmail(email: email);

            if (!mounted) return;

            AppSnackBar.success(
              context,
              'Password reset email sent. Please check your inbox.',
            );
          },
        );
      },
    );
  }

  // ✅ 4. THE SUBMISSION ENGINE VALIDATION PIPELINE
  void _submitForm() async {
    // ✅ Form validation
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    final enteredEmail = _emailController.text.trim();
    final enteredPassword = _passwordController.text.trim();
    final enteredUsername = _isLogin ? '' : _usernameController.text.trim();

    // ✅ Reading providers and Read the background repository instances via ref handles
    final authRepository = ref.read(authRepositoryProvider);
    //final firestoreRepository = ref.read(firestoreRepositoryProvider);
    final registrationService = ref.read(registrationServiceProvider);
    final loadingNotifier = ref.read(authLoadingProvider.notifier);

    try {
      // ✅ Loading state
      loadingNotifier.setLoading(true); // Turn on loading spinner indicator
      // AppSnackBar.info(context, 'Processing your request...');   // re

      if (_isLogin) {
        // ✅ SIGN IN and Run Cloud Sign In transaction Task
        await authRepository.signIn(
          email: enteredEmail,
          password: enteredPassword,
        );

        if (!mounted) return;
        AppSnackBar.success(
          context,
          'Successfully authenticated! Welcome back.',
        );
      } else {
        // ✅ REGISTRATION and Run Cloud Sign Up transaction Task
        await registrationService.register(
          username: enteredUsername,
          email: enteredEmail,
          password: enteredPassword,
        );
        if (!mounted) return;
        AppSnackBar.success(
          context,
          'Account created successfully! Please verify your email.',
        );
      }
    } on FirebaseAuthException catch (error) {
      // ✅ 3. ENTERPRISE ERROR SNACKBAR INTERCEPTORS
      if (!mounted) return;
      AppSnackBar.error(context, AuthExceptionMapper.map(error));
    } catch (error, stackTrace) {
      debugPrint('Unexpected Error: ${error.toString()}');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      AppSnackBar.error(
        context,
        'An unexpected system error occurred. Please try again later.',
      );
    } finally {
      // Turn off loading spinner indicator once operations close down
      loadingNotifier.setLoading(false);
    }
  }

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin; // Reverse internal toggler flag status state

      _formKey.currentState!.reset();

      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
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
              validator: AppValidators.validateUsername,
            ),
            const SizedBox(height: 14),
          ],

          // C. Core Isolated Email Field Component
          EmailField(
            controller: _emailController,
            validator: AppValidators.validateEmail,
          ),

          const SizedBox(height: 14),

          // D. Core Isolated Password Field Component
          PasswordField(
            controller: _passwordController,
            validator: AppValidators.validatePassword,
          ),

          if (_isLogin)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed:
                    _showForgotPasswordDialog, // Handshake link to trigger method
                style: TextButton.styleFrom(
                  foregroundColor: Colors
                      .black54, // Soft dark grey text link to match background theme
                  padding: EdgeInsets.zero,
                ),
                child: const Text('Forgot Password?'),
              ),
            ),

          const SizedBox(height: 14),

          // E. Conditional Confirm Password Node Injection
          if (!_isLogin) ...[
            ConfirmPasswordTextField(
              controller: _confirmPasswordController,
              validator: (value) => AppValidators.validateConfirmPassword(
                password: _passwordController.text,
                confirmPassword: value,
              ),
            ),
            const SizedBox(height: 14),
          ],

          const SizedBox(height: 20),

          // F. Isolated Authentication Button Unit
          // (Loading state is handled by the parent screen via LoadingOverlay)
          AuthButton(
            isLogin: _isLogin,
            onTap: _submitForm, // Passing function pointer handle cleanly
          ),

          const SizedBox(height: 12),

          // G. Isolated Authentication Mode Switcher Link Unit
          AuthSwitchButton(isLogin: _isLogin, onTap: _switchAuthMode),
        ],
      ),
    );
  }
}
