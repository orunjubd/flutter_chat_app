import 'dart:io';

import 'package:chat_app/core/config/media_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/profile/repositories/profile_repository.dart';
import 'package:chat_app/features/profile/services/profile_image_picker_service.dart';
import 'package:chat_app/features/profile/services/profile_image_optimization_service.dart';
import 'package:chat_app/features/profile/services/cloudinary_profile_image_service.dart';

/// ---------------------------------------------------------------------------
/// Profile photo state
/// ---------------------------------------------------------------------------

enum ProfilePhotoStatus {
  idle,
  picking,
  optimizing,
  uploading,
  saving,
  removing,
  success,
  failure,
}

class ProfilePhotoState {
  const ProfilePhotoState({
    this.status = ProfilePhotoStatus.idle,
    this.imageUrl,
    this.errorMessage,
  });

  final ProfilePhotoStatus status;
  final String? imageUrl;
  final String? errorMessage;

  bool get isBusy {
    return status == ProfilePhotoStatus.picking ||
        status == ProfilePhotoStatus.optimizing ||
        status == ProfilePhotoStatus.uploading ||
        status == ProfilePhotoStatus.saving ||
        status == ProfilePhotoStatus.removing;
  }

  ProfilePhotoState copyWith({
    ProfilePhotoStatus? status,
    String? imageUrl,
    String? errorMessage,
    bool clearImageUrl = false,
    bool clearError = false,
  }) {
    return ProfilePhotoState(
      status: status ?? this.status,
      imageUrl: clearImageUrl ? null : imageUrl ?? this.imageUrl,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

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

/// ---------------------------------------------------------------------------
/// Controller
/// ---------------------------------------------------------------------------

final profilePhotoProvider =
    NotifierProvider<ProfilePhotoController, ProfilePhotoState>(
      ProfilePhotoController.new,
    );

class ProfilePhotoController extends Notifier<ProfilePhotoState> {
  @override
  ProfilePhotoState build() {
    return const ProfilePhotoState();
  }

  /// Change profile photo using the device gallery.
  Future<String?> changeFromGallery({required String userId}) async {
    return _changePhoto(userId: userId, fromCamera: false);
  }

  /// Change profile photo using the camera.
  Future<String?> changeFromCamera({required String userId}) async {
    return _changePhoto(userId: userId, fromCamera: true);
  }

  Future<String?> _changePhoto({
    required String userId,
    required bool fromCamera,
  }) async {
    if (state.isBusy) {
      return null;
    }

    try {
      // ---------------------------------------------------------------
      // STEP 2 — Pick image
      // ---------------------------------------------------------------

      state = state.copyWith(
        status: ProfilePhotoStatus.picking,
        clearError: true,
      );

      final picker = ref.read(profileImagePickerServiceProvider);

      final File? selectedFile = fromCamera
          ? await picker.pickFromCamera()
          : await picker.pickFromGallery();

      // User cancelled the picker.
      if (selectedFile == null) {
        state = state.copyWith(status: ProfilePhotoStatus.idle);

        return null;
      }

      // ---------------------------------------------------------------
      // STEP 3 — Optimize image
      // ---------------------------------------------------------------

      state = state.copyWith(status: ProfilePhotoStatus.optimizing);

      final optimizer = ref.read(profileImageOptimizationServiceProvider);

      final optimizedBytes = await optimizer.optimize(selectedFile);

      // ---------------------------------------------------------------
      // STEP 4 — Cloudinary upload
      // ---------------------------------------------------------------

      state = state.copyWith(status: ProfilePhotoStatus.uploading);

      final cloudinary = ref.read(cloudinaryProfileImageServiceProvider);

      final imageUrl = await cloudinary.upload(
        imageBytes: optimizedBytes,
        userId: userId,
      );

      // ---------------------------------------------------------------
      // STEP 8 — Firestore imageUrl update
      // ---------------------------------------------------------------

      state = state.copyWith(status: ProfilePhotoStatus.saving);

      final repository = ref.read(profileRepositoryProvider);

      await repository.updateProfileImageUrl(
        userId: userId,
        imageUrl: imageUrl,
      );

      // ---------------------------------------------------------------
      // STEP 9 — UI refresh
      // ---------------------------------------------------------------

      state = state.copyWith(
        status: ProfilePhotoStatus.success,
        imageUrl: imageUrl,
      );

      debugPrint('✅ [ProfilePhoto] Profile image updated successfully.');

      return imageUrl;
    } catch (error, stackTrace) {
      debugPrint('❌ [ProfilePhoto] Failed to change profile photo: $error');

      debugPrintStack(stackTrace: stackTrace);

      state = state.copyWith(
        status: ProfilePhotoStatus.failure,
        errorMessage: error.toString(),
      );

      return null;
    }
  }

  // -------------------------------------------------------------------------
  // STEP 10 — Remove profile photo
  // -------------------------------------------------------------------------

  Future<bool> removePhoto({required String userId}) async {
    if (state.isBusy) {
      return false;
    }

    try {
      state = state.copyWith(
        status: ProfilePhotoStatus.removing,
        clearError: true,
      );

      final repository = ref.read(profileRepositoryProvider);

      await repository.removeProfileImage(userId: userId);

      state = state.copyWith(
        status: ProfilePhotoStatus.success,
        clearImageUrl: true,
      );

      debugPrint('✅ [ProfilePhoto] Profile image removed from Firestore.');

      return true;
    } catch (error, stackTrace) {
      debugPrint('❌ [ProfilePhoto] Failed to remove profile photo: $error');

      debugPrintStack(stackTrace: stackTrace);

      state = state.copyWith(
        status: ProfilePhotoStatus.failure,
        errorMessage: error.toString(),
      );

      return false;
    }
  }

  void resetStatus() {
    state = state.copyWith(status: ProfilePhotoStatus.idle, clearError: true);
  }
}
