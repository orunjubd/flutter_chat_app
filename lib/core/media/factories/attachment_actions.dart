import 'dart:io';
import 'package:chat_app/core/camera/providers/camera_capture_service_provider.dart';
import 'package:chat_app/core/video/providers/video_message_sender_provider.dart';
import 'package:chat_app/core/video/providers/video_upload_progress_provider.dart';
import 'package:chat_app/core/video/widgets/video_send_preview.dart';
//import 'package:chat_app/core/video/providers/video_player_provider.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:chat_app/core/media/models/media_draft.dart';
import 'package:chat_app/core/media/providers/media_compression_provider.dart';
import 'package:chat_app/core/media/providers/media_message_sender_provider.dart';
import 'package:chat_app/features/chat/presentation/screens/image_preview_screen.dart';
import 'package:chat_app/features/chat/providers/conversation_message_provider.dart';
import '../models/attachment_action.dart';
import '../providers/image_picker_provider.dart';
import 'package:chat_app/core/media/providers/file_picker_service_provider.dart';
import 'package:chat_app/core/media/providers/media_upload_provider.dart';
import 'package:chat_app/core/audio/widgets/voice_recorder_widget.dart';
import 'package:chat_app/core/audio/models/voice_recording.dart';
import 'package:chat_app/core/media/models/media_type.dart';
import 'package:chat_app/core/video/providers/video_picker_provider.dart';
import 'package:chat_app/core/video/providers/video_thumbnail_provider.dart';

class AttachmentActions {
  const AttachmentActions._();

  static List<AttachmentAction> build({
    required BuildContext context,
    required WidgetRef ref,
    required String conversationId,
  }) {
    final currentUser = FirebaseAuth.instance.currentUser;

    final conversationRepository = ref.read(
      conversationMessageRepositoryProvider(conversationId),
    );

    return [
      AttachmentAction(
        id: 'camera_photo',
        title: 'Photo (Camera)',
        icon: Icons.camera_alt,
        color: Colors.blue,
        enabled: true,
        onTap: () async {
          if (currentUser == null) {
            debugPrint('Camera photo capture aborted: no signed-in user.');
            return;
          }

          try {
            final cameraService = ref.read(cameraCaptureServiceProvider);

            final draft = await cameraService.capturePhoto();

            if (draft == null) {
              debugPrint('📷 Camera photo capture cancelled.');
              return;
            }

            debugPrint('📷 Camera photo captured.');
            debugPrint('Path: ${draft.file.path}');
            debugPrint('Size: ${draft.fileSize}');
            debugPrint('MIME: ${draft.mimeType}');
            debugPrint('Type: ${draft.type}');
            debugPrint('Dimensions: ${draft.width}x${draft.height}');

            if (!context.mounted) return;

            // Send the photo through your existing image pipeline.
            //
            // Use your existing image preview screen here,
            // exactly like the Gallery image flow.
            final MediaDraft? result = await Navigator.push<MediaDraft>(
              context,
              MaterialPageRoute(
                builder: (_) => ImagePreviewScreen(imageFile: draft.file),
              ),
            );

            if (result == null) {
              debugPrint('📷 Camera photo preview cancelled.');
              return;
            }

            final compressed = await ref
                .read(mediaCompressionProvider)
                .compress(result);

            if (!context.mounted) return;

            final appUser = await ref.read(currentUserProvider.future);

            final senderName = appUser?.username ?? 'Unknown';

            final sender = ref.read(
              mediaMessageSenderProvider(conversationRepository),
            );

            await sender.sendImage(
              draft: compressed,
              senderId: currentUser.uid,
              senderName: senderName,
            );

            debugPrint('✅ Camera photo message sent successfully.');
          } catch (e, stackTrace) {
            debugPrint('❌ Camera photo send failed: $e');
            debugPrintStack(stackTrace: stackTrace);

            if (!context.mounted) return;

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Camera photo failed: $e')));
          }
        },
      ),
      AttachmentAction(
        id: 'camera_video',
        title: 'Video (Camera)',
        icon: Icons.videocam,
        color: Colors.blue,
        enabled: true,
        onTap: () async {
          if (currentUser == null) {
            debugPrint('Video capture aborted: no signed-in user.');
            return;
          }

          try {
            final cameraService = ref.read(cameraCaptureServiceProvider);

            final draft = await cameraService.captureVideo();

            if (draft == null) {
              debugPrint('📷 Camera capture cancelled.');
              return;
            }

            debugPrint('📷 Camera photo captured.');
            debugPrint('Path: ${draft.file.path}');
            debugPrint('Size: ${draft.fileSize}');
            debugPrint('MIME: ${draft.mimeType}');
            debugPrint('Type: ${draft.type}');
            debugPrint('Dimensions: ${draft.width}x${draft.height}');
            final thumbnailService = ref.read(videoThumbnailServiceProvider);
            final thumbnailFile = await thumbnailService.generate(draft.file);

            final appUser = await ref.read(currentUserProvider.future);
            final senderName = appUser?.username ?? 'Unknown';

            if (!context.mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VideoSendPreview(
                  draft: draft,
                  thumbnailFile: thumbnailFile,
                  onSend: (updatedDraft) async {
                    final videoMessageSender = ref.read(
                      videoMessageSenderProvider(conversationId),
                    );
                    final sentMessage = await videoMessageSender.sendVideo(
                      draft: updatedDraft,
                      senderId: currentUser.uid,
                      senderName: senderName,
                    );
                    debugPrint(
                      '✅ Camera video message sent: ${sentMessage.id}',
                    );
                  },
                ),
              ),
            );
          } catch (e, stackTrace) {
            debugPrint('❌ Camera capture failed: $e');
            debugPrintStack(stackTrace: stackTrace);

            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Camera capture failed: $e')),
            );
          }
        },
      ),

      AttachmentAction(
        id: 'gallery',
        title: 'Gallery',
        icon: Icons.photo,
        color: Colors.green,
        onTap: () async {
          if (currentUser == null) return;

          try {
            final picker = ref.read(imagePickerProvider);
            final File? file = await picker.pickFromGallery();

            // 🛡️ SECURITY SHIELD A: Early return if user cancelled picking!
            if (file == null) {
              debugPrint('🖼️ Gallery picking cancelled by user.');
              return;
            }

            // 🛡️ SECURITY SHIELD B: ASYNC LIFE CYCLE GUARD (Clears the BuildContext across async gaps warning)
            if (!context.mounted) return;

            final MediaDraft? result = await Navigator.push<MediaDraft>(
              context,
              MaterialPageRoute(
                builder: (_) => ImagePreviewScreen(imageFile: file),
              ),
            );

            if (result == null) {
              debugPrint('Preview cancelled');
              return;
            }

            //==================================================
            // Compress
            //==================================================

            final compressed = await ref
                .read(mediaCompressionProvider)
                .compress(result);

            //==================================================
            // Upload + Send Message
            //==================================================

            if (!context.mounted) return;

            // Fresh read, at send time — not a stale sheet-open snapshot.
            final appUser = await ref.read(currentUserProvider.future);
            final senderName = appUser?.username ?? 'Unknown';

            final sender = ref.read(
              mediaMessageSenderProvider(conversationRepository),
            );

            await sender.sendImage(
              draft: compressed,
              senderId: currentUser.uid,
              senderName: senderName,
            );

            debugPrint('✅ Image message sent successfully.');
          } catch (e, stackTrace) {
            debugPrint('❌ Gallery image send failed: $e');
            debugPrintStack(stackTrace: stackTrace);
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Image send failed: $e')));
          }
        },
      ),

      AttachmentAction(
        id: 'file',
        title: 'File',
        icon: Icons.insert_drive_file,
        color: Colors.orange,
        enabled: true,
        onTap: () async {
          final service = ref.read(filePickerServiceProvider);
          // ============================================================
          // 1. PICK FILE
          // ============================================================

          final draft = await service.pickSingleFile();

          if (draft == null) {
            debugPrint('❌ 📄 File selection cancelled.');
            return;
          }

          debugPrint('📄 File picked: ${draft.fileName}');
          debugPrint('📦 File size: ${draft.fileSize}');
          debugPrint('📑 MIME type: ${draft.mimeType}');
          debugPrint('📂 File path: ${draft.file.path}');

          // ============================================================
          // 2. CONVERT FileDraft → MediaDraft
          // ============================================================

          final mediaDraft = MediaDraft(
            file: draft.file,
            type: MediaType.document,
            mimeType: draft.mimeType,
            caption: draft.fileName,
          );

          debugPrint('✅ MediaDraft created');
          debugPrint('   📄 ${mediaDraft.file}');
          debugPrint('   📑 ${mediaDraft.mimeType}');

          // ============================================================
          // 3. UPLOAD TO CLOUDINARY
          // ============================================================
          // UploadResult uploadResult;
          try {
            // ============================================================
            // 1. UPLOAD FILE TO CLOUDINARY
            // ============================================================

            debugPrint('☁️ Starting document upload...');

            final uploadResult = await ref
                .read(mediaUploadRepositoryProvider)
                .uploadMedia(mediaDraft);

            debugPrint('✅ Cloudinary upload completed');
            debugPrint('   🔗 URL: ${uploadResult.url}');
            debugPrint('   🆔 Public ID: ${uploadResult.publicId}');
            debugPrint('   📑 MIME: ${uploadResult.mimeType}');
            debugPrint('   📦 Bytes: ${uploadResult.bytes}');

            // ============================================================
            // 2. VERIFY CURRENT USER
            // ============================================================

            final currentUser = FirebaseAuth.instance.currentUser;

            if (currentUser == null) {
              debugPrint('❌ No authenticated Firebase user.');
              return;
            }

            // ============================================================
            // 3. RESOLVE VERIFIED USERNAME
            // ============================================================

            final appUserState = ref.read(currentUserProvider);

            final String verifiedSenderName =
                appUserState.value?.username ?? 'Unknown';

            debugPrint('👤 Sender: $verifiedSenderName');

            // ============================================================
            // 4. CREATE MEDIA MESSAGE SENDER
            // ============================================================

            final conversationRepository = ref.read(
              conversationMessageRepositoryProvider(conversationId),
            );

            final sender = ref.read(
              mediaMessageSenderProvider(conversationRepository),
            );

            // ============================================================
            // 5. CREATE FIRESTORE FILE MESSAGE
            // ============================================================

            await sender.sendDocument(
              uploadResult: uploadResult,
              fileName: draft.fileName,
              senderId: currentUser.uid,
              senderName: verifiedSenderName,
            );

            debugPrint('✅ Document message sent successfully.');
          } catch (e, stackTrace) {
            debugPrint('❌ Document upload/send failed: $e');
            debugPrint('$stackTrace');
          }
        },
      ),

      AttachmentAction(
        id: 'location',
        title: 'Location',
        icon: Icons.location_on,
        color: Colors.orange,
        enabled: false,
        onTap: () async {},
      ),

      AttachmentAction(
        id: 'contact',
        title: 'Contact',
        icon: Icons.person,
        color: Colors.teal,
        enabled: false,
        onTap: () async {},
      ),

      AttachmentAction(
        id: 'audio',
        title: 'Audio',
        icon: Icons.headphones,
        color: Colors.deepPurple,
        enabled: true,
        onTap: () async {
          //final recorder = ref.read(audioRecorderServiceProvider);

          final VoiceRecording? recording =
              await showModalBottomSheet<VoiceRecording?>(
                context: context,
                isScrollControlled: true,
                builder: (_) {
                  return VoiceRecorderWidget(
                    onRecordingComplete: (recording) {
                      Navigator.pop(context, recording);
                    },
                    onCancel: () {
                      Navigator.pop(context);
                    },
                  );
                },
              );

          if (recording == null || recording.path.isEmpty) {
            debugPrint('🗑️ [AttachmentActions] Voice recording cancelled.');
            return;
          }

          debugPrint('🎙️ [AttachmentActions] Voice recording ready.');
          debugPrint('📂 Path: ${recording.path}');
          debugPrint('📦 Bytes: ${recording.fileSize}');
          debugPrint('⏱️ Duration: ${recording.durationMs} ms');

          final file = File(recording.path);

          if (!await file.exists()) {
            debugPrint(
              '❌ [AttachmentActions] Recorded voice file does not exist.',
            );
            return;
          }

          final bytes = await file.length();

          debugPrint('📦 Voice bytes: $bytes');

          final mediaDraft = MediaDraft(
            file: file,
            type: MediaType.audio,
            mimeType: recording.mimeType,
            caption: '',
          );

          debugPrint('✅ Voice MediaDraft created.: ${mediaDraft.file.path}');

          final currentUser = FirebaseAuth.instance.currentUser;

          if (currentUser == null) {
            debugPrint('❌ No authenticated Firebase user.');
            return;
          }

          final appUserState = ref.read(currentUserProvider);

          final verifiedSenderName = appUserState.value?.username ?? 'Unknown';

          final conversationRepository = ref.read(
            conversationMessageRepositoryProvider(conversationId),
          );

          final sender = ref.read(
            mediaMessageSenderProvider(conversationRepository),
          );

          try {
            debugPrint('☁️ Starting voice upload...');

            final uploadResult = await ref
                .read(mediaUploadRepositoryProvider)
                .uploadMedia(mediaDraft);

            debugPrint('✅ Voice upload completed.');
            debugPrint('🔗 URL: ${uploadResult.url}');
            debugPrint('🆔 Public ID: ${uploadResult.publicId}');
            debugPrint('📑 MIME: ${uploadResult.mimeType}');
            debugPrint('📦 Bytes: ${uploadResult.bytes}');

            await sender.sendVoice(
              //uploadResult: uploadResult,
              draft: mediaDraft,
              senderId: currentUser.uid,
              senderName: verifiedSenderName,
              durationMs: recording.durationMs,
            );

            debugPrint('✅ Voice message sent successfully.');
          } catch (e, stackTrace) {
            debugPrint('❌ Voice upload/send failed: $e');
            debugPrint('$stackTrace');
          }
        },
      ),

      AttachmentAction(
        id: 'video',
        title: 'Video',
        icon: Icons.videocam,
        color: Colors.red,
        enabled: true,
        onTap: () async {
          if (currentUser == null) {
            debugPrint('Video send aborted: no signed-in user.');
            return;
          }

          try {
            final videoPicker = ref.read(videoPickerProvider);
            final MediaDraft? draft = await videoPicker.pickVideo();

            if (draft == null) {
              debugPrint('Video picker cancelled.');
              return;
            }

            final thumbnailService = ref.read(videoThumbnailServiceProvider);
            await thumbnailService.generate(draft.file);

            final appUser = await ref.read(currentUserProvider.future);
            final senderName = appUser?.username ?? 'Unknown';

            if (!context.mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VideoSendPreview(
                  draft: draft,
                  onSend: (updatedDraft) async {
                    final videoMessageSender = ref.read(
                      videoMessageSenderProvider(conversationId),
                    );

                    final progressNotifier = ref.read(
                      videoUploadProgressProvider.notifier,
                    );

                    progressNotifier.start(
                      totalBytes:
                          updatedDraft.fileSize ??
                          await updatedDraft.file.length(),
                    );

                    try {
                      final sentMessage = await videoMessageSender.sendVideo(
                        draft: updatedDraft,
                        senderId: currentUser.uid,
                        senderName: senderName,
                        onUploadProgress: (sentBytes, totalBytes) {
                          progressNotifier.update(
                            sentBytes: sentBytes,
                            totalBytes: totalBytes,
                          );
                        },
                      );

                      progressNotifier.complete();

                      debugPrint('✅ Video message sent.');
                      debugPrint(
                        '🔥 [VideoPipeline] Message ID: ${sentMessage.id}',
                      );
                    } catch (e) {
                      progressNotifier.reset();
                      rethrow;
                    }
                  },
                ),
              ),
            );
            debugPrint('✅ Video message sent successfully.');
          } catch (e, stackTrace) {
            debugPrint('❌ Video send failed: $e');
            debugPrintStack(stackTrace: stackTrace);

            if (!context.mounted) return;

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Video send failed: $e')));
          }
        },
      ),
    ];
  }
}
