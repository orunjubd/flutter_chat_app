import 'package:chat_app/features/chat/data/models/message.dart';

class ReplyRepository {
  const ReplyRepository();

  Message attachReply({required Message draft, required Message? reply}) {
    if (reply == null) {
      return draft;
    }

    return draft.withReply(
      replyToMessageId: reply.id,
      replyToSenderId: reply.senderId,
      replyToSenderName: reply.senderName,
      replyToText: reply.text,
    );
  }
}
