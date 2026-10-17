import 'package:cloud_firestore/cloud_firestore.dart';

class TypingStatus {
  const TypingStatus({
    required this.userId,
    required this.username,
    required this.isTyping,
    required this.updatedAt,
    required this.conversationId,
  });

  final String userId;
  final String username;
  final bool isTyping;
  final Timestamp updatedAt;
  final String conversationId;

  factory TypingStatus.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return TypingStatus(
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      isTyping: data['isTyping'] as bool? ?? false,
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
      conversationId: data['conversationId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'isTyping': isTyping,
      'updatedAt': updatedAt,
      'conversationId': conversationId,
    };
  }
}
