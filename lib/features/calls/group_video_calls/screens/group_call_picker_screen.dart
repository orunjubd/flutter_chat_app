import 'package:chat_app/features/calls/group_video_calls/screens/group_video_call_screen.dart';
import 'package:chat_app/features/calls/group_voice_calls/screens/group_voice_call_screen.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/calls/core/policies/group_call_policy.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';
// + imports: conversationsProvider, userByIdProvider, GroupVideoCallScreen

class GroupCallPickerScreen extends ConsumerStatefulWidget {
  const GroupCallPickerScreen({super.key, this.type = CallType.video});

  final CallType type;

  @override
  ConsumerState<GroupCallPickerScreen> createState() => _State();
}

class _State extends ConsumerState<GroupCallPickerScreen> {
  static const _policy = GroupCallPolicy();
  final _selected = <String, String>{}; // uid -> name

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final conversations = ref.watch(conversationsProvider).value ?? const [];
    final peerIds = {
      for (final c in conversations)
        for (final id in c.participantIds)
          if (id != myUid) id,
    }.toList();

    final problem = _selected.isEmpty
        ? null
        : _policy.validateStart(
            type: widget.type, // Maps audio/video constraints dynamically
            inviteeCount: _selected.length,
          );
    final canStart = _selected.isNotEmpty && problem == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == CallType.voice
              ? 'New group voice call'
              : 'New group video call',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (final id in peerIds)
                  Consumer(
                    builder: (context, ref, _) {
                      final user = ref.watch(userByIdProvider(id)).value;
                      final name = user?.username ?? id;
                      final hasImage = (user?.imageUrl ?? '').trim().isNotEmpty;
                      return CheckboxListTile(
                        value: _selected.containsKey(id),
                        title: Text(name),
                        secondary: CircleAvatar(
                          backgroundImage: hasImage
                              ? NetworkImage(user!.imageUrl)
                              : null,
                          child: hasImage
                              ? null
                              : Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                ),
                        ),
                        onChanged: (v) => setState(() {
                          v == true
                              ? _selected[id] = name
                              : _selected.remove(id);
                        }),
                      );
                    },
                  ),
              ],
            ),
          ),
          if (problem != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                problem,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                icon: Icon(
                  widget.type == CallType.voice ? Icons.call : Icons.videocam,
                ),
                label: Text('Start call (${_selected.length + 1})'),
                onPressed: canStart ? _start : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _start() async {
    final me = FirebaseAuth.instance.currentUser!;
    final myProfile = await ref.read(currentUserProvider.future);
    if (!mounted) return;

    // Compile unified profile collection maps for current user and chosen contacts
    final Map<String, String> names = {
      me.uid: myProfile?.username ?? 'Me',
      ..._selected,
    };

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => widget.type == CallType.voice
            ? GroupVoiceCallScreen.outgoing(
                inviteeIds: _selected.keys.toList(),
                names: names,
              )
            : GroupVideoCallScreen.outgoing(
                type: widget.type,
                inviteeIds: _selected.keys.toList(),
                names: names,
              ),
      ),
    );
  }
}
