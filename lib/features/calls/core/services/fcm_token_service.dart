// features/calls/services/fcm_token_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmTokenService {
  const FcmTokenService();

  /// Saves the current device's FCM token to the user's Firestore
  /// document, and keeps it updated if it ever refreshes.
  ///
  /// ASSUMPTION: users are stored at users/{uid} with the token field
  /// named `fcmToken`. Adjust if your AppUser document is shaped
  /// differently.
  Future<void> registerToken(String userId) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _saveToken(userId, token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _saveToken(userId, newToken);
    });
  }

  Future<void> _saveToken(String userId, String token) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }
}
