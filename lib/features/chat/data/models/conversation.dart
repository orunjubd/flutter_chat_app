import 'package:cloud_firestore/cloud_firestore.dart';

enum ConversationType { direct, group }

enum GroupPermission { send, addMembers, deleteMessages, editInfo }

class Conversation {
  const Conversation({
    required this.id,
    required this.participantIds,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCounts,
    this.type = ConversationType.direct,
    this.name,
    this.avatarUrl,
    this.description,
    this.createdBy,
    this.lastSenderName,
    this.adminIds = const [],
    this.joinedAt = const {},
    this.clearedAt = const {},
    this.permissions = const {},
    this.defaultPermissions = const [],
    this.removedFor = const [],
  });

  final String id;
  final List<String> participantIds; // 2 users for direct, N for groups
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String lastMessage;
  final Timestamp lastMessageTime;
  final String? lastSenderName;
  final Map<String, int> unreadCounts;

  // Group fields (ignored for direct chats)
  final ConversationType type;
  final String? name;
  final String? avatarUrl;
  final String? description;
  final String? createdBy;
  final List<String> adminIds;
  final Map<String, Timestamp> joinedAt;
  final Map<String, Timestamp> clearedAt;
  final Map<String, List<String>> permissions; // uid -> GroupPermission names
  final List<String> defaultPermissions;
  final List<String> removedFor;

  bool get isGroup => type == ConversationType.group;
  bool isAdmin(String uid) => adminIds.contains(uid);

  bool can(String uid, GroupPermission p) =>
      !isGroup || isAdmin(uid) || (permissions[uid]?.contains(p.name) ?? false);

  bool canSend(String uid) => can(uid, GroupPermission.send);

  factory Conversation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return Conversation(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? const []),
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageTime: data['lastMessageTime'] as Timestamp? ?? Timestamp.now(),
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? const {}),
      type: data['type'] == 'group'
          ? ConversationType.group
          : ConversationType.direct,
      name: data['name'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      description: data['description'] as String?,
      createdBy: data['createdBy'] as String?,
      lastSenderName: data['lastSenderName'] as String?,
      adminIds: List<String>.from(data['adminIds'] ?? const []),
      joinedAt: {
        for (final e in ((data['joinedAt'] as Map?) ?? const {}).entries)
          e.key as String: e.value as Timestamp,
      },
      clearedAt:
          (data['clearedAt'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as Timestamp),
          ) ??
          {},
      permissions: {
        for (final e in ((data['permissions'] as Map?) ?? const {}).entries)
          e.key as String: List<String>.from(e.value as List),
      },
      defaultPermissions: List<String>.from(
        data['defaultPermissions'] ?? const [],
      ),
      removedFor: List<String>.from(data['removedFor'] ?? const []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'unreadCounts': unreadCounts,
      'type': type.name,
      'removedFor': removedFor,
      if (isGroup) ...{
        'name': name,
        'avatarUrl': avatarUrl,
        'description': description,
        'createdBy': createdBy,
        'adminIds': adminIds,
        'joinedAt': joinedAt,
        'permissions': permissions,
        'defaultPermissions': defaultPermissions,
        //'removedFor': removedFor,
      },
    };
  }
}
