import '../models/media_draft.dart';
import '../models/upload_result.dart';

abstract class MediaUploadRepository {
  Future<UploadResult> uploadMedia(MediaDraft draft);
}
