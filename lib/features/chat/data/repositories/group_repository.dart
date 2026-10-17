import 'package:chat_app/features/chat/data/models/conversation.dart';
import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/features/chat/policies/group_policy.dart';
import 'package:flutter/cupertino.dart';

class GroupRepository {
  GroupRepository({
    FirebaseFirestore? firestore,
    GroupPolicy policy = const GroupPolicy(),
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _policy = policy;
  final FirebaseFirestore _db;
  final GroupPolicy _policy;

  Future<Conversation> createGroup({
    required String creatorId,
    required String name,
    required List<String> memberIds,
    bool? membersCanSend,
    String? avatarUrl,
    String? description,
  }) async {
    final members = {...memberIds}..remove(creatorId); // no duplicates, no self
    final problem =
        _policy.validateName(name) ?? _policy.validateCreate(members.length);
    if (problem != null) throw ArgumentError(problem);

    final doc = _db.collection('conversations').doc();
    final now = Timestamp.now();
    final all = [creatorId, ...members];
    final canSend = membersCanSend ?? _policy.defaultMemberCanSend;
    final defaults = canSend ? [GroupPermission.send.name] : <String>[];

    final group = Conversation(
      id: doc.id,
      participantIds: all,
      createdAt: now,
      updatedAt: now,
      lastMessage: '',
      lastMessageTime: now,
      unreadCounts: {for (final id in all) id: 0},
      type: ConversationType.group,
      name: name.trim(),
      avatarUrl: avatarUrl,
      description: description,
      createdBy: creatorId,
      adminIds: [creatorId],
      defaultPermissions: defaults,
      permissions: {for (final id in members) id: List<String>.from(defaults)},
      joinedAt: {for (final id in all) id: now},
    );
    debugPrint('📡 [Group] creating ${doc.id}: ${group.toFirestore()}');

    await doc.set(group.toFirestore());
    // final systemMsgRef = doc.collection('messages').doc();
    // await systemMsgRef.set(

    // GroupSystemMessage(
    //   //id: systemMsgRef.id,
    //   id: doc.id,
    //   senderId: 'system_node',
    //   senderName: 'System',
    //   text: 'Group created',
    //   createdAt: now,
    //   readBy: [creatorId],
    //   deletedBy: const <String>[],
    //   deletedForEveryone: false,
    //   action: 'created',
    // );
    // // );
    // debugPrint('✅ [Group] created ${doc.id}');
    // return group;
    // 3. Create the system message reference.
    final systemMsgRef = doc.collection('messages').doc();

    // 4. Create the system message model.
    final systemMessage = GroupSystemMessage(
      id: systemMsgRef.id,
      senderId: 'system_node',
      senderName: 'System',
      text: 'Group created',
      createdAt: now,
      readBy: [creatorId],
      deletedBy: const <String>[],
      deletedForEveryone: false,
      action: 'created',
      actorId: creatorId,
    );

    // 5. Save both documents atomically.
    final batch = _db.batch();

    batch.set(doc, group.toFirestore());
    batch.set(systemMsgRef, systemMessage.toMap());

    await batch.commit();

    debugPrint('✅ [Group] created ${doc.id}');

    return group;
  }

  DocumentReference<Map<String, dynamic>> _ref(String id) =>
      _db.collection('conversations').doc(id);

  Future<Conversation> _load(
    Transaction tx,
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    final s = await tx.get(ref);
    if (!s.exists) throw StateError('Group not found.');
    final c = Conversation.fromFirestore(s);
    if (!c.isGroup) throw StateError('Not a group.');
    return c;
  }

  /// Updates the group and writes the system message in the same transaction.
  void _write(
    Transaction tx,
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, Object?> updates, {
    required String text,
    required String action,
    required String actorId,
    List<String> targetIds = const [],
  }) {
    final now = Timestamp.now();
    final msg = ref.collection('messages').doc();
    tx.update(ref, {
      ...updates,
      'lastMessage': text,
      'lastMessageTime': now,
      'updatedAt': now,
      'lastSenderName': null,
    });
    tx.set(
      msg,
      GroupSystemMessage(
        id: msg.id,
        text: text,
        createdAt: now,
        readBy: const [],
        deletedForEveryone: false,
        deletedBy: const [],
        action: action,
        actorId: actorId,
        targetIds: targetIds,
      ).toMap(),
    );
  }

  Future<void> addMembers({
    required String groupId,
    required String actorId,
    required String actorName,
    required Map<String, String> newMembers, // uid -> name
  }) => _db.runTransaction((tx) async {
    final ref = _ref(groupId);
    final c = await _load(tx, ref);
    if (!c.can(actorId, GroupPermission.addMembers)) {
      throw StateError('You cannot add members.');
    }
    final toAdd = newMembers.keys
        .where((id) => !c.participantIds.contains(id))
        .toList();
    if (toAdd.isEmpty) return;
    final problem = _policy.validateAdd(
      currentCount: c.participantIds.length,
      adding: toAdd.length,
    );
    if (problem != null) throw StateError(problem);
    final now = Timestamp.now();
    _write(
      tx,
      ref,
      {
        'participantIds': FieldValue.arrayUnion(toAdd),
        for (final id in toAdd) ...{
          'joinedAt.$id': now,
          'permissions.$id': c.defaultPermissions,
          'unreadCounts.$id': 0,
        },
      },
      text:
          '$actorName added ${toAdd.map((i) => newMembers[i] ?? i).join(', ')}',
      action: 'added',
      actorId: actorId,
      targetIds: toAdd,
    );
  });

  Future<void> setAdmin({
    required String groupId,
    required String actorId,
    required String actorName,
    required String targetId,
    required String targetName,
    required bool admin,
  }) {
    // =======================================================================
    // 👑 FEATURE 6.5: ATOMIC PRIVILEGE ACTION TRACKER (INJECTED START LOG)
    // =======================================================================
    debugPrint(
      '👑 [Group] setAdmin group=$groupId target=$targetId admin=$admin',
    );
    return _db
        .runTransaction((tx) async {
          final ref = _ref(groupId);
          final c = await _load(tx, ref);
          if (!c.isAdmin(actorId)) {
            throw StateError('Only admins can change admins.');
          }

          if (targetId == c.createdBy && actorId != c.createdBy) {
            throw StateError(
              'The group creator cannot be changed by other admins.',
            );
          }

          if (!c.participantIds.contains(targetId)) {
            throw StateError('Not a member.');
          }
          if (!admin && c.adminIds.where((a) => a != targetId).isEmpty) {
            throw StateError('A group needs at least one admin.');
          }
          _write(
            tx,
            ref,
            {
              'adminIds': admin
                  ? FieldValue.arrayUnion([targetId])
                  : FieldValue.arrayRemove([targetId]),
            },
            text: admin
                ? '$targetName is now an admin'
                : '$targetName is no longer an admin',
            action: admin ? 'promoted' : 'demoted',
            actorId: actorId,
            targetIds: [targetId],
          );
        })
        .then((_) {
          // =======================================================================
          // 👑 FEATURE 6.5: ATOMIC PRIVILEGE ACTION SUCCESS (INJECTED DONE LOG)
          // =======================================================================
          // ✅ REQUIREMENT MET: Fires '👑 done' output strictly after a verified transaction completion pass!
          // ✅ বাংলায়: এডমিন প্রমোশন ট্র্যানজেকশন সার্ভারে সফলভাবে সেভ হওয়া কনফর্ম করার ইন্ডিকেটর।
          debugPrint('👑 done');
        });
  }

  Future<void> removeMember({
    required String groupId,
    required String actorId,
    required String actorName,
    required String targetId,
    required String targetName,
  }) => _db.runTransaction((tx) async {
    final ref = _ref(groupId);
    final c = await _load(tx, ref);
    if (!c.isAdmin(actorId)) {
      throw StateError('Only admins can remove members.');
    }

    if (targetId == c.createdBy && actorId != c.createdBy) {
      throw StateError('The group creator cannot be changed by other admins.');
    }

    if (targetId == actorId) throw StateError('Use Leave group instead.');
    if (c.isAdmin(targetId)) throw StateError('Remove admin rights first.');
    if (!c.participantIds.contains(targetId)) return;
    _write(
      tx,
      ref,
      {
        'participantIds': FieldValue.arrayRemove([targetId]),
        'joinedAt.$targetId': FieldValue.delete(),
        'permissions.$targetId': FieldValue.delete(),
        'unreadCounts.$targetId': FieldValue.delete(),
      },
      text: '$actorName removed $targetName',
      action: 'removed',
      actorId: actorId,
      targetIds: [targetId],
    );
  });

  /// Per-member permission switch (no system message).
  Future<void> setPermission({
    required String groupId,
    required String actorId,
    required String targetId,
    required GroupPermission permission,
    required bool enabled,
  }) => _db.runTransaction((tx) async {
    final ref = _ref(groupId);
    final c = await _load(tx, ref);
    if (!c.isAdmin(actorId)) {
      throw StateError('Only admins can change permissions.');
    }
    if (!c.participantIds.contains(targetId)) throw StateError('Not a member.');
    tx.update(ref, {
      'permissions.$targetId': enabled
          ? FieldValue.arrayUnion([permission.name])
          : FieldValue.arrayRemove([permission.name]),
    });
  });

  /// "Members can send messages" for everyone, including future members.
  Future<void> setAllMembersCanSend({
    required String groupId,
    required String actorId,
    required bool enabled,
  }) => _db.runTransaction((tx) async {
    final ref = _ref(groupId);
    final c = await _load(tx, ref);
    if (!c.isAdmin(actorId)) throw StateError('Only admins can change this.');
    final op = enabled
        ? FieldValue.arrayUnion([GroupPermission.send.name])
        : FieldValue.arrayRemove([GroupPermission.send.name]);
    tx.update(ref, {
      'defaultPermissions': op,
      for (final id in c.participantIds)
        if (!c.isAdmin(id)) 'permissions.$id': op,
    });
  });

  Future<void> updateInfo({
    required String groupId,
    required String actorId,
    required String actorName,
    required String name,
    String? description,
  }) => _db.runTransaction((tx) async {
    final ref = _ref(groupId);
    final c = await _load(tx, ref);
    if (!c.can(actorId, GroupPermission.editInfo)) {
      throw StateError('You cannot edit group info.');
    }
    final problem = _policy.validateName(name);
    if (problem != null) throw ArgumentError(problem);
    final renamed = name.trim() != (c.name ?? '');
    final updates = <String, Object?>{
      'name': name.trim(),
      'description': description?.trim(),
    };
    if (renamed) {
      _write(
        tx,
        ref,
        updates,
        text: '$actorName renamed the group to "${name.trim()}"',
        action: 'renamed',
        actorId: actorId,
      );
    } else {
      tx.update(ref, updates);
    }
  });
  Future<void> updateAvatar({
    required String groupId,
    required String actorId,
    required String actorName,
    String? avatarUrl,
  }) => _db.runTransaction((tx) async {
    final ref = _ref(groupId);
    final c = await _load(tx, ref);
    if (!c.can(actorId, GroupPermission.editInfo)) {
      throw StateError('You cannot edit group info.');
    }
    _write(
      tx,
      ref,
      {'avatarUrl': avatarUrl ?? FieldValue.delete()},
      text: avatarUrl == null
          ? '$actorName removed the group photo'
          : '$actorName changed the group photo',
      action: 'avatar',
      actorId: actorId,
    );
  });

  Future<void> leave({
    required String groupId,
    required String uid,
    required String name,
  }) => _db.runTransaction((tx) async {
    final ref = _ref(groupId);
    final c = await _load(tx, ref);
    if (!c.participantIds.contains(uid)) return;
    final remaining = c.participantIds.where((id) => id != uid).toList();
    if (remaining.isEmpty) {
      tx.update(ref, {
        'participantIds': [],
        'adminIds': [],
        'deletedAt': Timestamp.now(),
      });
      return;
    }
    var admins = c.adminIds.where((a) => a != uid).toList();
    if (admins.isEmpty) {
      // Last admin leaving: promote the longest-standing member.
      remaining.sort(
        (a, b) => (c.joinedAt[a] ?? Timestamp.now()).compareTo(
          c.joinedAt[b] ?? Timestamp.now(),
        ),
      );
      admins = [remaining.first];
    }
    _write(
      tx,
      ref,
      {
        'participantIds': FieldValue.arrayRemove([uid]),
        'adminIds': admins, // full list: one op per field
        'joinedAt.$uid': FieldValue.delete(),
        'permissions.$uid': FieldValue.delete(),
        'unreadCounts.$uid': FieldValue.delete(),
      },
      text: '$name left',
      action: 'left',
      actorId: uid,
    );
  });

  /// Soft delete: nobody is a member any more, so it leaves every list.
  Future<void> deleteGroup({
    required String groupId,
    required String actorId,
  }) => _db.runTransaction((tx) async {
    final ref = _ref(groupId);
    final c = await _load(tx, ref);
    if (!c.isAdmin(actorId)) {
      throw StateError('Only admins can delete the group.');
    }
    tx.update(ref, {
      'participantIds': [],
      'adminIds': [],
      'deletedAt': Timestamp.now(),
      'deletedBy': actorId,
    });
  });
}
