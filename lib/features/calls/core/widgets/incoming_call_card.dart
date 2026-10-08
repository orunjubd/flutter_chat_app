import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/calls/core/constants/call_strings.dart';
import 'package:flutter/material.dart';

class IncomingCallCard extends StatelessWidget {
  const IncomingCallCard({
    super.key,
    required this.title,
    required this.callerName,
    required this.icon,
    required this.actionsEnabled,
    required this.onAccept,
    required this.onDecline,
  });
  final String title;
  final String callerName;
  final IconData icon;
  final bool actionsEnabled;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.callScreenBackground,
      body: SafeArea(
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 56),
                const SizedBox(height: 16),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  callerName,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                IncomingCallActions(
                  enabled: actionsEnabled,
                  onAccept: onAccept,
                  onDecline: onDecline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── moved unchanged from voice_call_controls.dart ──
class IncomingCallActions extends StatelessWidget {
  const IncomingCallActions({
    super.key,
    required this.enabled,
    required this.onAccept,
    required this.onDecline,
  });
  final bool enabled;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _RoundAction(
          color: context.callDeclineColor,
          icon: Icons.call_end,
          label: CallStrings.decline,
          onTap: enabled ? onDecline : null,
        ),
        _RoundAction(
          color: context.callAcceptColor,
          icon: Icons.call,
          label: CallStrings.accept,
          onTap: enabled ? onAccept : null,
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: onTap == null ? color.withValues(alpha: 0.4) : color,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
