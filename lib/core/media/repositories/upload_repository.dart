//import 'dart:io';

import 'package:chat_app/core/media/models/media_draft.dart';

import '../models/upload_result.dart';
import '../services/upload_service.dart';

class UploadRepository {
  const UploadRepository(this._service);

  final UploadService _service;

  Future<UploadResult> uploadMedia(MediaDraft draft) {
    return _service.uploadMedia(draft);
  }

  Future<void> deleteMedia(String url) {
    return _service.deleteMedia(url);
  }
}
