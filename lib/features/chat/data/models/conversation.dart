import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.participantIds,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCounts,
  });

  final String id;

  /// Exactly two users for now.
  final List<String> participantIds;

  final Timestamp createdAt;

  final Timestamp updatedAt;

  final String lastMessage;

  final Timestamp lastMessageTime;

  final Map<String, int> unreadCounts;

  factory Conversation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return Conversation(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? const []),
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageTime: data['lastMessageTime'] as Timestamp? ?? Timestamp.now(),
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? const {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
    };
  }
}
