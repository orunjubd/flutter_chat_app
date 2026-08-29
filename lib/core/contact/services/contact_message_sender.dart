import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/core/contact/models/contact_draft.dart';
import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/data/repositories/conversation_message_repository.dart';

class ContactMessageSender {
  const ContactMessageSender(this._messageRepository);
  final ConversationMessageRepository _messageRepository;

  Future<ContactMessage> sendContact({
    required ContactDraft draft,
    required String senderId,
    required String senderName,
  }) async {
    final docRef = _messageRepository.createMessageDocument();

    final message = ContactMessage(
      id: docRef.id,
      senderId: senderId,
      senderName: senderName,
      text: '',
      createdAt: Timestamp.now(),
      readBy: [senderId],
      deletedForEveryone: false,
      deletedBy: const [],
      contactName: draft.name,
      contactPhone: draft.phone,
      contactEmail: draft.email,
      contactAddress: draft.address,
    );

    await _messageRepository.sendMessage(message);
    return message;
  }
}
