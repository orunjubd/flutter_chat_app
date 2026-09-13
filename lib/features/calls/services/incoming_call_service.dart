// features/calls/services/incoming_call_service.dart
import 'package:flutter_callkit_incoming_maintained/entities/call_event.dart';
import 'package:flutter_callkit_incoming_maintained/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming_maintained/entities/android_params.dart';
import 'package:flutter_callkit_incoming_maintained/entities/notification_params.dart';
import 'package:flutter_callkit_incoming_maintained/flutter_callkit_incoming_maintained.dart';

class IncomingCallService {
  const IncomingCallService();

  /// Shows the native incoming-call UI (CallKit on iOS, a custom
  /// full-screen notification backed by ConnectionService on Android).
  Future<void> showIncomingCall({
    required String callId,
    required String callerName,
    String? callerAvatarUrl,
    required bool isVideoCall,
  }) async {
    final params = CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: 'Chat App',
      avatar: callerAvatarUrl,
      handle: callerName,
      type: isVideoCall ? 1 : 0, // 0 = audio, 1 = video
      duration: 30000, // auto-timeout if unanswered, ms
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
      ),
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  Future<void> endCall(String callId) => FlutterCallkitIncoming.endCall(callId);

  /// Stream of accept/decline/timeout events — wire this up once, near
  /// app startup, to route into your CallProvider / navigate to
  /// ActiveCallScreen.
  Stream<CallEvent?> get events => FlutterCallkitIncoming.onEvent;
}
