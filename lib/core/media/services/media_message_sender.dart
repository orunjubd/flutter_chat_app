import 'package:chat_app/core/media/models/upload_result.dart';
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

  Future<void> sendDocument({
    required UploadResult uploadResult,
    required String fileName,
    required String senderId,
    required String senderName,
  }) async {
    final document = _messageRepository.createMessageDocument();

    final message = Message(
      id: document.id,

      senderId: senderId,
      senderName: senderName,

      // The visible text for a file message.
      text: fileName,

      createdAt: Timestamp.now(),

      readBy: [senderId],

      type: 'file',

      deletedForEveryone: false,
      deletedBy: const [],
      deletedAt: null,

      replyToMessageId: null,
      replyToSenderId: null,
      replyToSenderName: null,
      replyToText: null,

      forwarded: false,
      forwardedFromUserId: null,
      forwardedFromUserName: null,

      // File metadata.
      fileUrl: uploadResult.url,
      fileName: fileName,
      mimeType: uploadResult.mimeType,
      mediaBytes: uploadResult.bytes,

      // Image-specific fields remain null.
      imageUrl: null,
      imageWidth: null,
      imageHeight: null,
      thumbnailUrl: null,

      caption: fileName,
    );

    await _messageRepository.sendMessage(message);
  }
}
