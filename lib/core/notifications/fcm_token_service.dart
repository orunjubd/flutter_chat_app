// lib/core/notifications/fcm_token_service.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmTokenService {
  FcmTokenService();
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static String? _registeredForUserId;

  /// Keeps the FCM token registered for the current user.
  ///
  /// Safe to call multiple times for the SAME userId — subsequent
  /// calls are no-ops. Call again if the signed-in user actually
  /// changes (e.g. sign-out then a different account signs in).
  Future<void> registerToken(String userId) async {
    if (_registeredForUserId == userId) {
      return; // already registered for this user — nothing to do
    }
    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();
    if (token != null) {
      await _saveToken(userId, token);
    }
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = messaging.onTokenRefresh.listen((newToken) {
      _saveToken(userId, newToken);
    });
    _registeredForUserId = userId;
  }

  Future<void> _saveToken(String userId, String token) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _registeredForUserId = null;
  }
}
