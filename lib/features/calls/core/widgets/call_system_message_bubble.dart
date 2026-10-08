// lib/features/calls/widgets/call_system_message_bubble.dart
import 'package:flutter/material.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/core/utils/date_time_formatter.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';
import 'package:chat_app/features/calls/core/models/call_history.dart';
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
    );

    //final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;

    final bubbleColor = isMe ? context.myBubbleColor : context.otherBubbleColor;

    final primaryTextColor = isMe
        ? context.myBubbleTextPrimary
        : context.colorScheme.onSurface;

    final secondaryTextColor = isMe
        ? context.myBubbleTextPrimary.withValues(alpha: 0.65)
        : context.textSecondaryColor.withValues(alpha: 0.65);

    final statusColor = display.color ?? primaryTextColor;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: onCallBack,
        child: Container(
          // ------------------------------------------------------------
          // FIXED CONTEXTUAL WIDTH
          // ------------------------------------------------------------
          width: MediaQuery.of(context).size.width * 0.60,

          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(isMe ? 14 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 14),
            ),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------------
              // ROW 1
              // Call icon + Call type + Duration
              // ----------------------------------------------------------
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withValues(alpha: 0.12),
                    ),
                    child: Icon(display.icon, size: 20, color: statusColor),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      message.callType == CallType.video
                          ? 'Video call'
                          : 'Voice call',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyTextMedium?.copyWith(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  if (message.status == CallHistoryStatus.completed &&
                      message.durationSeconds != null) ...[
                    const SizedBox(width: 10),
                    Text(
                      _formatDuration(message.durationSeconds!),
                      style: context.captionText?.copyWith(
                        color: secondaryTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 6),

              // ----------------------------------------------------------
              // DIVIDER
              // ----------------------------------------------------------
              Container(
                height: 1,
                color: secondaryTextColor.withValues(alpha: 0.18),
              ),

              const SizedBox(height: 4),

              // ----------------------------------------------------------
              // ROW 2
              // Timestamp - right aligned
              // ----------------------------------------------------------
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateTimeFormatter.messageTime(message.createdAt.toDate()),
                  style: context.captionText?.copyWith(
                    color: secondaryTextColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _CallDisplay _displayFor(
    CallHistoryStatus status,
    CallType type,
    int? durationSeconds,
  ) {
    switch (status) {
      case CallHistoryStatus.completed:
        return _CallDisplay(
          icon: type == CallType.video
              ? Icons.videocam_outlined
              : Icons.call_outlined,
          label: 'Call completed',
          color: null,
        );

      case CallHistoryStatus.missed:
        return _CallDisplay(
          icon: Icons.call_missed_outlined,
          label: 'Missed Call',
          color: Colors.red,
        );

      case CallHistoryStatus.rejected:
        return _CallDisplay(
          icon: Icons.call_end_outlined,
          label: 'Call Declined',
          color: Colors.red,
        );

      case CallHistoryStatus.cancelled:
        return _CallDisplay(
          icon: Icons.call_end_outlined,
          label: 'Call Cancelled',
          color: null,
        );

      case CallHistoryStatus.failed:
        return _CallDisplay(
          icon: Icons.error_outline,
          label: 'Call Failed',
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
