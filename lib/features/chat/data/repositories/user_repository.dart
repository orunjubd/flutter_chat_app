import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/features/chat/data/models/app_user.dart';

class UserRepository {
  UserRepository();

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firebaseFirestore.collection('users');

  // ------------------------------------------------------------
  // Stream all users except myself
  // ------------------------------------------------------------
  Stream<List<AppUser>> usersStream({required String currentUserId}) {
    return usersCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map(AppUser.fromFirestore)
          .where((user) => user.id != currentUserId)
          .toList();
    });
  }

  // ------------------------------------------------------------
  // Get one user
  // ------------------------------------------------------------
  Future<AppUser?> getUser(String uid) async {
    final doc = await usersCollection.doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return AppUser.fromFirestore(doc);
  }

  // ------------------------------------------------------------
  // Get user by ID
  // ------------------------------------------------------------
  Future<AppUser?> getUserById(String userId) async {
    final document = await usersCollection.doc(userId).get();

    if (!document.exists) {
      return null;
    }

    return AppUser.fromFirestore(document);
  }

  // ------------------------------------------------------------
  // Search users
  // (implemented later)
  // ------------------------------------------------------------
}
