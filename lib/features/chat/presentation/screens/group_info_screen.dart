import 'package:chat_app/features/chat/data/models/conversation.dart';
//import 'package:chat_app/features/chat/policies/group_policy.dart';
import 'package:chat_app/features/chat/presentation/screens/add_group_members_screen.dart';
import 'package:chat_app/features/chat/presentation/widgets/group_avatar.dart';
import 'package:chat_app/features/chat/presentation/widgets/group_chat_edit_dialog.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/features/chat/providers/group_provider.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:chat_app/features/chat/services/group_avatar_service.dart';
import 'package:chat_app/features/profile/presentation/screens/user_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupInfoScreen extends ConsumerWidget {
  const GroupInfoScreen({super.key, required this.groupId});
  final String groupId;

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e, st) {
      debugPrint('❌ [Group] action failed: $e');
      debugPrintStack(stackTrace: st);
      if (!context.mounted) return;
      final msg = e is StateError
          ? e.message
          : (e is ArgumentError ? '${e.message}' : 'Action failed.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String body,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (d) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ) ??
      false;

  Future<String> _myName(WidgetRef ref) async =>
      (await ref.read(currentUserProvider.future))?.username ?? 'Someone';

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    Conversation c,
    String me,
  ) async {
    final result = await showDialog<GroupEditResult>(
      context: context,
      builder: (_) => GroupEditDialog(
        initialName: c.name ?? '',
        initialDescription: c.description ?? '',
      ),
    );

    if (result == null || !context.mounted) return;

    await _run(
      context,
      () async => ref
          .read(groupRepositoryProvider)
          .updateInfo(
            groupId: c.id,
            actorId: me,
            actorName: await _myName(ref),
            name: result.name,
            description: result.description,
          ),
    );
  }

  Future<void> _changeAvatar(
    BuildContext context,
    WidgetRef ref,
    Conversation c,
    String me,
  ) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (s) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(s, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(s, 'camera'),
            ),
            if ((c.avatarUrl ?? '').isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove photo'),
                onTap: () => Navigator.pop(s, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final service = ref.read(groupAvatarServiceProvider);
      final name = await _myName(ref);
      if (choice == 'remove') {
        await service.remove(groupId: c.id, actorId: me, actorName: name);
      } else {
        await service.change(
          groupId: c.id,
          actorId: me,
          actorName: name,
          fromCamera: choice == 'camera',
        );
      }
    } catch (e, st) {
      debugPrint('❌ [Group] avatar failed: $e');
      debugPrintStack(stackTrace: st);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update the group photo.')),
        );
      }
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(conversationByIdProvider(groupId));
    final me = ref.watch(currentUserIdProvider);
    final loaded = ref.watch(conversationsProvider).hasValue;

    if (c == null || me == null) {
      // Removed or deleted: leave this screen.
      if (loaded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final repo = ref.read(groupRepositoryProvider);
    final isAdmin = c.isAdmin(me);
    final members = [...c.participantIds]
      ..sort((a, b) {
        final aa = c.isAdmin(a) ? 0 : 1, bb = c.isAdmin(b) ? 0 : 1;
        if (aa != bb) return aa - bb;
        return (c.joinedAt[a] ?? Timestamp.now()).compareTo(
          c.joinedAt[b] ?? Timestamp.now(),
        );
      });

    return Scaffold(
      appBar: AppBar(title: const Text('Group info')),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: c.can(me, GroupPermission.editInfo)
                  ? () => _changeAvatar(context, ref, c, me)
                  : null,
              child: Stack(
                children: [
                  GroupAvatar(
                    name: c.name ?? 'Group',
                    imageUrl: c.avatarUrl,
                    radius: 44,
                  ),
                  if (c.can(me, GroupPermission.editInfo))
                    const Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 14,
                        child: Icon(Icons.camera_alt, size: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              c.name ?? 'Group',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if ((c.description ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(c.description!, textAlign: TextAlign.center),
            ),
          Center(child: Text('${c.participantIds.length} members')),
          if (c.can(me, GroupPermission.editInfo))
            TextButton.icon(
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit name and description'),
              onPressed: () => _edit(context, ref, c, me),
            ),
          const Divider(),
          if (isAdmin)
            SwitchListTile(
              title: const Text('Members can send messages'),
              subtitle: const Text(
                'Off: only admins write, unless you allow a member',
              ),
              value: c.defaultPermissions.contains(GroupPermission.send.name),
              onChanged: (v) => _run(
                context,
                () => repo.setAllMembersCanSend(
                  groupId: c.id,
                  actorId: me,
                  enabled: v,
                ),
              ),
            ),
          if (c.can(me, GroupPermission.addMembers))
            ListTile(
              leading: const Icon(Icons.person_add_alt),
              title: const Text('Add members'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddGroupMembersScreen(groupId: c.id),
                ),
              ),
            ),
          const Divider(),
          for (final id in members)
            _MemberTile(
              group: c,
              memberId: id,
              me: me,
              runner: _run,
              confirm: _confirm,
              myName: _myName,
            ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Leave group',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () async {
              if (!await _confirm(
                context,
                'Leave group?',
                'You will stop receiving messages.',
              )) {
                return;
              }
              if (!context.mounted) return;
              await _run(
                context,
                () async => repo.leave(
                  groupId: c.id,
                  uid: me,
                  name: await _myName(ref),
                ),
              );
              if (context.mounted) {
                Navigator.of(context).popUntil((r) => r.isFirst);
              }
            },
          ),
          if (isAdmin)
            ListTile(
              leading: Icon(
                Icons.delete_forever,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete group',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () async {
                if (!await _confirm(
                  context,
                  'Delete group?',
                  'The group disappears for everyone.',
                )) {
                  return;
                }
                if (!context.mounted) return;
                await _run(
                  context,
                  () => repo.deleteGroup(groupId: c.id, actorId: me),
                );
                if (context.mounted) {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                }
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MemberTile extends ConsumerWidget {
  const _MemberTile({
    required this.group,
    required this.memberId,
    required this.me,
    required this.runner,
    required this.confirm,
    required this.myName,
  });
  final Conversation group;
  final String memberId, me;
  final Future<void> Function(BuildContext, Future<void> Function()) runner;
  final Future<bool> Function(BuildContext, String, String) confirm;
  final Future<String> Function(WidgetRef) myName;

  bool _has(GroupPermission p) =>
      group.permissions[memberId]?.contains(p.name) ?? false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userByIdProvider(memberId)).value;
    final name = user?.username ?? memberId;
    final targetIsAdmin = group.isAdmin(memberId);
    final repo = ref.read(groupRepositoryProvider);
    final viewerIsAdmin = group.isAdmin(me);

    Future<void> toggle(GroupPermission p) => runner(
      context,
      () => repo.setPermission(
        groupId: group.id,
        actorId: me,
        targetId: memberId,
        permission: p,
        enabled: !_has(p),
      ),
    );

    return ListTile(
      leading: GroupAvatar(name: name, imageUrl: user?.imageUrl),
      title: Text(memberId == me ? '$name (You)' : name),
      subtitle: Text(
        targetIsAdmin
            ? 'Admin'
            : (_has(GroupPermission.send) ? 'Can send' : 'Read only'),
      ),
      onTap: memberId == me
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(userId: memberId),
              ),
            ),
      trailing: (viewerIsAdmin && memberId != me)
          ? PopupMenuButton<String>(
              onSelected: (v) async {
                switch (v) {
                  case 'send':
                    await toggle(GroupPermission.send);
                  case 'add':
                    await toggle(GroupPermission.addMembers);
                  case 'delete':
                    await toggle(GroupPermission.deleteMessages);
                  case 'edit':
                    await toggle(GroupPermission.editInfo);
                  case 'promote':
                  case 'demote':
                    await runner(
                      context,
                      () async => repo.setAdmin(
                        groupId: group.id,
                        actorId: me,
                        actorName: await myName(ref),
                        targetId: memberId,
                        targetName: name,
                        admin: v == 'promote',
                      ),
                    );
                  case 'remove':
                    if (!await confirm(
                      context,
                      'Remove $name?',
                      'They lose access to this group.',
                    )) {
                      return;
                    }
                    if (!context.mounted) return;
                    await runner(
                      context,
                      () async => repo.removeMember(
                        groupId: group.id,
                        actorId: me,
                        actorName: await myName(ref),
                        targetId: memberId,
                        targetName: name,
                      ),
                    );
                }
              },
              itemBuilder: (_) => targetIsAdmin
                  ? const [
                      PopupMenuItem(
                        value: 'demote',
                        child: Text('Remove admin'),
                      ),
                    ]
                  : [
                      PopupMenuItem(
                        value: 'send',
                        child: Text(
                          _has(GroupPermission.send)
                              ? 'Block from sending'
                              : 'Allow sending',
                        ),
                      ),
                      PopupMenuItem(
                        value: 'add',
                        child: Text(
                          _has(GroupPermission.addMembers)
                              ? 'Revoke add members'
                              : 'Allow add members',
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          _has(GroupPermission.deleteMessages)
                              ? 'Revoke delete messages'
                              : 'Allow delete messages',
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(
                          _has(GroupPermission.editInfo)
                              ? 'Revoke edit info'
                              : 'Allow edit info',
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'promote',
                        child: Text('Make admin'),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Text('Remove from group'),
                      ),
                    ],
            )
          : null,
    );
  }
}
