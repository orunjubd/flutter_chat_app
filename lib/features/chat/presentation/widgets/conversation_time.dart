import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/core/utils/date_time_formatter.dart';

class ConversationTime extends StatelessWidget {
  const ConversationTime({super.key, required this.timestamp});

  final Timestamp timestamp;

  @override
  Widget build(BuildContext context) {
    final lastTime = DateTimeFormatter.conversationTime(timestamp.toDate());

    return Text(
      lastTime,
      style: context.captionText?.copyWith(color: context.textSecondaryColor),
    );
  }
}
