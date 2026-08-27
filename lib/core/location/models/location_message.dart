part of 'package:chat_app/features/chat/data/models/message.dart';

class LocationMessage extends Message {
  const LocationMessage({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.text,
    required super.createdAt,
    required super.readBy,
    required super.deletedForEveryone,
    required super.deletedBy,
    super.deletedAt,
    super.replyToMessageId,
    super.replyToSenderId,
    super.replyToSenderName,
    super.replyToText,
    super.forwarded,
    super.forwardedFromUserId,
    super.forwardedFromUserName,
    super.reactions,
    required this.latitude,
    required this.longitude,
    this.address,
  }) : super(type: 'location');

  final double latitude;
  final double longitude;
  final String? address;

  factory LocationMessage._fromMap(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return LocationMessage(
      id: documentId,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      readBy: List<String>.from(data['readBy'] ?? const []),
      deletedForEveryone: data['deletedForEveryone'] as bool? ?? false,
      deletedBy: List<String>.from(data['deletedBy'] ?? const []),
      deletedAt: data['deletedAt'] as Timestamp?,
      replyToMessageId: data['replyToMessageId'] as String?,
      replyToSenderId: data['replyToSenderId'] as String?,
      replyToSenderName: data['replyToSenderName'] as String?,
      replyToText: data['replyToText'] as String?,
      forwarded: data['forwarded'] as bool? ?? false,
      forwardedFromUserId: data['forwardedFromUserId'] as String?,
      forwardedFromUserName: data['forwardedFromUserName'] as String?,
      reactions: Message.parseReactions(data['reactions']),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      address: data['address'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    ...baseMap(),
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
  };

  @override
  Message withReply({
    required String replyToMessageId,
    required String replyToSenderId,
    required String replyToSenderName,
    required String replyToText,
  }) {
    return LocationMessage(
      id: id,
      senderId: senderId,
      senderName: senderName,
      text: text,
      createdAt: createdAt,
      readBy: readBy,
      deletedForEveryone: deletedForEveryone,
      deletedBy: deletedBy,
      deletedAt: deletedAt,
      replyToMessageId: replyToMessageId,
      replyToSenderId: replyToSenderId,
      replyToSenderName: replyToSenderName,
      replyToText: replyToText,
      forwarded: forwarded,
      forwardedFromUserId: forwardedFromUserId,
      forwardedFromUserName: forwardedFromUserName,
      reactions: reactions,
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  @override
  Message asForwarded({
    required String newId,
    required String senderId,
    required String senderName,
    required Timestamp createdAt,
    required List<String> readBy,
    required String forwardedFromUserId,
    required String forwardedFromUserName,
  }) {
    return LocationMessage(
      id: newId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      createdAt: createdAt,
      readBy: readBy,
      deletedForEveryone: false,
      deletedBy: const [],
      deletedAt: null,
      replyToMessageId: null,
      replyToSenderId: null,
      replyToSenderName: null,
      replyToText: null,
      forwarded: true,
      forwardedFromUserId: forwardedFromUserId,
      forwardedFromUserName: forwardedFromUserName,
      reactions: const {},
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }
}
