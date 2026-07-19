import 'package:chat_app/core/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/features/authentication/presentation/widgets/connectivity_banner.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFF1E4D40),

      drawer: const AppDrawer(), // ← Add this

      appBar: appBar,

      body: SafeArea(
        child: Column(
          children: [
            const ConnectivityBanner(),

            Expanded(child: body),
          ],
        ),
      ),

      floatingActionButton: floatingActionButton,
    );
  }
}
