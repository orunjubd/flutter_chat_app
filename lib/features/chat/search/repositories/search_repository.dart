import 'package:chat_app/features/chat/data/models/message.dart';

class SearchRepository {
  const SearchRepository();

  /// ==========================================================
  /// Search Messages
  ///
  /// Filters messages locally using the provided query.
  ///
  /// Search targets:
  /// • Message text
  /// • Sender name
  /// • Reply preview text
  /// • Reply sender name
  /// • Forwarded from username
  /// ==========================================================
  List<Message> search({
    required List<Message> messages,
    required String query,
  }) {
    final keyword = query.trim().toLowerCase();

    if (keyword.isEmpty) {
      return messages;
    }

    return messages.where((message) {
      bool contains(String? value) =>
          value?.toLowerCase().contains(keyword) ?? false;

      return contains(message.text) ||
          contains(message.senderName) ||
          contains(message.replyToText) ||
          contains(message.replyToSenderName) ||
          contains(message.forwardedFromUserName);
    }).toList();
  }
}
