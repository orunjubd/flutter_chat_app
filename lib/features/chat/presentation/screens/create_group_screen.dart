//import 'dart:math';

import 'package:chat_app/features/chat/data/models/conversation.dart';
import 'package:chat_app/features/chat/policies/group_policy.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/features/chat/providers/group_provider.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// + imports: conversationsProvider, userByIdProvider, groupRepositoryProvider,
//   GroupPolicy, ChatScreen

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});
  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  static const _policy = GroupPolicy();
  final _selected = <String>{};
  final _name = TextEditingController();
  bool _naming = false;
  bool _busy = false;
  String? _error;
  bool _membersCanSend = true;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      _busy = true;
      _error = null;
    });

    Conversation group;
    try {
      group = await ref
          .read(groupRepositoryProvider)
          .createGroup(
            creatorId: myUid,
            name: _name.text,
            memberIds: _selected.toList(),
            membersCanSend: _membersCanSend,
          );
    } catch (e, st) {
      debugPrint('❌ [CreateGroup] write failed: $e');
      debugPrintStack(stackTrace: st);
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e is ArgumentError
              ? '${e.message}'
              : 'Could not create the group.';
        });
      }
      return;
    }

    if (!mounted) return;
    // Created. Navigation problems are a different issue and must not look like a failed create.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ChatScreen(conversation: group)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_naming,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _naming = false);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_naming ? 'New group' : 'Add members')),
        body: _naming ? _nameStep() : _memberStep(),
      ),
    );
  }

  Widget _memberStep() {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final conversations = ref.watch(conversationsProvider).value ?? const [];
    final peerIds = {
      for (final c in conversations)
        if (!c.isGroup)
          for (final id in c.participantIds)
            if (id != myUid) id,
    }.toList();
    final problem = _selected.isEmpty
        ? null
        : _policy.validateCreate(_selected.length);

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              for (final id in peerIds)
                Consumer(
                  builder: (context, ref, _) {
                    final user = ref.watch(userByIdProvider(id)).value;
                    if (user?.isDeleted == true) return const SizedBox.shrink();

                    final name = user?.username ?? id;
                    final hasImage = (user?.imageUrl ?? '').trim().isNotEmpty;
                    return CheckboxListTile(
                      value: _selected.contains(id),
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
                      onChanged: (v) => setState(
                        () => v == true
                            ? _selected.add(id)
                            : _selected.remove(id),
                      ),
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
            child: FilledButton(
              onPressed: _selected.isNotEmpty && problem == null
                  ? () => setState(() => _naming = true)
                  : null,
              child: Text('Next (${_selected.length} selected)'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _nameStep() {
    final nameProblem = _name.text.isEmpty
        ? null
        : _policy.validateName(_name.text);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar: added once Profile Photos upload is finished (same code).
          TextField(
            controller: _name,
            autofocus: true,
            maxLength: GroupPolicy.maxNameLength,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Group name',
              errorText: nameProblem,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          SwitchListTile(
            title: const Text('Members can send messages'),
            subtitle: const Text(
              'Off: only admins can write until you allow someone',
            ),
            value: _membersCanSend,
            onChanged: (v) => setState(() => _membersCanSend = v),
          ),
          const Spacer(),
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy || _policy.validateName(_name.text) != null
                    ? null
                    : _create,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create group'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
