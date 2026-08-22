import 'package:chat_app/core/video/services/video_compression_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/core/media/models/media_draft.dart';
import 'package:chat_app/core/video/repositories/video_upload_repository.dart';
import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/data/repositories/conversation_message_repository.dart';
import 'package:flutter/material.dart' show debugPrint;

class VideoMessageSender {
  const VideoMessageSender(
    this._videoUploadRepository,
    this._videoCompressionService,
    this._conversationMessageRepository,
  );

  /// Video-specific upload pipeline.
  final VideoUploadRepository _videoUploadRepository;
  final VideoCompressionService _videoCompressionService;

  /// Shared message-send pipeline.
  ///
  /// This repository is intentionally shared with text/image/audio/etc.
  /// because Firestore message persistence and conversation updates are
  /// common message behavior, not video-specific behavior.

  final ConversationMessageRepository _conversationMessageRepository;

  Future<VideoMessage> sendVideo({
    required MediaDraft draft,
    //required String conversationId,
    required String senderId,
    required String senderName,
    void Function(int sentBytes, int totalBytes)? onUploadProgress, // new
  }) async {
    if (!draft.isVideo) {
      throw ArgumentError('VideoMessageSender requires a video MediaDraft.');
    }

    debugPrint('🎬 Starting video message send...');
    // ------------------------------------------------------------
    // 1. Compress / normalize video
    // ------------------------------------------------------------

    final compressedDraft = await _videoCompressionService.compress(draft);
    debugPrint(
      '📦 Using compressed video: '
      '${compressedDraft.width}x${compressedDraft.height}, '
      '${compressedDraft.fileSize} bytes',
    );
    // ------------------------------------------------------------
    // 2. Upload compressed video
    // -----------------------------------------------------------
    final uploadResult = await _videoUploadRepository.upload(
      compressedDraft,
      onProgress: onUploadProgress,
    );

    // ------------------------------------------------------------
    // 3. Create Firestore document
    // ------------------------------------------------------------
    final docRef = _conversationMessageRepository.createMessageDocument();

    // =======================================================================
    // 🎬 THE DIMENSION HARMONIZATION CORE SHIELD
    // =======================================================================
    // ✅ REQUIREMENT MET: Uses the absolute verified backend resolution payload to wipe out stride glitches!
    final double verifiedWidth =
        uploadResult.width ?? (compressedDraft.width?.toDouble() ?? 16.0);
    final double verifiedHeight =
        uploadResult.height ?? (compressedDraft.height?.toDouble() ?? 9.0);

    final message = VideoMessage(
      id: docRef.id,
      senderId: senderId,
      senderName: senderName,
      text: '',
      createdAt: Timestamp.now(),
      readBy: [senderId],
      deletedForEveryone: false,
      deletedBy: const [],
      caption: compressedDraft.caption.isEmpty ? null : compressedDraft.caption,
      mimeType: uploadResult.mimeType,
      mediaBytes: uploadResult.bytes,
      thumbnailUrl: uploadResult.thumbnailUrl,
      videoUrl: uploadResult.url,
      videoWidth: verifiedWidth,
      videoHeight: verifiedHeight,
      videoDurationMs: uploadResult.durationMs ?? compressedDraft.durationMs,
    );

    // ------------------------------------------------------------
    // 4. Send through the COMMON conversation message pipeline.
    //
    // This is important:
    //
    // Message write
    // + conversation update
    // + lastMessage
    // + updatedAt
    // + unread handling
    // + any future shared message behavior
    //
    // all remain centralized here.
    // ------------------------------------------------------------
    await _conversationMessageRepository.sendMessage(message);

    return message;
  }
}
