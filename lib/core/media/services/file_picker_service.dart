import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'package:chat_app/core/media/models/file_draft.dart';
import 'package:flutter/foundation.dart';

class FilePickerService {
  const FilePickerService();

  Future<FileDraft?> pickSingleFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: false,
    );

    if (result == null) {
      return null;
    }

    final picked = result.files.single;

    if (picked.path == null) {
      return null;
    }

    final draft = FileDraft(
      file: File(picked.path!),
      fileName: picked.name,
      mimeType: detectMimeType(picked.name),
      fileSize: picked.size,
    );

    debugPrint('✅ FileDraft created');
    debugPrint('   name: ${draft.fileName}');
    debugPrint('   mime: ${draft.mimeType}');
    debugPrint('   size: ${draft.fileSize}');

    return draft;
  }

  String detectMimeType(String fileName) {
    final lower = fileName.toLowerCase();

    if (lower.endsWith('.pdf')) {
      return 'application/pdf';
    }

    if (lower.endsWith('.doc')) {
      return 'application/msword';
    }

    if (lower.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }

    if (lower.endsWith('.xls')) {
      return 'application/vnd.ms-excel';
    }

    if (lower.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }

    if (lower.endsWith('.zip')) {
      return 'application/zip';
    }

    if (lower.endsWith('.apk')) {
      return 'application/vnd.android.package-archive';
    }

    if (lower.endsWith('.png')) {
      return 'image/png';
    }

    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }

    if (lower.endsWith('.mp3')) {
      return 'audio/mpeg';
    }

    if (lower.endsWith('.mp4')) {
      return 'video/mp4';
    }

    if (lower.endsWith('.txt')) {
      return 'text/plain';
    }

    if (lower.endsWith('.json')) {
      return 'application/json';
    }

    if (lower.endsWith('.csv')) {
      return 'text/csv';
    }

    if (lower.endsWith('.rar')) {
      return 'application/vnd.rar';
    }

    if (lower.endsWith('.7z')) {
      return 'application/x-7z-compressed';
    }

    return 'application/octet-stream';
  }
}
