part of 'package:chat_app/features/chat/data/models/message.dart';

class ContactMessage extends Message {
  const ContactMessage({
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
    required this.contactName,
    required this.contactPhone,
    this.contactEmail,
    this.contactAddress,
  }) : super(type: 'contact');

  final String contactName;
  final String contactPhone;
  final String? contactEmail;
  final String? contactAddress;

  factory ContactMessage._fromMap(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return ContactMessage(
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
      contactName: data['contactName'] as String? ?? '',
      contactPhone: data['contactPhone'] as String? ?? '',
      contactEmail: data['contactEmail'] as String?,
      contactAddress: data['contactAddress'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    ...baseMap(),
    'contactName': contactName,
    'contactPhone': contactPhone,
    'contactEmail': contactEmail,
    'contactAddress': contactAddress,
  };

  @override
  Message withReply({
    required String replyToMessageId,
    required String replyToSenderId,
    required String replyToSenderName,
    required String replyToText,
  }) {
    return ContactMessage(
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
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      contactAddress: contactAddress,
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
    return ContactMessage(
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
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      contactAddress: contactAddress,
    );
  }
}
