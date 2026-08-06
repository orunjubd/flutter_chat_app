import 'package:chat_app/core/media/models/attachment_action.dart';
import 'package:flutter/material.dart';

class AttachmentSheet extends StatelessWidget {
  const AttachmentSheet({super.key, required this.actions});

  final List<AttachmentAction> actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Wrap(
          spacing: 28,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: actions.map((action) {
            return _AttachmentButton(
              icon: action.icon,
              label: action.title,
              color: action.color,
              enabled: action.enabled,
              onTap: () async {
                Navigator.pop(context);

                await action.onTap();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _AttachmentButton extends StatelessWidget {
  const _AttachmentButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.color = Colors.blue,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onTap;
  final bool enabled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final buttonColor = enabled ? color : Theme.of(context).disabledColor;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 88,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: buttonColor.withValues(alpha: .15),
              child: Icon(icon, color: buttonColor, size: 28),
            ),

            const SizedBox(height: 8),

            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: buttonColor, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
