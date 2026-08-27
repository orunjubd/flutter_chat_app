import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/location/services/location_message_sender.dart';
import 'package:chat_app/features/chat/providers/conversation_message_provider.dart';

final locationMessageSenderProvider =
    Provider.family<LocationMessageSender, String>((ref, conversationId) {
      final messageRepository = ref.read(
        conversationMessageRepositoryProvider(conversationId),
      );
      return LocationMessageSender(messageRepository);
    });
