import 'package:flutter/material.dart';

import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/core/utils/date_time_formatter.dart';

class MessageDateSeparator extends StatelessWidget {
  const MessageDateSeparator({super.key, required this.date});

  final DateTime date;

  // String _label() {
  //   final today = DateTime.now();

  //   final todayOnly = DateTime(today.year, today.month, today.day);
  //   final target = DateTime(date.year, date.month, date.day);
  //   final difference = todayOnly.difference(target).inDays;
  //   if (difference == 0) {
  //     return 'Today';
  //   }
  //   if (difference == 1) {
  //     return 'Yesterday';
  //   }
  //   if (difference < 7) {
  //     return DateFormat('EEEE').format(date);
  //   }
  //   return DateFormat('dd MMM yyyy').format(date);
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            DateTimeFormatter.conversationTime(date),
            style: context.captionText?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
