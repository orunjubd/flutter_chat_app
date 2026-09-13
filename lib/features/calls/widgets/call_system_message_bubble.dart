// lib/features/calls/widgets/call_system_message_bubble.dart
import 'package:flutter/material.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/core/utils/date_time_formatter.dart';
import 'package:chat_app/features/calls/data/models/call_type.dart';
import 'package:chat_app/features/calls/data/models/call_history.dart';
import 'package:chat_app/features/chat/data/models/message.dart';

/// Renders a call-log entry as a centered system notice, matching
/// how WhatsApp/Telegram show call events — not a left/right chat
/// bubble, since this isn't content either party "sent."
class CallSystemMessageBubble extends StatelessWidget {
  const CallSystemMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onCallBack,
  });

  final CallSystemMessage message;
  final bool isMe;
  final VoidCallback? onCallBack;

  @override
  Widget build(BuildContext context) {
    final display = _displayFor(
      message.status,
      message.callType,
      message.durationSeconds,
      isMe,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: GestureDetector(
          onTap: onCallBack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 260),
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.isDarkMode ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (display.color ?? context.textSecondaryColor)
                        .withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    display.icon,
                    size: 16,
                    color: display.color ?? context.textSecondaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        display.label,
                        style: context.bodyTextMedium?.copyWith(
                          color: display.color ?? context.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateTimeFormatter.messageTime(
                          message.createdAt.toDate(),
                        ),
                        style: context.captionText?.copyWith(
                          color: context.textSecondaryColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _CallDisplay _displayFor(
    CallHistoryStatus status,
    CallType type,
    int? durationSeconds,
    bool isMe,
  ) {
    final typeLabel = type == CallType.video ? 'Video call' : 'Voice call';
    final typeIcon = type == CallType.video
        ? Icons.videocam_outlined
        : Icons.call_outlined;

    switch (status) {
      case CallHistoryStatus.completed:
        final duration = durationSeconds != null
            ? ' · ${_formatDuration(durationSeconds)}'
            : '';
        return _CallDisplay(
          icon: typeIcon,
          label: '$typeLabel$duration',
          color: null,
        );
      case CallHistoryStatus.missed:
        final label = isMe ? 'No answer' : 'Missed $typeLabel';
        return _CallDisplay(
          icon: Icons.call_missed,
          label: label,
          color: Colors.red,
        );
      case CallHistoryStatus.rejected:
        final label = isMe ? 'Call declined' : 'You declined this call';
        return _CallDisplay(
          icon: Icons.call_end,
          label: label,
          color: Colors.red,
        );
      case CallHistoryStatus.cancelled:
        return _CallDisplay(
          icon: Icons.call_end,
          label: 'Call cancelled',
          color: null,
        );
      case CallHistoryStatus.failed:
        return _CallDisplay(
          icon: Icons.error_outline,
          label: 'Call failed',
          color: Colors.red,
        );
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _CallDisplay {
  const _CallDisplay({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color? color;
}
