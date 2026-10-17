import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/profile/providers/profile_photo_provider.dart';

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
        debugPrint('⚠️ [ProfilePhoto] User cancelled the image picker.');
        return null;
      }
      debugPrint(
        '📸 [ProfilePhoto] Image picked successfully. Local Path: ${selectedFile.path}',
      );
      // ---------------------------------------------------------------
      // STEP 3 — Optimize image
      // ---------------------------------------------------------------

      state = state.copyWith(status: ProfilePhotoStatus.optimizing);

      final optimizer = ref.read(profileImageOptimizationServiceProvider);

      final optimizedBytes = await optimizer.optimize(selectedFile);
      debugPrint(
        '⚡ [ProfilePhoto] Image optimized successfully. Bytes count: ${optimizedBytes.length}',
      );

      // ---------------------------------------------------------------
      // STEP 4 — Cloudinary upload
      // ---------------------------------------------------------------

      state = state.copyWith(status: ProfilePhotoStatus.uploading);

      final cloudinary = ref.read(cloudinaryProfileImageServiceProvider);

      final imageUrl = await cloudinary.upload(
        imageBytes: optimizedBytes,
        userId: userId,
      );
      // DATA INTEGRITY GUARD: If the link from Cloudinary is null or empty, intercept and abort instantly!
      if (imageUrl.trim().isEmpty) {
        throw Exception(
          'Cloudinary upload returned an empty or invalid secure web URL token.',
        );
      }

      debugPrint('☁️ [ProfilePhoto] Cloudinary Secure URL received: $imageUrl');
      // ---------------------------------------------------------------
      // STEP 8 — Firestore imageUrl update
      // ---------------------------------------------------------------

      state = state.copyWith(status: ProfilePhotoStatus.saving);

      final repository = ref.read(profileRepositoryProvider);

      await repository.updateProfile(userId, {'imageUrl': imageUrl});

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

  /// Returns a user-friendly message for the latest profile-photo error.
  String getUserFriendlyError() {
    final error = state.errorMessage?.toLowerCase() ?? '';

    if (error.contains('network') ||
        error.contains('socketexception') ||
        error.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }

    if (error.contains('permission')) {
      return 'Permission denied. Please check your app permissions.';
    }

    if (error.contains('cloudinary')) {
      return 'Image upload failed. Please try again.';
    }

    if (error.contains('firebase') || error.contains('firestore')) {
      return 'Could not save your profile photo. Please try again.';
    }

    return 'Something went wrong. Please try again.';
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
