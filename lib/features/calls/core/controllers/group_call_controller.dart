import 'dart:async';

import 'package:chat_app/features/calls/core/models/call_state.dart';
import 'package:chat_app/features/calls/core/models/group_call_history_entry.dart';
import 'package:chat_app/features/calls/core/repositories/group_call_history_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/calls/core/controllers/call_controller.dart'; // callProvider, liveKit/token providers
import 'package:chat_app/features/calls/core/controllers/call_media_controller.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';
import 'package:chat_app/features/calls/core/models/group_call_session.dart';
import 'package:chat_app/features/calls/core/models/room_participant_view.dart';
import 'package:chat_app/features/calls/core/policies/group_call_policy.dart';
import 'package:chat_app/features/calls/core/repositories/group_call_signaling_repository.dart';
import 'package:chat_app/features/calls/core/services/call_audio_service.dart';
import 'package:chat_app/features/calls/core/utils/app_lifecycle_utils.dart';

enum GroupCallPhase { idle, incoming, connecting, connected, ended, failed }

extension GroupCallPhaseX on GroupCallPhase {
  bool get isBusy =>
      this == GroupCallPhase.incoming ||
      this == GroupCallPhase.connecting ||
      this == GroupCallPhase.connected;
  bool get isTerminal =>
      this == GroupCallPhase.ended || this == GroupCallPhase.failed;
}

class GroupCallUiState {
  const GroupCallUiState({
    this.phase = GroupCallPhase.idle,
    this.session,
    this.participants = const [],
    this.micEnabled = true,
    this.cameraEnabled = true,
    this.speakerOn = true,
    this.error,
  });
  final GroupCallPhase phase;
  final GroupCallSession? session;
  final List<RoomParticipantView> participants;
  final bool micEnabled, cameraEnabled, speakerOn;
  final String? error;

  GroupCallUiState copyWith({
    GroupCallPhase? phase,
    GroupCallSession? session,
    List<RoomParticipantView>? participants,
    bool? micEnabled,
    bool? cameraEnabled,
    bool? speakerOn,
    String? error,
    bool clearError = false,
  }) => GroupCallUiState(
    phase: phase ?? this.phase,
    session: session ?? this.session,
    participants: participants ?? this.participants,
    micEnabled: micEnabled ?? this.micEnabled,
    cameraEnabled: cameraEnabled ?? this.cameraEnabled,
    speakerOn: speakerOn ?? this.speakerOn,
    error: clearError ? null : (error ?? this.error),
  );

  static const idle = GroupCallUiState();
}

final groupCallSignalingRepositoryProvider =
    Provider<GroupCallSignalingRepository>(
      (ref) => GroupCallSignalingRepository(),
    );

final groupCallProvider =
    NotifierProvider<GroupCallController, GroupCallUiState>(
      GroupCallController.new,
    );
final groupCallHistoryRepositoryProvider = Provider(
  (ref) => GroupCallHistoryRepository(),
);

class GroupCallController extends Notifier<GroupCallUiState> {
  static const _policy = GroupCallPolicy();

  late final CallMediaController _media;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<GroupCallSession?>? _inboxSub;
  StreamSubscription<GroupCallSession?>? _callSub;
  StreamSubscription<List<RoomParticipantView>>? _partsSub;
  StreamSubscription<void>? _roomLostSub;
  bool _leaving = false;
  Timer? _ringTimer;
  DateTime? _joinedAt;
  String? _recordedCallId;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  GroupCallSignalingRepository get _repo =>
      ref.read(groupCallSignalingRepositoryProvider);

  @override
  GroupCallUiState build() {
    final room = ref.read(liveKitCallServiceProvider);
    _media = CallMediaController(callService: room);

    _partsSub = room.onParticipantsChanged.listen((p) {
      if (state.phase == GroupCallPhase.connected ||
          state.phase == GroupCallPhase.connecting) {
        state = state.copyWith(participants: p);
      }
    });

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _watchInbox(user.uid);
      } else {
        _inboxSub?.cancel();
        unawaited(_cleanup());
        state = GroupCallUiState.idle;
      }
    });

    ref.onDispose(() {
      _ringTimer?.cancel();
      _authSub?.cancel();
      _inboxSub?.cancel();
      _callSub?.cancel();
      _partsSub?.cancel();
      _roomLostSub?.cancel();
    });
    return GroupCallUiState.idle;
  }

  // --- incoming (foreground only in v1) --------------------------------------

  void _watchInbox(String uid) {
    _inboxSub?.cancel();
    _inboxSub = _repo.watchIncoming(uid).listen((s) {
      // =======================================================================
      // 📡 INCOMING STREAM DISMISSAL / NULL DETECTION BRANCH
      // =======================================================================
      if (s == null) {
        if (state.phase == GroupCallPhase.incoming) {
          unawaited(ref.read(callAudioServiceProvider).stopLoop());
          // ✅ REQUIREMENT MET: Triggered the missed call logger BEFORE resetting the state parameters!
          unawaited(_record(GroupCallOutcome.missed));
          state = GroupCallUiState.idle;
        }
        return;
      }
      if (s.id == state.session?.id || state.phase.isBusy) return;
      if (ref.read(callProvider).phase.isBusy) return; // already in a 1:1 call
      if (s.callerId == uid || !isAppInForeground) return;
      if (DateTime.now().difference(s.createdAt.toDate()) >
          const Duration(seconds: 60)) {
        return; // stale
      }
      state = GroupCallUiState(phase: GroupCallPhase.incoming, session: s);
      unawaited(
        ref.read(callAudioServiceProvider).startRingtone(handledByOs: false),
      );
    }, onError: (Object e) => debugPrint('❌ [GroupCall] inbox error: $e'));
  }

  Future<void> acceptIncoming() async {
    final s = state.session;
    final uid = _uid;
    if (s == null || uid == null || state.phase != GroupCallPhase.incoming) {
      return;
    }
    await ref.read(callAudioServiceProvider).stopLoop();
    state = state.copyWith(phase: GroupCallPhase.connecting, clearError: true);
    await _repo.join(s.id, uid);
    _watchCall(s.id);
    await _joinRoom(s);
  }

  Future<void> declineIncoming() async {
    final s = state.session;
    final uid = _uid;
    await ref.read(callAudioServiceProvider).stopLoop();
    await _record(GroupCallOutcome.declined);

    state = GroupCallUiState.idle;
    if (s != null && uid != null) await _repo.decline(s.id, uid);
  }

  // --- outgoing --------------------------------------------------------------

  Future<void> startGroupVideoCall({
    String? conversationId,
    required List<String> inviteeIds,
    required Map<String, String> names,
  }) async {
    final uid = _uid;
    if (uid == null) return _fail('No authenticated user.');
    if (state.phase.isBusy || ref.read(callProvider).phase.isBusy) {
      debugPrint('⚠️ [GroupCall] start ignored: already in a call');
      return;
    }
    final problem = _policy.validateStart(
      type: CallType.video,
      inviteeCount: inviteeIds.length,
    );
    if (problem != null) return _fail(problem);

    state = const GroupCallUiState(phase: GroupCallPhase.connecting);
    try {
      final session = await _repo.create(
        conversationId: conversationId,
        callerId: uid,
        callerName: names[uid],
        inviteeIds: inviteeIds,
        names: names,
        type: CallType.video,
      );
      state = state.copyWith(session: session);
      _watchCall(session.id);
      await _joinRoom(session);
      _ringTimer?.cancel();
      _ringTimer = Timer(
        GroupCallPolicy
            .ringTimeout, // 🚀 Perfectly utilizes your declared static configuration logic!
        () => unawaited(_repo.markUnansweredMissed(session.id)),
      );
    } catch (e) {
      _fail(e.toString());
    }
  }

  Future<void> _record(GroupCallOutcome outcome) async {
    final s = state.session;
    final uid = _uid;
    if (s == null || uid == null || _recordedCallId == s.id) return;
    _recordedCallId = s.id;
    final seconds = outcome == GroupCallOutcome.joined && _joinedAt != null
        ? DateTime.now().difference(_joinedAt!).inSeconds
        : null;
    try {
      await ref
          .read(groupCallHistoryRepositoryProvider)
          .record(
            uid: uid,
            session: s,
            outcome: outcome,
            durationSeconds: seconds,
          );
    } catch (e) {
      debugPrint('❌ [GroupHistory] save failed: $e');
    }
  }

  // --- room ------------------------------------------------------------------

  Future<void> _joinRoom(GroupCallSession s) async {
    final uid = _uid!;
    final room = ref.read(liveKitCallServiceProvider);
    try {
      room.groupMode = true;
      _media.reset(speakerOn: true);
      final token = await ref
          .read(callTokenServiceProvider)
          .fetchDevelopmentToken(
            roomName: s.roomName,
            participantIdentity: uid,
          );
      await room.connect(roomToken: token.participantToken);

      _roomLostSub?.cancel();
      // In group mode this only fires when OUR connection is gone for good.
      _roomLostSub = room.onPeerGone.listen((_) => unawaited(leave()));

      final mic = await _media.setMicrophoneEnabled(true);
      final cam = await _media.setCameraEnabled(true);
      final spk = await _media.setSpeakerphoneEnabled(true);

      state = state.copyWith(
        phase: GroupCallPhase.connected,
        participants: room.participants,
        micEnabled: mic.micEnabled,
        cameraEnabled: cam.cameraEnabled,
        speakerOn: spk.speakerOn,
      );
      _joinedAt = DateTime.now();
    } catch (e) {
      debugPrint('❌ [GroupCall] join failed: $e');
      await _repo.leave(s.id, uid);
      await _cleanup();
      _fail(e.toString());
    }
  }

  void _watchCall(String callId) {
    _callSub?.cancel();
    _callSub = _repo.watchCall(callId).listen((s) {
      if (s == null || s.isEnded) {
        if (state.phase.isBusy && !_leaving) {
          debugPrint('📴 [GroupCall] call ended remotely');
          unawaited(_record(GroupCallOutcome.joined));
          unawaited(_cleanup());
          state = state.copyWith(phase: GroupCallPhase.ended);
        }
        return;
      }
      state = state.copyWith(session: s);
    });
  }

  Future<void> leave() async {
    if (_leaving || !state.phase.isBusy) return;
    _leaving = true;
    final s = state.session;
    final uid = _uid;
    try {
      // Local teardown first, so a Firestore failure can't leave camera/mic on.
      await _cleanup();
      if (s != null && uid != null) await _repo.leave(s.id, uid);
    } catch (e) {
      debugPrint('⚠️ [GroupCall] leave write failed: $e');
    } finally {
      _leaving = false;
      await _record(GroupCallOutcome.joined);
      state = state.copyWith(phase: GroupCallPhase.ended);
    }
  }

  Future<void> _cleanup() async {
    _joinedAt = null;
    _callSub?.cancel();
    _callSub = null;
    _roomLostSub?.cancel();
    _ringTimer?.cancel();
    _roomLostSub = null;
    await ref.read(callAudioServiceProvider).stopLoop();
    final room = ref.read(liveKitCallServiceProvider);
    room.groupMode = false;
    await room.disconnect();
  }

  // --- media -----------------------------------------------------------------

  Future<void> toggleMic() async {
    final s = await _media.toggleMic();
    state = state.copyWith(micEnabled: s.micEnabled);
  }

  Future<void> toggleCamera() async {
    final s = await _media.toggleCamera();
    state = state.copyWith(cameraEnabled: s.cameraEnabled);
  }

  Future<void> toggleSpeaker() async {
    final s = await _media.toggleSpeaker();
    state = state.copyWith(speakerOn: s.speakerOn);
  }

  Future<void> switchCamera() => _media.switchCamera();

  void _fail(String message) {
    debugPrint('❌ [GroupCall] $message');
    state = GroupCallUiState(phase: GroupCallPhase.failed, error: message);
  }
}
