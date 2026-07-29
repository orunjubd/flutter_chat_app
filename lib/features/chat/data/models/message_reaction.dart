import 'package:cloud_firestore/cloud_firestore.dart';

class MessageReaction {
  const MessageReaction({
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  final String userId;
  final String emoji;
  final Timestamp createdAt;

  factory MessageReaction.fromMap(Map<String, dynamic> map) {
    return MessageReaction(
      userId: map['userId'] as String,
      emoji: map['emoji'] as String,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'emoji': emoji, 'createdAt': createdAt};
  }
}
