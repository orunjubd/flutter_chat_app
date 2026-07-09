import 'package:cloud_firestore/cloud_firestore.dart';

class TypingStatus {
  const TypingStatus({
    required this.userId,
    required this.username,
    required this.isTyping,
    required this.updatedAt,
  });

  final String userId;
  final String username;
  final bool isTyping;
  final Timestamp updatedAt;

  factory TypingStatus.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return TypingStatus(
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      isTyping: data['isTyping'] as bool? ?? false,
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'isTyping': isTyping,
      'updatedAt': updatedAt,
    };
  }
}
