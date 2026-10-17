import 'package:chat_app/features/chat/data/models/app_user.dart';
import 'package:chat_app/features/profile/repositories/private_contact_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Add this provider only if your project doesn't already define it.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

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

  Future<AppUser?> fetchProfileById(String userId) async => null;

  /// Updates only the specified profile fields.
  ///
  /// Existing fields not included in [fields] remain unchanged.
  Future<void> updateProfile(String uid, Map<String, dynamic> fields) async {
    if (fields.isEmpty) {
      throw ArgumentError('Profile fields cannot be empty.');
    }
    debugPrint('🔥 [ProfileRepository] Updating profile for user: $uid');
    await _usersCollection.doc(uid).update(fields);
    debugPrint('✅ [ProfileRepository] Profile updated successfully.');
    //await userDocument.update(fields);
    //debugPrint('✅ [ProfileRepository] Profile updated successfully.');
  }

  /// Updates the phone number.
  // Future<void> updatePhoneNumber({
  //   required String userId,
  //   required String phoneNumber,
  // }) async {
  //   //await updateProfile(userId, {'phoneNumber': phoneNumber.trim()});
  //   await _firestore
  //       .collection('users')
  //       .doc(userId)
  //       .collection('private')
  //       .doc('phone')
  //       .set({'value': phoneNumber.trim()});
  // }
  Future<void> updatePhoneNumber({
    required String userId,
    required String phoneNumber,
  }) => PrivateContactRepository(
    firestore: _firestore,
  ).setPhone(userId, phoneNumber);

  /// Updates the email-sharing preference.
  Future<void> updateEmailSharing({
    required String userId,
    required bool enabled,
  }) async {
    await updateProfile(userId, {'shareEmailWithGroupMembers': enabled});
  }

  /// Updates the phone-sharing preference.
  Future<void> updatePhoneSharing({
    required String userId,
    required bool enabled,
  }) async {
    await updateProfile(userId, {'sharePhoneNumberWithGroupMembers': enabled});
  }

  /// Removes the profile photo URL.
  Future<void> removeProfileImage({required String userId}) async {
    await updateProfile(userId, {'imageUrl': ''});
  }
}
