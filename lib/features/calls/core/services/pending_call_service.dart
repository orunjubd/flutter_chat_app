import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingCallService {
  PendingCallService._();

  static const String _acceptedCallIdKey = 'pending_accepted_call_id';

  static final PendingCallService instance = PendingCallService._();

  /// Stores the call accepted from the native CallKit background UI.
  Future<void> setAcceptedCall(String callId) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_acceptedCallIdKey, callId);

    debugPrint('📞 [PendingCallService] Accepted call persisted → $callId');
  }

  /// Reads the pending accepted call and removes it immediately.
  ///
  /// This is a "consume once" operation.
  Future<String?> consumeAcceptedCall() async {
    final preferences = await SharedPreferences.getInstance();

    final callId = preferences.getString(_acceptedCallIdKey);

    if (callId == null || callId.isEmpty) {
      return null;
    }

    await preferences.remove(_acceptedCallIdKey);

    debugPrint('📞 [PendingCallService] Accepted call consumed → $callId');

    return callId;
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_acceptedCallIdKey);

    debugPrint('🧹 [PendingCallService] Pending accepted call cleared');
  }
}
