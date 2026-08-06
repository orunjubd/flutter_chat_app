import 'dart:convert';
//import 'dart:io';

import 'package:chat_app/core/config/api_config.dart';
import 'package:chat_app/core/config/media_config.dart';
import 'package:chat_app/core/media/models/media_draft.dart';
import 'package:http/http.dart' as http;

import '../models/upload_config.dart';
import '../models/upload_result.dart';
import 'upload_service.dart';

class CloudinaryUploadService extends UploadService {
  CloudinaryUploadService(this._config);

  final UploadConfig _config;

  @override
  Future<UploadResult> uploadImage(MediaDraft draft) async {
    final file = draft.file;
    final uri = Uri.parse(
      ApiConfig.cloudinaryUploadUrl(cloudName: _config.cloudName),
    );

    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = _config.uploadPreset;

    request.fields['folder'] = MediaConfig.folder;

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(body);
    }

    final json = jsonDecode(body);

    return UploadResult(
      url: json['secure_url'],
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      bytes: json['bytes'],
      publicId: json['public_id'],
      mimeType: json['resource_type'] == 'image'
          ? 'image/${json['format']}'
          : 'application/octet-stream',
    );
  }

  @override
  Future<void> deleteImage(String url) async {
    // Cloudinary deletion requires a signed request.
    // We'll implement this later using your backend.
  }
}
