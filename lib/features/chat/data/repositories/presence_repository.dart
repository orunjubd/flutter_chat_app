import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/features/chat/data/models/presence.dart';

class PresenceRepository {
  PresenceRepository();

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _presenceCollection =>
      _firebaseFirestore.collection('presence');

  // ------------------------------------------------------------
  // Update online status
  // ------------------------------------------------------------
  Future<void> updatePresence(Presence presence) async {
    await _presenceCollection.doc(presence.userId).set(presence.toFirestore());
  }

  // ------------------------------------------------------------
  // Mark user offline
  // ------------------------------------------------------------
  Future<void> setOffline(String userId) async {
    await _presenceCollection.doc(userId).set({
      'userId': userId,
      'isOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ------------------------------------------------------------
  // Mark user online
  // ------------------------------------------------------------
  Future<void> setOnline(String userId) async {
    await _presenceCollection.doc(userId).set({
      'userId': userId,
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
      // When a user comes online, we don't want to overwrite the whole document.
      //  .set(..., SetOptions(merge: true)) updates only the specified fields.
    }, SetOptions(merge: true));
  }

  // ------------------------------------------------------------
  // Real-time presence stream
  // ------------------------------------------------------------
  Stream<Presence?> presenceStream(String userId) {
    return _presenceCollection.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return Presence.fromFirestore(snapshot);
    });
  }
}
