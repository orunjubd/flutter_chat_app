part of 'package:chat_app/features/chat/data/models/message.dart';

class VideoMessage extends Message {
  const VideoMessage({
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
    required this.videoUrl,
    this.videoWidth,
    this.videoHeight,
    this.videoDurationMs,
    this.thumbnailUrl,
    this.mimeType,
    this.mediaBytes,
    this.caption,
  }) : super(type: 'video');

  final String videoUrl;
  final double? videoWidth;
  final double? videoHeight;
  final int? videoDurationMs;
  final String? thumbnailUrl;
  final String? mimeType;
  final int? mediaBytes;
  final String? caption;

  factory VideoMessage.fromMap(String documentId, Map<String, dynamic> data) {
    return VideoMessage(
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
      videoUrl: data['videoUrl'] as String? ?? '',
      videoWidth: (data['videoWidth'] as num?)?.toDouble(),
      videoHeight: (data['videoHeight'] as num?)?.toDouble(),
      videoDurationMs: (data['videoDurationMs'] as num?)?.toInt(),
      thumbnailUrl: data['thumbnailUrl'] as String?,
      mimeType: data['mimeType'] as String?,
      mediaBytes: data['mediaBytes'] as int?,
      caption: data['caption'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...baseMap(),
      'videoUrl': videoUrl,
      'videoWidth': videoWidth,
      'videoHeight': videoHeight,
      'videoDurationMs': videoDurationMs,
      'thumbnailUrl': thumbnailUrl,
      'mimeType': mimeType,
      'mediaBytes': mediaBytes,
      'caption': caption,
    };
  }

  @override
  Message withReply({
    required String replyToMessageId,
    required String replyToSenderId,
    required String replyToSenderName,
    required String replyToText,
  }) {
    return VideoMessage(
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
      videoUrl: videoUrl,
      videoWidth: videoWidth,
      videoHeight: videoHeight,
      videoDurationMs: videoDurationMs,
      thumbnailUrl: thumbnailUrl,
      mimeType: mimeType,
      mediaBytes: mediaBytes,
      caption: caption,
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
    return VideoMessage(
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
      videoUrl: videoUrl,
      videoWidth: videoWidth,
      videoHeight: videoHeight,
      videoDurationMs: videoDurationMs,
      thumbnailUrl: thumbnailUrl,
      mimeType: mimeType,
      mediaBytes: mediaBytes,
      caption: caption,
    );
  }
}
