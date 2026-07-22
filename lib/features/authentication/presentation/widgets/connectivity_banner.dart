import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:chat_app/features/authentication/providers/connectivity_provider.dart';

class ConnectivityBanner extends ConsumerStatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  ConsumerState<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends ConsumerState<ConnectivityBanner> {
  bool _showConnected = false;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();

    ref.listenManual(connectivityProvider, (previous, next) {
      next.whenData((results) {
        final isOnline = results.any((r) => r != ConnectivityResult.none);

        if (!isOnline) {
          // Remember that we went offline.
          _wasOffline = true;

          if (_showConnected && mounted) {
            setState(() {
              _showConnected = false;
            });
          }
          return;
        }

        // Only show "Back Online" if we were previously offline.
        if (_wasOffline) {
          _wasOffline = false;

          if (mounted) {
            setState(() {
              _showConnected = true;
            });
          }

          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;

            setState(() {
              _showConnected = false;
            });
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = ref.watch(connectivityProvider);

    return connectivity.when(
      loading: () => const SizedBox.shrink(),

      error: (_, __) => const _Banner(
        color: AppColors.error,
        icon: Icons.wifi_off,
        text: 'Network unavailable',
      ),

      data: (results) {
        final isOnline = results.any((r) => r != ConnectivityResult.none);

        if (!isOnline) {
          return const _Banner(
            color: AppColors.error,
            icon: Icons.wifi_off,
            text: 'No Internet Connection',
          );
        }

        if (_showConnected) {
          return const _Banner(
            color: AppColors.success,
            icon: Icons.wifi,
            text: 'Back Online',
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.color, required this.icon, required this.text});

  final Color color;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(icon, color: AppColors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: context.textTheme.labelLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
