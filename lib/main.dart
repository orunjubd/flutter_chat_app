import 'package:chat_app/core/navigation/app_navigator_key.dart';
import 'package:chat_app/features/calls/widgets/global_incoming_call_listener.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming_maintained/flutter_callkit_incoming_maintained.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/media/providers/media_cache_cleanup_service_provider.dart';
import 'package:chat_app/core/providers/theme_provider.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/features/authentication/presentation/gate/auth_gate.dart';
import 'firebase_options.dart';
import 'package:chat_app/features/calls/services/call_push_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FlutterCallkitIncoming.onBackgroundMessage(callKitBackgroundHandler);
  registerForegroundCallListener();
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
      navigatorKey: appNavigatorKey,
      title: 'ECE Chat',
      debugShowCheckedModeBanner: false,

      // Light Theme (Default)
      theme: AppTheme.lightTheme,

      // Dark Theme
      darkTheme: AppTheme.darkTheme,

      // Current Theme
      themeMode: themeMode,

      //home: const AuthGate(),
      home: const AuthGate(),
      builder: (context, child) {
        // Wraps the entire Navigator — every pushed route, at any
        // depth — not just the initial `home` route's content. This
        // is what actually makes the incoming-call overlay global.
        return GlobalIncomingCallListener(
          child: child ?? const SizedBox.shrink(),
        );
        //final safeChild = child ?? const SizedBox.shrink();
        // return GlobalIncomingCallListener(child: safeChild);
      },
    );
  }
}
