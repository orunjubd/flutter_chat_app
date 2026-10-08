import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/calls/core/constants/call_strings.dart';
import 'package:chat_app/features/calls/core/controllers/group_call_controller.dart';
import 'package:chat_app/features/calls/core/widgets/incoming_call_card.dart';
import 'package:chat_app/features/calls/voice_calls/widgets/voice_call_controls.dart';
import '../widgets/group_voice_tile.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';

class GroupVoiceCallScreen extends ConsumerStatefulWidget {
  const GroupVoiceCallScreen({super.key})
    : conversationId = null,
      inviteeIds = const [],
      names = const {};

  const GroupVoiceCallScreen.outgoing({
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
  ConsumerState<GroupVoiceCallScreen> createState() =>
      _GroupVoiceCallScreenState();
}

class _GroupVoiceCallScreenState extends ConsumerState<GroupVoiceCallScreen> {
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    GroupVoiceCallScreen.instances++;
    if (widget.inviteeIds.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(groupCallProvider.notifier)
            .startGroupCall(
              type: CallType.voice,
              conversationId: widget.conversationId,
              inviteeIds: widget.inviteeIds,
              names: widget.names,
            );
      });
    }
  }

  @override
  void dispose() {
    GroupVoiceCallScreen.instances--;
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
          title: CallStrings.incomingGroupVoice,
          icon: Icons.groups,
          callerName: session?.callerName ?? CallStrings.unknownCaller,
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
                    s.error ?? CallStrings.callFailed,
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
    return Scaffold(
      backgroundColor: context.callScreenBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${CallStrings.groupVoiceCall} · ${s.participants.length} in call',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(8),
                children: [
                  for (final p in s.participants)
                    GroupVoiceTile(
                      participant: p,
                      displayName: nameOf(p.identity),
                    ),
                ],
              ),
            ),
            VoiceCallControls(
              controlsEnabled: true,
              onEndCall: call.leave,
              onToggleMute: call.toggleMic,
              onToggleSpeaker: call.toggleSpeaker,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
