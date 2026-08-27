import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/core/location/models/location_draft.dart';
import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/data/repositories/conversation_message_repository.dart';

class LocationMessageSender {
  const LocationMessageSender(this._messageRepository);

  final ConversationMessageRepository _messageRepository;

  Future<LocationMessage> sendLocation({
    required LocationDraft draft,
    required String senderId,
    required String senderName,
  }) async {
    final docRef = _messageRepository.createMessageDocument();

    final message = LocationMessage(
      id: docRef.id,
      senderId: senderId,
      senderName: senderName,
      text: '',
      createdAt: Timestamp.now(),
      readBy: [senderId],
      deletedForEveryone: false,
      deletedBy: const [],
      latitude: draft.latitude,
      longitude: draft.longitude,
      address: draft.address,
    );

    await _messageRepository.sendMessage(message);
    return message;
  }
}
