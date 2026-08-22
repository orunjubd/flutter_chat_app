import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:chat_app/core/config/api_config.dart';
import 'package:chat_app/core/config/media_config.dart';
import 'package:chat_app/core/media/models/media_draft.dart';
import 'package:chat_app/core/media/models/media_type.dart';
import '../models/upload_config.dart';
import '../models/upload_result.dart';
import 'upload_service.dart';

class CloudinaryUploadService extends UploadService {
  CloudinaryUploadService(this._config);
  final UploadConfig _config;

  String _resourceTypeFor(MediaType type) {
    switch (type) {
      case MediaType.image:
        return 'image';
      case MediaType.audio:
      case MediaType.video:
        return 'video';
      case MediaType.document:
        return 'raw';
    }
  }

  /// Performs the actual Cloudinary HTTP upload and returns the decoded
  /// response as-is. Exposed separately from [uploadMedia] so callers
  /// that need fields beyond [UploadResult] (e.g. video's `duration`)
  /// can read them from the same response without a second HTTP call
  /// or duplicating the request/error-handling logic here.
  Future<Map<String, dynamic>> uploadRaw(
    MediaDraft draft, {
    void Function(int sentBytes, int totalBytes)? onProgress,
  }) async {
    final file = draft.file;

    final targetRoute = _resourceTypeFor(draft.type);

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

    final client = http.Client();

    try {
      if (onProgress == null) {
        final response = await client.send(request);

        final body = await response.stream.bytesToString();

        if (response.statusCode != 200) {
          final errorSnippet = body.length > 300
              ? body.substring(0, 300)
              : body;

          throw Exception(
            'Cloudinary upload failed '
            '(${response.statusCode}): $errorSnippet',
          );
        }

        return jsonDecode(body) as Map<String, dynamic>;
      }

      // ------------------------------------------------------------
      // REAL PROGRESS UPLOAD
      // ------------------------------------------------------------

      final totalBytes = request.contentLength;

      var sentBytes = 0;

      final finalizedStream = request.finalize();

      final streamedRequest = http.StreamedRequest(request.method, request.url)
        ..headers.addAll(request.headers)
        ..contentLength = totalBytes;

      // IMPORTANT:
      // Start the HTTP request FIRST.
      //
      // Cloudinary must be consuming the sink while we write chunks.
      final responseFuture = client.send(streamedRequest);

      final trackedStream = finalizedStream.transform(
        StreamTransformer<List<int>, List<int>>.fromHandlers(
          handleData: (chunk, sink) {
            sentBytes += chunk.length;

            onProgress(sentBytes, totalBytes);

            sink.add(chunk);
          },
        ),
      );

      try {
        await trackedStream.forEach(streamedRequest.sink.add);

        await streamedRequest.sink.close();
      } catch (e) {
        await streamedRequest.sink.close();

        rethrow;
      }

      // Now wait for Cloudinary's HTTP response.
      final response = await responseFuture;

      final body = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        final errorSnippet = body.length > 300 ? body.substring(0, 300) : body;

        throw Exception(
          'Cloudinary upload failed '
          '(${response.statusCode}): $errorSnippet',
        );
      }

      // Make absolutely sure the UI reaches 100%.
      onProgress(totalBytes, totalBytes);

      return jsonDecode(body) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  /// Builds the common [UploadResult] from a raw Cloudinary response.
  /// Reusable so callers that already have the raw JSON (e.g. video)
  /// don't need to re-fetch or re-decode it.
  UploadResult buildResult(MediaDraft draft, Map<String, dynamic> json) {
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

  @override
  Future<UploadResult> uploadMedia(MediaDraft draft) async {
    final json = await uploadRaw(draft);
    return buildResult(draft, json);
  }

  String _resolveMimeType({
    required String? resourceType,
    required String? format,
    required String fallback,
  }) {
    if (resourceType == 'image' && format != null) return 'image/$format';
    if (resourceType == 'video' && format != null) return 'video/$format';
    // Cloudinary's "raw" resource type covers files such as:
    // PDF, DOCX, ZIP, RAR, etc.
    if (resourceType == 'raw') {
      return fallback;
    }
    return fallback;
  }

  @override
  Future<void> deleteMedia(String publicId) async {
    // Cloudinary deletion requires a signed request.
    // We'll implement provider-side deletion later.
  }
}
