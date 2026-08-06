//import 'dart:io';

import 'package:chat_app/core/media/models/media_draft.dart';

import '../models/upload_result.dart';
import '../services/upload_service.dart';

class UploadRepository {
  const UploadRepository(this._service);

  final UploadService _service;

  Future<UploadResult> uploadImage(MediaDraft draft) {
    return _service.uploadImage(draft);
  }

  Future<void> deleteImage(String url) {
    return _service.deleteImage(url);
  }
}
