part of 'package:chat_app/features/chat/data/models/message.dart';

class CallSystemMessage extends Message {
  const CallSystemMessage({
    required super.id,
    required super.senderId,
    required super.senderName,
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
    required this.callType,
    required this.status,
    this.durationSeconds,
  }) : super(text: '', type: 'call_system');

  final CallType callType;
  final CallHistoryStatus status;
  final int? durationSeconds;

  factory CallSystemMessage._fromMap(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return CallSystemMessage(
      id: documentId,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
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
      callType: CallType.values.firstWhere(
        (t) => t.name == data['callType'],
        orElse: () => CallType.voice,
      ),
      status: CallHistoryStatus.values.firstWhere(
        (s) => s.name == data['callStatus'],
        orElse: () => CallHistoryStatus.failed,
      ),
      durationSeconds: (data['durationSeconds'] as num?)?.toInt(),
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    ...baseMap(),
    'callType': callType.name,
    'callStatus': status.name,
    'durationSeconds': durationSeconds,
  };

  @override
  Message withReply({
    required String replyToMessageId,
    required String replyToSenderId,
    required String replyToSenderName,
    required String replyToText,
  }) {
    return CallSystemMessage(
      id: id,
      senderId: senderId,
      senderName: senderName,
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
      callType: callType,
      status: status,
      durationSeconds: durationSeconds,
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
    return CallSystemMessage(
      id: newId,
      senderId: senderId,
      senderName: senderName,
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
      callType: callType,
      status: status,
      durationSeconds: durationSeconds,
    );
  }
}
