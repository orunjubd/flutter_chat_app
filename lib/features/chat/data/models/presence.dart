import 'package:cloud_firestore/cloud_firestore.dart';

class Presence {
  const Presence({
    required this.userId,
    required this.isOnline,
    required this.lastSeen,
  });

  final String userId;
  final bool isOnline;
  final Timestamp lastSeen;

  factory Presence.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return Presence(
      userId: data['userId'] as String? ?? '',
      isOnline: data['isOnline'] as bool? ?? false,
      lastSeen: data['lastSeen'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'userId': userId, 'isOnline': isOnline, 'lastSeen': lastSeen};
  }
}
