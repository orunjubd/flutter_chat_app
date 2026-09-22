// features/calls/services/incoming_call_service.dart
import 'package:flutter_callkit_incoming_maintained/entities/call_event.dart';
import 'package:flutter_callkit_incoming_maintained/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming_maintained/entities/android_params.dart';
import 'package:flutter_callkit_incoming_maintained/entities/notification_params.dart';
import 'package:flutter_callkit_incoming_maintained/flutter_callkit_incoming_maintained.dart';

class IncomingCallService {
  // Was `const IncomingCallService()`. Switched to a factory singleton
  // because a const constructor can't hold the mutable Set below — but the
  // call sites (`IncomingCallService()` called from multiple places in
  // call_provider.dart) still need to land on the SAME instance so
  // `isShowingNativeUi` reflects whatever the last event actually did.

  factory IncomingCallService() => _instance;
  IncomingCallService._internal();
  static final IncomingCallService _instance = IncomingCallService._internal();

  /// Call ids for which the native incoming-call UI is currently on screen.
  /// This is what CallAudioCoordinator's isNativeIncomingUiVisible reads —
  /// so this set must be accurate, or you get either silence (never added)
  /// or a permanently-blocked in-app ringtone (never removed).
  final Set<String> _visibleCallIds = {};

  bool get isShowingNativeUi => _visibleCallIds.isNotEmpty;

  /// Shows the native incoming-call UI (CallKit on iOS, a custom
  /// full-screen notification backed by ConnectionService on Android).
  Future<void> showIncomingCall({
    required String callId,
    required String callerName,
    String? callerAvatarUrl,
    required bool isVideoCall,
  }) async {
    // Guard against showing the same call twice (e.g. a retried push) —
    // a second showCallkitIncoming for an id already on screen is at best
    // redundant, at worst a second overlapping native UI.
    if (!_visibleCallIds.add(callId)) return;
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

  Future<void> endCall(String callId) async {
    // Removal happens here, not scattered across every place that calls
    // endCall — one place owns "this call's native UI is gone now."
    _visibleCallIds.remove(callId);
    await FlutterCallkitIncoming.endCall(callId);
  }

  /// Stream of accept/decline/timeout events — wire this up once, near
  /// app startup, to route into your CallProvider / navigate to
  /// ActiveCallScreen.
  Stream<CallEvent?> get events => FlutterCallkitIncoming.onEvent;
}
