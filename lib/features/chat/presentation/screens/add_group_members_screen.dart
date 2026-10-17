import 'package:chat_app/features/chat/data/models/conversation.dart';
import 'package:chat_app/features/chat/presentation/widgets/group_avatar.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/features/chat/providers/group_provider.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddGroupMembersScreen extends ConsumerStatefulWidget {
  const AddGroupMembersScreen({super.key, required this.groupId});
  final String groupId;
  @override
  ConsumerState<AddGroupMembersScreen> createState() => _AddState();
}

class _AddState extends ConsumerState<AddGroupMembersScreen> {
  final _selected = <String, String>{};
  bool _busy = false;
  String? _error;

  Future<void> _add(Conversation group) async {
    final me = ref.read(currentUserIdProvider)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final myName =
          (await ref.read(currentUserProvider.future))?.username ?? 'Someone';
      await ref
          .read(groupRepositoryProvider)
          .addMembers(
            groupId: group.id,
            actorId: me,
            actorName: myName,
            newMembers: _selected,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('❌ [Group] add members failed: $e');
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e is StateError ? e.message : 'Could not add members.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(conversationByIdProvider(widget.groupId));
    final me = ref.watch(currentUserIdProvider);
    final all = ref.watch(conversationsProvider).value ?? const [];
    if (group == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final candidates = {
      for (final c in all)
        if (!c.isGroup)
          for (final id in c.participantIds)
            if (id != me && !group.participantIds.contains(id)) id,
    }.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Add members')),
      body: Column(
        children: [
          Expanded(
            child: candidates.isEmpty
                ? const Center(child: Text('No one else to add'))
                : ListView(
                    children: [
                      for (final id in candidates)
                        Consumer(
                          builder: (context, ref, _) {
                            final user = ref.watch(userByIdProvider(id)).value;
                            if (user?.isDeleted == true) {
                              return const SizedBox.shrink();
                            }
                            final name = user?.username ?? id;
                            return CheckboxListTile(
                              value: _selected.containsKey(id),
                              title: Text(name),
                              secondary: GroupAvatar(
                                name: name,
                                imageUrl: user?.imageUrl,
                              ),
                              onChanged: (v) => setState(
                                () => v == true
                                    ? _selected[id] = name
                                    : _selected.remove(id),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy || _selected.isEmpty
                      ? null
                      : () => _add(group),
                  child: Text('Add (${_selected.length})'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
