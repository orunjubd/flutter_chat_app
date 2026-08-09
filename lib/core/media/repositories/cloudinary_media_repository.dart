import '../models/media_draft.dart';
import '../models/upload_result.dart';
import '../services/cloudinary_upload_service.dart';
import 'media_upload_repository.dart';

class CloudinaryMediaRepository implements MediaUploadRepository {
  CloudinaryMediaRepository(this._service);

  final CloudinaryUploadService _service;

  @override
  Future<UploadResult> uploadMedia(MediaDraft draft) {
    return _service.uploadMedia(draft);
  }
}
