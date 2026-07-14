import 'package:intl/intl.dart';

class DateTimeFormatter {
  const DateTimeFormatter._();

  static String conversationTime(DateTime dateTime) {
    final now = DateTime.now();

    final local = dateTime.toLocal();

    if (_isSameDay(now, local)) {
      return DateFormat('hh:mm a').format(local);
    }

    final yesterday = now.subtract(const Duration(days: 1));

    if (_isSameDay(yesterday, local)) {
      return 'Yesterday';
    }

    final difference = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(local.year, local.month, local.day)).inDays;

    if (difference < 7) {
      return DateFormat('EEEE').format(local);
    }

    return DateFormat('dd/MM/yyyy').format(local);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
