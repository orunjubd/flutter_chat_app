import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.imageUrl,
    required this.createdAt,
    required this.isOnline,
    this.phoneNumber = '',
    this.shareEmailWithGroupMembers = false,
    this.sharePhoneNumberWithGroupMembers = false,
    this.deletedAt,
  });

  final String id;
  final String username;
  final String email;
  final String imageUrl;
  final Timestamp createdAt;
  final bool isOnline;
  final String phoneNumber;
  final bool shareEmailWithGroupMembers;
  final bool sharePhoneNumberWithGroupMembers;
  final Timestamp? deletedAt;
  bool get isDeleted => deletedAt != null;

  /// Convert AppUser → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      // 'email': email,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'isOnline': isOnline,
      // 'phoneNumber': phoneNumber,
      'shareEmailWithGroupMembers': shareEmailWithGroupMembers,
      'sharePhoneNumberWithGroupMembers': sharePhoneNumberWithGroupMembers,
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
      phoneNumber: map['phoneNumber'] as String? ?? '',
      shareEmailWithGroupMembers:
          map['shareEmailWithGroupMembers'] as bool? ?? false,
      sharePhoneNumberWithGroupMembers:
          map['sharePhoneNumberWithGroupMembers'] as bool? ?? false,
      deletedAt: map['deletedAt'] as Timestamp?,
    );
  }
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return AppUser.fromMap(doc.id, data);
  }
}
