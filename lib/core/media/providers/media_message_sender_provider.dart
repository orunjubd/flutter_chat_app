import 'package:chat_app/core/media/providers/media_upload_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/media/services/media_message_sender.dart';
//import 'package:chat_app/core/media/repositories/media_upload_repository.dart';

import 'package:chat_app/features/chat/data/repositories/conversation_message_repository.dart';

final mediaMessageSenderProvider =
    Provider.family<MediaMessageSender, ConversationMessageRepository>((
      ref,
      conversationRepository,
    ) {
      final uploadRepository = ref.read(mediaUploadRepositoryProvider);

      return MediaMessageSender(
        uploadRepository: uploadRepository,
        messageRepository: conversationRepository,
      );
    });
