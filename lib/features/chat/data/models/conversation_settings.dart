import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationSettings {
  const ConversationSettings({
    required this.conversationId,
    this.pinnedAt,
    this.archived = false,
    this.favorite = false,
    this.mutedUntil,
  });

  final String conversationId;
  final Timestamp? pinnedAt;
  final bool archived;
  final bool favorite;
  final Timestamp? mutedUntil;

  static ConversationSettings defaults(String id) =>
      ConversationSettings(conversationId: id);

  bool get pinned => pinnedAt != null;
  bool get isMuted =>
      mutedUntil != null && mutedUntil!.toDate().isAfter(DateTime.now());
  bool get isDefault => !pinned && !archived && !favorite && !isMuted;

  ConversationSettings copyWith({
    Timestamp? pinnedAt,
    bool clearPin = false,
    bool? archived,
    bool? favorite,
    Timestamp? mutedUntil,
    bool clearMute = false,
  }) => ConversationSettings(
    conversationId: conversationId,
    pinnedAt: clearPin ? null : (pinnedAt ?? this.pinnedAt),
    archived: archived ?? this.archived,
    favorite: favorite ?? this.favorite,
    mutedUntil: clearMute ? null : (mutedUntil ?? this.mutedUntil),
  );

  factory ConversationSettings.fromMap(String id, Map<String, dynamic> d) =>
      ConversationSettings(
        conversationId: id,
        pinnedAt: d['pinnedAt'] as Timestamp?,
        archived: d['archived'] as bool? ?? false,
        favorite: d['favorite'] as bool? ?? false,
        mutedUntil: d['mutedUntil'] as Timestamp?,
      );

  Map<String, dynamic> toMap() => {
    'pinnedAt': pinnedAt,
    'archived': archived,
    'favorite': favorite,
    'mutedUntil': mutedUntil,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  @override
  bool operator ==(Object other) =>
      other is ConversationSettings &&
      other.conversationId == conversationId &&
      other.pinnedAt == pinnedAt &&
      other.archived == archived &&
      other.favorite == favorite &&
      other.mutedUntil == mutedUntil;

  @override
  int get hashCode =>
      Object.hash(conversationId, pinnedAt, archived, favorite, mutedUntil);
}
