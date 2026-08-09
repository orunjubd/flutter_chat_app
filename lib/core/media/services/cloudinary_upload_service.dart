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
  Future<UploadResult> uploadMedia(MediaDraft draft) async {
    final file = draft.file;

    final String targetRoute = draft.type == MediaType.image ? 'image' : 'raw';

    final uri = Uri.parse(
      ApiConfig.cloudinaryUploadUrl(
        cloudName: _config.cloudName,
        resourceType: targetRoute,
      ),
    );

    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = _config.uploadPreset;
    request.fields['folder'] = MediaConfig.folder;

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(
        'Cloudinary upload failed '
        '(${response.statusCode}): $body',
      );
    }

    final json = jsonDecode(body) as Map<String, dynamic>;

    final resourceType = json['resource_type'] as String?;
    final format = json['format'] as String?;

    return UploadResult(
      url: json['secure_url'] as String? ?? '',
      publicId: json['public_id'] as String? ?? '',
      mimeType: _resolveMimeType(
        resourceType: resourceType,
        format: format,
        fallback: draft.mimeType ?? 'application/octet-stream',
      ),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      bytes: (json['bytes'] as num?)?.toInt(),
    );
  }

  String _resolveMimeType({
    required String? resourceType,
    required String? format,
    required String fallback,
  }) {
    if (resourceType == 'image' && format != null) {
      return 'image/$format';
    }

    if (resourceType == 'video' && format != null) {
      return 'video/$format';
    }

    // Cloudinary's "raw" resource type covers files such as:
    // PDF, DOCX, ZIP, RAR, etc.
    if (resourceType == 'raw') {
      return fallback;
    }

    return fallback;
  }

  @override
  Future<void> deleteMedia(String url) async {
    // Cloudinary deletion requires a signed request.
    // We'll implement provider-side deletion later.
  }
}
