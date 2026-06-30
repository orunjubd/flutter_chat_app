import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ IMPORT YOUR SEPARATED CHILD SUB-WIDGETS HERE
import 'package:chat_app/features/authentication/presentation/widgets/email_field.dart';
import 'package:chat_app/features/authentication/presentation/widgets/password_field.dart';
import 'package:chat_app/features/authentication/presentation/widgets/username_field.dart';
import 'package:chat_app/features/authentication/presentation/widgets/confirm_password_field.dart';
import 'package:chat_app/features/authentication/presentation/widgets/auth_button.dart';
import 'package:chat_app/features/authentication/presentation/widgets/auth_switch_button.dart';
import 'package:chat_app/features/authentication/presentation/widgets/logo.dart'
    as auth_logo;
// import 'package:chat_app/features/authentication/data/repositories/auth_repository.dart';
import 'package:chat_app/features/authentication/providers/auth_provider.dart';
//import 'package:chat_app/features/chat/data/models/app_user.dart';
import 'package:chat_app/features/authentication/providers/registration_provider.dart';

class AuthForm extends ConsumerStatefulWidget {
  const AuthForm({super.key});

  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
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
  void _submitForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    final enteredEmail = _emailController.text.trim();
    final enteredPassword = _passwordController.text.trim();
    final enteredUsername = _isLogin ? '' : _usernameController.text.trim();

    // Read the background repository instances via ref handles
    final authRepository = ref.read(authRepositoryProvider);
    //final firestoreRepository = ref.read(firestoreRepositoryProvider);
    final registrationService = ref.read(registrationServiceProvider);
    final loadingNotifier = ref.read(authLoadingProvider.notifier);

    try {
      loadingNotifier.setLoading(true); // Turn on loading spinner indicator
      ScaffoldMessenger.of(context).clearSnackBars();

      if (_isLogin) {
        // Run Cloud Sign In transaction Task
        await authRepository.signIn(
          email: enteredEmail,
          password: enteredPassword,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully authenticated! Welcome back.'),
          ),
        );
      } else {
        await registrationService.register(
          username: enteredUsername,
          email: enteredEmail,
          password: enteredPassword,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account successfully created! Welcome to Chat App.'),
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      // ✅ 3. ENTERPRISE ERROR SNACKBAR INTERCEPTORS
      // ✅ ফায়ারবেস থেকে কোনো এরর আসলে সেটি স্ক্রিনে মেসেজ আকারে দেখাবে
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ??
                'Authentication failed. Please check your credentials.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected system error occurred.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      // Turn off loading spinner indicator once operations close down
      loadingNotifier.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);

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

          if (isLoading)
            const CircularProgressIndicator(color: Colors.black)
          else ...[
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
        ],
      ),
    );
  }
}
