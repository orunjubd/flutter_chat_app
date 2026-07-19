import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/providers/theme_provider.dart';

/// ---------------------------------------------------------------------------
/// ThemeBottomSheet
/// ---------------------------------------------------------------------------
///
/// Displays the application's available theme modes.
///
/// Responsibilities:
/// • Display available theme options.
/// • Update ThemeProvider.
/// • Persist theme automatically through ThemeProvider.
/// • Close after selection.
///
/// This widget contains the theme selection logic while the
/// ThemeSelectorTile is responsible only for opening this sheet.
/// ---------------------------------------------------------------------------
class ThemeBottomSheet extends ConsumerWidget {
  const ThemeBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose Theme', style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 16),

            RadioGroup<ThemeMode>(
              groupValue: currentTheme,
              onChanged: (mode) async {
                await ref.read(themeProvider.notifier).setTheme(mode!);

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ThemeOption(
                    title: 'Light',
                    icon: Icons.light_mode_outlined,
                    value: ThemeMode.light,
                  ),
                  _ThemeOption(
                    title: 'Dark',
                    icon: Icons.dark_mode_outlined,
                    value: ThemeMode.dark,
                  ),
                  _ThemeOption(
                    title: 'Follow System',
                    icon: Icons.phone_android_outlined,
                    value: ThemeMode.system,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Internal Theme Option
/// ---------------------------------------------------------------------------
///
/// Reusable radio tile used by ThemeBottomSheet.
/// ---------------------------------------------------------------------------
class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.value,
  });

  final String title;
  final IconData icon;
  final ThemeMode value;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      value: value,
      secondary: Icon(icon),
      title: Text(title),
    );
  }
}
