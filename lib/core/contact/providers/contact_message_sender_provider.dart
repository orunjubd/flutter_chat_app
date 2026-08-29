import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/contact/services/contact_message_sender.dart';
import 'package:chat_app/core/contact/services/contact_picker_service.dart';
import 'package:chat_app/features/chat/providers/conversation_message_provider.dart';

final contactPickerServiceProvider = Provider<ContactPickerService>(
  (ref) => const ContactPickerService(),
);

final contactMessageSenderProvider =
    Provider.family<ContactMessageSender, String>((ref, conversationId) {
      final messageRepository = ref.read(
        conversationMessageRepositoryProvider(conversationId),
      );
      return ContactMessageSender(messageRepository);
    });
