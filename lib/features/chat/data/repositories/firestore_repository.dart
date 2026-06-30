import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/features/chat/data/models/app_user.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class FirestoreRepository {
  FirestoreRepository();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get messagesCollection =>
      _firestore.collection('messages');

  Future<void> createUser(AppUser user) async {
    await usersCollection.doc(user.id).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    final document = await usersCollection.doc(uid).get();

    if (!document.exists) {
      return null;
    }

    return AppUser.fromMap(document.id, document.data()!);
  }
}
