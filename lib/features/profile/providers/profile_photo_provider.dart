import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/config/media_config.dart';
import 'package:chat_app/features/profile/repositories/profile_repository.dart';
import 'package:chat_app/features/profile/services/profile_image_picker_service.dart';
import 'package:chat_app/features/profile/services/profile_image_optimization_service.dart';
import 'package:chat_app/features/profile/services/cloudinary_profile_image_service.dart';

/// ---------------------------------------------------------------------------
/// Profile photo state
/// ---------------------------------------------------------------------------

/// ---------------------------------------------------------------------------
/// Services
/// ---------------------------------------------------------------------------

final profileImagePickerServiceProvider = Provider<ProfileImagePickerService>((
  ref,
) {
  return ProfileImagePickerService();
});

final profileImageOptimizationServiceProvider =
    Provider<ProfileImageOptimizationService>((ref) {
      return const ProfileImageOptimizationService();
    });

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

/// ---------------------------------------------------------------------------
/// Cloudinary configuration
/// ---------------------------------------------------------------------------
///
/// Replace these two values with the SAME Cloudinary configuration
/// you already use in your ECE project.
///
/// Do NOT put a Cloudinary API secret here.
final cloudinaryProfileImageServiceProvider =
    Provider<CloudinaryProfileImageService>((ref) {
      return const CloudinaryProfileImageService(
        cloudName: MediaConfig.cloudName,
        uploadPreset: MediaConfig.uploadPreset,
      );
    });
