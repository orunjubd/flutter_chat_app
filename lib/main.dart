import 'package:chat_app/core/media/providers/media_cache_cleanup_service_provider.dart';
import 'package:chat_app/core/providers/theme_provider.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/features/authentication/presentation/gate/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProviderScope.containerOf(
        context,
      ).read(mediaCacheCleanupServiceProvider).clearAll();
    });

    return MaterialApp(
      title: 'ECE Chat',
      debugShowCheckedModeBanner: false,

      // Light Theme (Default)
      theme: AppTheme.lightTheme,

      // Dark Theme
      darkTheme: AppTheme.darkTheme,

      // Current Theme
      themeMode: themeMode,

      home: const AuthGate(),
    );
  }
}
