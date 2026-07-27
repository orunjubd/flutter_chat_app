import 'package:chat_app/features/chat/data/models/message.dart';

class ReplyRepository {
  const ReplyRepository();

  Message attachReply({required Message draft, required Message? reply}) {
    if (reply == null) {
      return draft;
    }

    return Message(
      id: draft.id,
      senderId: draft.senderId,
      senderName: draft.senderName,
      text: draft.text,
      createdAt: draft.createdAt,
      readBy: draft.readBy,
      type: draft.type,

      deletedForEveryone: draft.deletedForEveryone,
      deletedBy: draft.deletedBy,
      deletedAt: draft.deletedAt,

      replyToMessageId: reply.id,
      replyToSenderId: reply.senderId,
      replyToSenderName: reply.senderName,
      replyToText: reply.text,
    );
  }
}
