import 'package:chat_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message = 'Please wait...',
  });

  final bool isLoading;
  final Widget child;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,

        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.black.withValues(alpha: .54),
              child: Center(
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 22,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 18),
                        Text(message, style: context.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
