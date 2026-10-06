import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/calls/core/controllers/group_call_controller.dart';
import 'package:chat_app/features/calls/core/widgets/incoming_call_card.dart';
import 'package:chat_app/features/calls/video_calls/widgets/video_call_controls.dart';
import 'package:chat_app/features/calls/core/widgets/group_video_grid.dart';
import 'package:chat_app/features/calls/core/widgets/group_video_spotlight.dart';

class GroupVideoCallScreen extends ConsumerStatefulWidget {
  const GroupVideoCallScreen({super.key})
    : inviteeIds = const [],
      names = const {},
      conversationId = null;

  const GroupVideoCallScreen.outgoing({
    super.key,
    this.conversationId,
    required this.inviteeIds,
    required this.names,
  });

  final String? conversationId;
  final List<String> inviteeIds;
  final Map<String, String> names;

  static int instances = 0;

  @override
  ConsumerState<GroupVideoCallScreen> createState() =>
      _GroupVideoCallScreenState();
}

class _GroupVideoCallScreenState extends ConsumerState<GroupVideoCallScreen> {
  String? _pinned;
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    GroupVideoCallScreen.instances++;
    //final id = widget.conversationId;
    if (widget.inviteeIds.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(groupCallProvider.notifier)
            .startGroupVideoCall(
              conversationId: widget.conversationId,
              inviteeIds: widget.inviteeIds,
              names: widget.names,
            );
      });
    }
  }

  @override
  void dispose() {
    GroupVideoCallScreen.instances--;
    super.dispose();
  }

  void _popOnce() {
    if (_popped || !mounted || !Navigator.of(context).canPop()) return;
    _popped = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GroupCallUiState>(groupCallProvider, (prev, next) {
      final wasActive = prev != null && prev.phase != GroupCallPhase.idle;
      if (next.phase.isTerminal ||
          (wasActive && next.phase == GroupCallPhase.idle)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _popOnce());
      }
    });

    final s = ref.watch(groupCallProvider);
    final call = ref.read(groupCallProvider.notifier);
    final session = s.session;
    String nameOf(String uid) => session?.nameOf(uid) ?? uid;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        s.phase == GroupCallPhase.incoming
            ? call.declineIncoming()
            : call.leave();
      },
      child: switch (s.phase) {
        GroupCallPhase.incoming => IncomingCallCard(
          title: 'Incoming Group Video Call',
          icon: Icons.groups,
          callerName: session?.callerName ?? 'Unknown',
          actionsEnabled: true,
          onAccept: call.acceptIncoming,
          onDecline: call.declineIncoming,
        ),
        GroupCallPhase.connected => _connected(context, s, call, nameOf),
        _ => Scaffold(
          backgroundColor: context.callScreenBackground,
          body: Center(
            child: s.phase == GroupCallPhase.failed
                ? Text(
                    s.error ?? 'Call failed',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      },
    );
  }

  Widget _connected(
    BuildContext context,
    GroupCallUiState s,
    GroupCallController call,
    String Function(String) nameOf,
  ) {
    final pinned = s.participants
        .where((p) => p.identity == _pinned)
        .firstOrNull;
    return Scaffold(
      backgroundColor: context.callScreenBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 64, bottom: 120),
            child: pinned != null
                ? GroupVideoSpotlight(
                    main: pinned,
                    others: s.participants.where((p) => p != pinned).toList(),
                    nameOf: nameOf,
                    onTapParticipant: (uid) => setState(() => _pinned = uid),
                    onUnpin: () => setState(() => _pinned = null),
                  )
                : GroupVideoGrid(
                    participants: s.participants,
                    nameOf: nameOf,
                    onTapParticipant: (uid) => setState(() => _pinned = uid),
                  ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Group video · ${s.participants.length} in call',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: VideoCallControls(
                  controlsEnabled: true,
                  micEnabled: s.micEnabled,
                  cameraEnabled: s.cameraEnabled,
                  speakerOn: s.speakerOn,
                  onToggleMute: call.toggleMic,
                  onToggleCamera: call.toggleCamera,
                  onSwitchCamera: call.switchCamera,
                  onToggleSpeaker: call.toggleSpeaker,
                  onEndCall: call.leave,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
