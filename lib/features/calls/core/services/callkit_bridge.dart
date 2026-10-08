// features/calls/core/services/callkit_bridge.dart
//
// FIXES BUG #1 (two listeners) and BUG #3 (double ringtone).
//
// ONE subscription to CallKit, owned by one object, cancelled in one place.
// It also tracks which call ids are currently displayed on the NATIVE incoming
// screen — that flag is what stops CallAudioService from playing a second
// ringtone on top of the OS one.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming_maintained/entities/call_event.dart';
import 'package:flutter_callkit_incoming_maintained/entities/android_params.dart';
import 'package:flutter_callkit_incoming_maintained/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming_maintained/entities/notification_params.dart';
import 'package:flutter_callkit_incoming_maintained/flutter_callkit_incoming_maintained.dart';

typedef CallKitAction = Future<void> Function(String callId);

class CallKitBridge {
  CallKitBridge({
    required this.onAccept,
    required this.onDecline,
    required this.onTimeout,
    //required this.onNativeUiVisibilityChanged,
  });

  final CallKitAction onAccept;
  final CallKitAction onDecline;
  final CallKitAction onTimeout;
  //final ValueChanged<bool> onNativeUiVisibilityChanged;

  StreamSubscription<CallEvent?>? _subscription;

  /// Call ids currently showing the native full-screen incoming UI.
  final Set<String> _displayed = <String>{};

  /// Read by CallAudioService. True => the OS owns the ringtone right now.
  bool get isShowingNativeUi => _displayed.isNotEmpty;
  bool isShowing(String callId) => _displayed.contains(callId);

  // void _notifyNativeUiVisibility() {
  //   onNativeUiVisibilityChanged(_displayed.isNotEmpty);
  // }

  /// Subscribe exactly once. Calling twice is a no-op instead of leaking.
  void start() {
    if (_subscription != null) {
      debugPrint('⚠️ [CallKit] start() ignored — already listening.');
      return;
    }

    _subscription = FlutterCallkitIncoming.onEvent.listen(
      _handle,
      onError: (Object e, StackTrace st) {
        debugPrint('❌ [CallKit] listener error: $e');
        debugPrintStack(stackTrace: st);
      },
    );
    debugPrint('📞 [CallKit] bridge listening.');
  }

  static Future<bool> isActiveNatively(String callId) async {
    try {
      final calls = await FlutterCallkitIncoming.activeCalls();
      // for (final c in calls) {
      //   debugPrint('🔎 [CallKit] active: ${c.toJson()}');
      // }
      return calls.any((c) => c is Map && c.id == callId);
    } catch (e) {
      debugPrint('⚠️ [CallKit] activeCalls failed: $e');
    }
    return false;
  }

  static Future<void> endNative(String callId) async {
    try {
      await FlutterCallkitIncoming.endCall(callId);
    } catch (e) {
      debugPrint('⚠️ [CallKit] endNative failed: $e');
    }
  }

  /// Id of a call the user already accepted on the native UI, if any.
  /// Covers a cold start where the accept event was emitted before our
  /// listener existed (the plugin does not replay it).
  static Future<String?> acceptedNativeCallId() async {
    try {
      final calls = await FlutterCallkitIncoming.activeCalls();
      for (final c in calls) {
        if ((c as dynamic).isAccepted == true) return c.id;
      }
    } catch (e) {
      debugPrint('⚠️ [CallKit] acceptedNativeCallId unavailable: $e');
    }
    return null;
  }

  Future<void> _handle(CallEvent? event) async {
    if (event == null) return;

    switch (event) {
      case CallEventActionCallAccept(:final id):
        _displayed.remove(id);
        //_notifyNativeUiVisibility();
        debugPrint('📞 [CallKit] accept → $id');
        await onAccept(id);

      case CallEventActionCallDecline(:final id):
        _displayed.remove(id);
        //_notifyNativeUiVisibility();
        debugPrint('❌ [CallKit] decline → $id');
        await onDecline(id);

      case CallEventActionCallTimeout(:final id):
        _displayed.remove(id);
        //_notifyNativeUiVisibility();
        debugPrint('⌛ [CallKit] timeout → $id');
        await onTimeout(id);

      case CallEventActionCallEnded(:final id):
        _displayed.remove(id);
        // _notifyNativeUiVisibility();
        debugPrint('☎️ [CallKit] ended → $id');

      // Explicitly ignored — listed so a package upgrade that adds a case
      // breaks the build instead of silently doing nothing.
      case CallEventActionCallIncoming():
      case CallEventActionCallStart():
      case CallEventActionCallConnected():
      case CallEventActionCallCallback():
      case CallEventActionCallToggleHold():
      case CallEventActionCallToggleMute():
      case CallEventActionCallToggleDmtf():
      case CallEventActionCallToggleGroup():
      case CallEventActionCallToggleAudioSession():
      case CallEventActionDidUpdateDevicePushTokenVoip():
      case CallEventActionCallCustom():
        break;
    }
  }

  // --- showing / dismissing --------------------------------------------------
  /// Builds and shows the native incoming-call UI directly via the plugin,
  /// with NO instance-level tracking. This is the only variant safe to call
  /// from the background message-handler isolate, which cannot see this
  /// class's `_displayed` set — it's a separate isolate, not just a separate
  /// object. Do NOT call this from the main isolate; use the instance
  /// method `show()` there instead, or `isShowingNativeUi` silently goes
  /// stale and CallAudioService starts double-ringing again (bug #3).
  static Future<void> showRaw({
    required String callId,
    required String callerName,
    String? callerAvatarUrl,
    required bool isVideoCall,
    bool isGroup = false, // ignored
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (await isActiveNatively(callId)) {
      debugPrint(
        '🔔 [CallKit] showRaw skipped, already active natively → $callId',
      );
      return;
    }
    final params = CallKitParams(
      id: callId,
      nameCaller: isGroup ? '$callerName · Group' : callerName, // CHANGED,
      appName: 'ECE',
      avatar: callerAvatarUrl,
      handle: callerName,
      type: isVideoCall ? 1 : 0,
      duration: timeout.inMilliseconds,
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default', //'ece_ringtone',
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
    debugPrint('🔔 [CallKit] showRaw done → $callId');
  }

  Future<void> show({
    required String callId,
    required String callerName,
    String? callerAvatarUrl,
    required bool isVideoCall,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_displayed.contains(callId)) {
      debugPrint('🔔 [CallKit] show() skipped, already displayed → $callId');
      return; // never ring twice for one call
    }
    _displayed.add(callId);
    debugPrint('🔔 [CallKit] show() from main isolate → $callId');

    try {
      await showRaw(
        callId: callId,
        callerName: callerName,
        callerAvatarUrl: callerAvatarUrl,
        isVideoCall: isVideoCall,
        timeout: timeout,
      );
    } catch (e, st) {
      _displayed.remove(callId);
      debugPrint('❌ [CallKit] show() failed → $callId: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  /// FIXES BUG #4. Must be called on EVERY terminal transition, or the callee's
  /// phone keeps ringing after the caller cancels.
  Future<void> dismiss(String callId) async {
    _displayed.remove(callId);
    //  _notifyNativeUiVisibility();
    try {
      await FlutterCallkitIncoming.endCall(callId);
      debugPrint('🔕 [CallKit] dismissed → $callId');
    } catch (e) {
      debugPrint('❌ [CallKit] dismiss failed: $e');
    }
  }

  Future<void> dismissAll() async {
    final ids = List<String>.from(_displayed);
    _displayed.clear();
    //  _notifyNativeUiVisibility();
    for (final id in ids) {
      try {
        await FlutterCallkitIncoming.endCall(id);
      } catch (_) {}
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await dismissAll();
  }
}
