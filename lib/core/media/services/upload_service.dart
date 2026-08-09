import '../models/media_draft.dart';
import '../models/upload_result.dart';

/// Common upload contract for all media providers.
/// Future providers can implement this same interface:
/// - Cloudinary
/// - Firebase Storage
/// - Amazon S3
/// - WHM/server storage
/// - etc.

abstract class UploadService {
  const UploadService();

  /// Uploads any supported media draft.
  ///
  /// The concrete provider decides how the media should be
  /// uploaded based on the MediaDraft type.
  Future<UploadResult> uploadMedia(MediaDraft draft);

  /// Deletes an uploaded media asset.
  /// Currently retained for Cloudinary image deletion.
  /// Later this can become provider-agnostic as the deletion
  /// architecture is implemented.

  Future<void> deleteMedia(String publicId);
}

// abstract class UploadConfig {
//   const UploadConfig(this.cloudName, this.uploadPreset, this.folder);

//   final String cloudName;
//   final String uploadPreset;
//   final String folder;
// }
