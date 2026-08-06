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
        id: 'document',
        title: 'Document',
        icon: Icons.insert_drive_file,
        color: Colors.blue,
        enabled: false,
        onTap: () async {},
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
