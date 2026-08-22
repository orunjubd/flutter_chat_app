// lib/core/video/providers/video_upload_provider.dart
import 'package:chat_app/core/config/media_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/media/services/cloudinary_upload_service.dart';
import 'package:chat_app/core/media/models/upload_config.dart';
import 'package:chat_app/core/video/services/cloudinary_video_upload_service.dart';

final cloudinaryVideoUploadServiceProvider =
    Provider<CloudinaryVideoUploadService>((ref) {
      final cloudinaryUploadService = CloudinaryUploadService(
        const UploadConfig(
          cloudName: MediaConfig
              .cloudName, // or pull from MediaConfig if you've centralized it
          uploadPreset: MediaConfig.uploadPreset,
        ),
      );
      return CloudinaryVideoUploadService(cloudinaryUploadService);
    });
