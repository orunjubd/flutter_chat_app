import '../models/media_draft.dart';
import '../models/upload_result.dart';

abstract class UploadService {
  const UploadService();

  /// Uploads any media draft.
  ///
  /// Every upload provider (Cloudinary, Firebase Storage,
  /// WHM server, S3...) implements this same API.
  Future<UploadResult> uploadImage(MediaDraft draft);

  Future<void> deleteImage(String url);
}

// abstract class UploadConfig {
//   const UploadConfig(this.cloudName, this.uploadPreset, this.folder);

//   final String cloudName;
//   final String uploadPreset;
//   final String folder;
// }
