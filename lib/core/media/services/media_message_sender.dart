import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/core/media/models/media_draft.dart';
import 'package:chat_app/core/media/repositories/media_upload_repository.dart';

import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/data/repositories/conversation_message_repository.dart';

class MediaMessageSender {
  const MediaMessageSender({
    required MediaUploadRepository uploadRepository,
    required ConversationMessageRepository messageRepository,
  }) : _uploadRepository = uploadRepository,
       _messageRepository = messageRepository;

  final MediaUploadRepository _uploadRepository;

  final ConversationMessageRepository _messageRepository;

  Future<void> sendImage({
    required MediaDraft draft,
    required String senderId,
    required String senderName,
  }) async {
    //--------------------------------------------------
    // Upload
    //--------------------------------------------------

    final upload = await _uploadRepository.uploadMedia(draft);

    //--------------------------------------------------
    // Firestore document
    //--------------------------------------------------

    final document = _messageRepository.createMessageDocument();

    //--------------------------------------------------
    // Message
    //--------------------------------------------------

    final message = Message(
      id: document.id,

      senderId: senderId,
      senderName: senderName,

      text: draft.caption,

      createdAt: Timestamp.now(),

      readBy: [senderId],

      type: 'image',

      deletedForEveryone: false,
      deletedBy: const [],
      deletedAt: null,

      replyToMessageId: null,
      replyToSenderId: null,
      replyToSenderName: null,
      replyToText: draft.caption,

      forwarded: false,
      forwardedFromUserId: null,
      forwardedFromUserName: null,

      imageUrl: upload.url,
      imageWidth: upload.width,
      imageHeight: upload.height,

      mimeType: upload.mimeType,
      mediaBytes: upload.bytes,
      thumbnailUrl: null,

      caption: draft.caption,
    );

    //--------------------------------------------------
    // Save
    //--------------------------------------------------

    await _messageRepository.sendImageMessage(message: message);
  }
}
