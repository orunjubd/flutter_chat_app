import 'package:flutter/material.dart';

class ConfirmPasswordTextField extends StatelessWidget {
  const ConfirmPasswordTextField({
    super.key,
    required this.controller,
    required this.passwordController, // ✅ Receives the parent password controller to check matches
  });

  final TextEditingController controller;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        color: Color.fromARGB(221, 194, 193, 193),
      ), // ✅ Clear black text ink for white background
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Confirm Password',
        labelStyle: TextStyle(
          color: Color.fromARGB(221, 194, 193, 193),
        ), // ✅ Soft dark grey text label
        prefixIcon: Icon(
          Icons.lock_reset_outlined,
          color: Color.fromARGB(221, 194, 193, 193),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(88, 194, 193, 193),
          ), // ✅ Subtle contrast border edge
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ), // ✅ Strong solid black highlight on tap
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
      obscureText:
          true, // ✅ Secures typed password input string character layers
      autocorrect: false,
      textCapitalization: TextCapitalization.none,

      // ✅ CONFIRMATION MATCH CHECK VALIDATOR PIPELINE
      // ✅ পাসওয়ার্ড দুটির উইজেট ডাটা হুবহু মিলছে কিনা তা ইনস্ট্যান্ট ভ্যালিডেট করে
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please confirm your password.';
        }
        // 🚀 Matches the entered string directly against the text memory of the parent field controller
        if (value != passwordController.text) {
          return 'Passwords do not match.';
        }
        return null; // Passed verification smoothly
      },
    );
  }
}
