import 'package:chat_app/features/chat/data/repositories/group_repository.dart';
import 'package:chat_app/features/chat/providers/group_provider.dart';
import 'package:chat_app/features/profile/providers/profile_photo_provider.dart';
import 'package:chat_app/features/profile/services/cloudinary_profile_image_service.dart';
import 'package:chat_app/features/profile/services/profile_image_optimization_service.dart';
import 'package:chat_app/features/profile/services/profile_image_picker_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupAvatarServiceProvider = Provider(
  (ref) => GroupAvatarService(
    ref.read(profileImagePickerServiceProvider),
    ref.read(profileImageOptimizationServiceProvider),
    ref.read(cloudinaryProfileImageServiceProvider),
    ref.read(groupRepositoryProvider),
  ),
);

class GroupAvatarService {
  GroupAvatarService(this._picker, this._optimizer, this._cloud, this._groups);
  final ProfileImagePickerService _picker;
  final ProfileImageOptimizationService _optimizer;
  final CloudinaryProfileImageService _cloud;
  final GroupRepository _groups;

  Future<bool> change({
    required String groupId,
    required String actorId,
    required String actorName,
    required bool fromCamera,
  }) async {
    final file = fromCamera
        ? await _picker.pickFromCamera()
        : await _picker.pickFromGallery();
    if (file == null) return false;
    final bytes = await _optimizer.optimize(file);
    final url = await _cloud.upload(
      imageBytes: bytes,
      userId: groupId,
      folder: 'ece/group_avatars',
      filenamePrefix: 'group',
    );
    await _groups.updateAvatar(
      groupId: groupId,
      actorId: actorId,
      actorName: actorName,
      avatarUrl: url,
    );
    return true;
  }

  Future<void> remove({
    required String groupId,
    required String actorId,
    required String actorName,
  }) => _groups.updateAvatar(
    groupId: groupId,
    actorId: actorId,
    actorName: actorName,
  );
}
