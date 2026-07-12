import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConversationTime extends StatelessWidget {
  const ConversationTime({super.key, required this.timestamp});

  final Timestamp timestamp;

  @override
  Widget build(BuildContext context) {
    final date = timestamp.toDate();
    final now = DateTime.now();

    String text;

    if (DateUtils.isSameDay(date, now)) {
      text = DateFormat('hh:mm a').format(date);
    } else if (DateUtils.isSameDay(
      date,
      now.subtract(const Duration(days: 1)),
    )) {
      text = 'Yesterday';
    } else {
      text = DateFormat('dd MMM').format(date);
    }

    return Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey));
  }
}
