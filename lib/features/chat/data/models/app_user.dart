import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.imageUrl,
    required this.createdAt,
    required this.isOnline,
  });

  final String id;
  final String username;
  final String email;
  final String imageUrl;
  final Timestamp createdAt;
  final bool isOnline;

  /// Convert AppUser → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'isOnline': isOnline,
    };
  }

  /// Convert Firestore Map → AppUser
  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      isOnline: map['isOnline'] ?? false,
    );
  }
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      id: doc
          .id, // Extracts the unique alphanumeric document string ID directly
      username: data['username'] as String? ?? '',
      email: data['email'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      isOnline: data['isOnline'] as bool? ?? false,
    );
  }
}
