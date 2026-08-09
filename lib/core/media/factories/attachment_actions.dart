import 'dart:io';
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
//import 'package:chat_app/core/media/models/upload_result.dart';
import 'package:chat_app/core/media/providers/file_picker_service_provider.dart';
import 'package:chat_app/core/media/providers/media_upload_provider.dart';

class AttachmentActions {
  const AttachmentActions._();

  static List<AttachmentAction> build({
    required BuildContext context,
    required WidgetRef ref,
    required String conversationId,
  }) {
    final currentUser = FirebaseAuth.instance.currentUser;
    // We create an asynchronous task runner helper, or read the synchronous value from cache!
    // Since build() is synchronous, we read the current state snapshot instantly:
    final appUserState = ref.read(currentUserProvider);
    final String verifiedSenderName = appUserState.value?.username ?? 'Unknown';

    final conversationRepository = ref.read(
      conversationMessageRepositoryProvider(conversationId),
    );

    return [
      AttachmentAction(
        id: 'camera',
        title: 'Camera',
        icon: Icons.photo_camera,
        color: Colors.red,
        onTap: () async {
          final picker = ref.read(imagePickerProvider);

          final File? file = await picker.pickFromCamera();

          if (file == null) {
            return;
          }

          debugPrint('Camera');
        },
      ),

      AttachmentAction(
        id: 'gallery',
        title: 'Gallery',
        icon: Icons.photo,
        color: Colors.green,
        onTap: () async {
          if (currentUser == null) return;

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

          final sender = ref.read(
            mediaMessageSenderProvider(conversationRepository),
          );

          await sender.sendImage(
            draft: compressed,
            senderId: currentUser.uid,
            senderName: verifiedSenderName,
          );

          debugPrint('✅ Image message sent successfully.');
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
        enabled: false,
        onTap: () async {},
      ),
    ];
  }
}
