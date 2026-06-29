import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ Imports core cloud engine packages
import 'package:chat_app/firebase_options.dart'; // ✅ Imports your newly generated options file
import 'package:chat_app/features/authentication/presentation/screens/auth_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // ✅ 1. Ensures native mobile channels communicate correctly before running async hooks
  // ✅ অ্যাসিঙ্ক অপারেশন শুরু করার আগে ফ্লাটার ফ্রেমওয়ার্ক ইঞ্জিন লক নিশ্চিত করে
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 2. Executes the live cloud handshake using your dynamic platform options
  // ✅ জেনারেট হওয়া ফাইলটি ব্যবহার করে ফায়ারবেস ক্লাউডের সাথে কানেকশন তৈরি করে
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat',
      debugShowCheckedModeBanner: false, // Disables debug banner banner flag
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 97, 84),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 255, 255),
          brightness: Brightness.dark,
        ),
      ),
      home: const AuthScreen(),
    );
  }
}
