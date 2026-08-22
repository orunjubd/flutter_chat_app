import 'package:chat_app/core/video/providers/video_compression_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/video/providers/video_upload_repository_provider.dart';
import 'package:chat_app/core/video/services/video_message_sender.dart';
import 'package:chat_app/features/chat/providers/conversation_message_provider.dart';

final videoMessageSenderProvider = Provider.family<VideoMessageSender, String>((
  ref,
  conversationId,
) {
  final uploadRepository = ref.read(videoUploadRepositoryProvider);
  final compressionService = ref.read(videoCompressionServiceProvider);
  final conversationMessageRepository = ref.read(
    conversationMessageRepositoryProvider(conversationId),
  );

  return VideoMessageSender(
    uploadRepository,
    compressionService,
    conversationMessageRepository,
  );
});
