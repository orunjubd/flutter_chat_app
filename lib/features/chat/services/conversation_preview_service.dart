//import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/message.dart';
import '../data/repositories/conversation_repository.dart';

class ConversationPreviewService {
  const ConversationPreviewService(this._repository);

  final ConversationRepository _repository;

  Future<void> updatePreview({
    required String conversationId,
    required Message message,
  }) {
    return _repository.updateConversationPreview(
      conversationId: conversationId,
      message: message,
    );
  }
}
