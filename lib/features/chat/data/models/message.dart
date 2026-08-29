import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';

part 'package:chat_app/core/video/models/video_message.dart';
part 'package:chat_app/core/location/models/location_message.dart';
part 'package:chat_app/core/contact/models/contact_message.dart';

/// Shared envelope for every message, regardless of content type.
/// Fields here are genuinely universal — true for every message,
/// not just some. Type-specific data lives on the subtypes.
sealed class Message {
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
    this.reactions = const {},
  });

  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final Timestamp createdAt;
  final List<String> readBy;
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
  final Map<String, List<String>> reactions;

  Map<String, dynamic> baseMap() => {
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
    'reactions': reactions,
  };

  Map<String, dynamic> toMap();

  /// Returns a copy of this message with reply-to fields set,
  /// preserving all other fields (including type-specific ones)
  /// exactly as they were.
  Message withReply({
    required String replyToMessageId,
    required String replyToSenderId,
    required String replyToSenderName,
    required String replyToText,
  });

  /// forward হিসেবে নতুন কপি ফেরত দেয়: নতুন id,
  /// sender, timestamp, forward metadata সেট করা,
  /// reply ফিল্ডগুলো ক্লিয়ার করা, আর টাইপ‑স্পেসিফিক ফিল্ডগুলো আগের মতো রাখা।
  Message asForwarded({
    required String newId,
    required String senderId,
    required String senderName,
    required Timestamp createdAt,
    required List<String> readBy,
    required String forwardedFromUserId,
    required String forwardedFromUserName,
  });

  static Map<String, List<String>> parseReactions(dynamic raw) {
    if (raw is! Map) return const <String, List<String>>{};
    return Map<String, List<String>>.from(
      raw.map(
        (key, value) => MapEntry<String, List<String>>(
          key.toString(),
          List<String>.from(value as List<dynamic>? ?? const []),
        ),
      ),
    );
  }

  factory Message.fromMap(String documentId, Map<String, dynamic> data) {
    final type = data['type'] as String? ?? 'text';

    switch (type) {
      case 'text':
        return TextMessage._fromMap(documentId, data);
      case 'video':
        return VideoMessage._fromMap(documentId, data);
      case 'location':
        return LocationMessage._fromMap(documentId, data);
      case 'contact':
        return ContactMessage._fromMap(documentId, data);
      default:
        // image, voice, file — not yet migrated off the flat shape.
        return LegacyMessage._fromMap(documentId, data);
    }
  }
}

class TextMessage extends Message {
  const TextMessage({
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
  }) : super(type: 'text');

  factory TextMessage._fromMap(String documentId, Map<String, dynamic> data) {
    return TextMessage(
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
    );
  }

  @override
  Map<String, dynamic> toMap() => baseMap();

  @override
  Message withReply({
    required String replyToMessageId,
    required String replyToSenderId,
    required String replyToSenderName,
    required String replyToText,
  }) {
    return TextMessage(
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
    // required String text, // add
  }) {
    return TextMessage(
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
    );
  }
}

/// Temporary holding type for message types not yet migrated off the
/// old flat shape: image, voice, file. Carries every legacy field
/// exactly as the old Message class did. As each type is migrated,
/// its fields move out of here into a proper subtype and out of
/// LegacyMessage. Once empty, delete this class.
class LegacyMessage extends Message {
  const LegacyMessage({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.text,
    required super.createdAt,
    required super.readBy,
    required super.type,
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
    this.imageUrl,
    this.imageWidth,
    this.imageHeight,
    this.thumbnailUrl,
    this.mimeType,
    this.mediaBytes,
    this.caption,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.voiceUrl,
    this.voiceDurationMs,
  });

  final String? imageUrl;
  final double? imageWidth;
  final double? imageHeight;
  final String? thumbnailUrl;
  final String? mimeType;
  final int? mediaBytes;
  final String? caption;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? voiceUrl;
  final int? voiceDurationMs;

  factory LegacyMessage._fromMap(String documentId, Map<String, dynamic> data) {
    return LegacyMessage(
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
      reactions: Message.parseReactions(data['reactions']),
      imageUrl: data['imageUrl'] as String?,
      imageWidth: (data['imageWidth'] as num?)?.toDouble(),
      imageHeight: (data['imageHeight'] as num?)?.toDouble(),
      thumbnailUrl: data['thumbnailUrl'] as String?,
      mimeType: data['mimeType'] as String?,
      mediaBytes: data['mediaBytes'] as int?,
      caption: data['caption'] as String?,
      fileUrl: data['fileUrl'] as String?,
      fileName: data['fileName'] as String?,
      fileSize: data['fileSize'] as int?,
      voiceUrl: data['voiceUrl'] as String?,
      voiceDurationMs: (data['voiceDurationMs'] as num?)?.toInt(),
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    ...baseMap(),
    'imageUrl': imageUrl,
    'imageWidth': imageWidth,
    'imageHeight': imageHeight,
    'thumbnailUrl': thumbnailUrl,
    'mimeType': mimeType,
    'mediaBytes': mediaBytes,
    'caption': caption,
    'fileUrl': fileUrl,
    'fileName': fileName,
    'fileSize': fileSize,
    'voiceUrl': voiceUrl,
    'voiceDurationMs': voiceDurationMs,
  };

  @override
  Message withReply({
    required String replyToMessageId,
    required String replyToSenderId,
    required String replyToSenderName,
    required String replyToText,
  }) {
    return LegacyMessage(
      id: id,
      senderId: senderId,
      senderName: senderName,
      text: text,
      createdAt: createdAt,
      readBy: readBy,
      type: type,
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
      imageUrl: imageUrl,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      thumbnailUrl: thumbnailUrl,
      mimeType: mimeType,
      mediaBytes: mediaBytes,
      caption: caption,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      voiceUrl: voiceUrl,
      voiceDurationMs: voiceDurationMs,
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
    return LegacyMessage(
      id: newId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      createdAt: createdAt,
      readBy: readBy,
      type: type,
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
      imageUrl: imageUrl,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      thumbnailUrl: thumbnailUrl,
      mimeType: mimeType,
      mediaBytes: mediaBytes,
      caption: caption,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      voiceUrl: voiceUrl,
      voiceDurationMs: voiceDurationMs,
    );
  }
}
