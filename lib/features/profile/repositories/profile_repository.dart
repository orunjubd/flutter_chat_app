import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles profile-related Firestore operations.
///
/// This repository owns the persistence layer only.
/// It does not know about:
/// - ImagePicker
/// - image compression
/// - Cloudinary
/// - Riverpod
/// - UI
class ProfileRepository {
  ProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection {
    return _firestore.collection('users');
  }

  /// Updates the current user's profile photo URL.
  Future<void> updateProfileImageUrl({
    required String userId,
    required String imageUrl,
  }) async {
    await _usersCollection.doc(userId).update({'imageUrl': imageUrl});
  }

  /// Removes the profile photo reference from Firestore.
  ///
  /// We intentionally keep the field as an empty string instead of
  /// deleting the field. This keeps AppUser/imageUrl handling simple
  /// and consistent.
  Future<void> removeProfileImage({required String userId}) async {
    await _usersCollection.doc(userId).update({'imageUrl': ''});
  }
}
