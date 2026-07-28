//import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    required this.readBy,
    required this.type,

    required this.deletedForEveryone,
    required this.deletedBy,
    this.deletedAt,

    this.replyToMessageId,
    this.replyToSenderId,
    this.replyToSenderName,
    this.replyToText,

    this.forwarded = false,
    this.forwardedFromUserId,
    this.forwardedFromUserName,
  });

  /// Firestore document ID
  final String id;

  /// UID of the sender
  final String senderId;

  /// Display name of the sender
  final String senderName;

  /// Message content
  final String text;

  /// Creation timestamp
  final Timestamp createdAt;

  /// Users who have read this message
  final List<String> readBy;

  /// Message type (text, image, etc.)
  final String type;

  final bool deletedForEveryone;
  final List<String> deletedBy;
  final Timestamp? deletedAt;

  final String? replyToMessageId;
  final String? replyToSenderId;
  final String? replyToSenderName;
  final String? replyToText;

  final bool forwarded;
  final String? forwardedFromUserId;
  final String? forwardedFromUserName;

  factory Message.fromMap(String documentId, Map<String, dynamic> data) {
    return Message(
      id: documentId,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      readBy: List<String>.from(data['readBy'] ?? const []),
      type: data['type'] as String? ?? 'text',

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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'createdAt': createdAt,
      'readBy': readBy,
      'type': type,

      'deletedForEveryone': deletedForEveryone,
      'deletedBy': deletedBy,
      'deletedAt': deletedAt,

      'replyToMessageId': replyToMessageId,
      'replyToSenderId': replyToSenderId,
      'replyToSenderName': replyToSenderName,
      'replyToText': replyToText,

      'forwarded': forwarded,
      'forwardedFromUserId': forwardedFromUserId,
      'forwardedFromUserName': forwardedFromUserName,
    };
  }
}
