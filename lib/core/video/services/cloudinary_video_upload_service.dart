import 'dart:io';

import 'package:chat_app/core/media/models/media_draft.dart';
import 'package:chat_app/core/media/services/cloudinary_upload_service.dart';
import 'package:chat_app/core/video/models/video_upload_result.dart';
import 'package:chat_app/core/video/services/video_upload_service.dart';

class CloudinaryVideoUploadService extends VideoUploadService {
  const CloudinaryVideoUploadService(this._cloudinaryUploadService);

  final CloudinaryUploadService _cloudinaryUploadService;

  /// Uploads a video [MediaDraft] to Cloudinary.
  ///
  /// This service is responsible only for the video upload and for
  /// converting Cloudinary's response into [VideoUploadResult].
  ///
  /// It does NOT:
  /// - write to Firestore
  /// - send a message
  /// - manage chat state
  /// - manage local thumbnail cleanup
  @override
  Future<VideoUploadResult> upload({
    required MediaDraft draft,
    void Function(int sentBytes, int totalBytes)? onProgress,
  }) async {
    if (!draft.isVideo) {
      throw ArgumentError(
        'CloudinaryVideoUploadService requires '
        'a video MediaDraft.',
      );
    }

    final file = draft.file;

    if (!await file.exists()) {
      throw FileSystemException('Video file does not exist.', file.path);
    }

    final fileSize = draft.fileSize ?? await file.length();

    if (fileSize <= 0) {
      throw StateError('Cannot upload an empty video file.');
    }

    // The common Cloudinary service owns the actual HTTP upload.
    //
    // This keeps authentication/configuration/request handling
    // centralized rather than duplicating it here.
    final json = await _cloudinaryUploadService.uploadRaw(
      draft,
      onProgress: onProgress,
    );

    final secureUrl = json['secure_url'] as String?;
    final publicId = json['public_id'] as String?;
    final resourceType = json['resource_type'] as String?;
    final format = json['format'] as String?;

    if (secureUrl == null || secureUrl.isEmpty) {
      throw StateError('Cloudinary response did not contain secure_url.');
    }

    if (publicId == null || publicId.isEmpty) {
      throw StateError('Cloudinary response did not contain public_id.');
    }

    if (resourceType != 'video') {
      throw StateError(
        'Cloudinary returned an unexpected resource type: '
        '$resourceType',
      );
    }

    final uploadedBytes = (json['bytes'] as num?)?.toInt() ?? fileSize;

    final width =
        (json['width'] as num?)?.toDouble() ?? draft.width?.toDouble();

    final height =
        (json['height'] as num?)?.toDouble() ?? draft.height?.toDouble();

    final durationSeconds = (json['duration'] as num?)?.toDouble();

    final durationMs = durationSeconds != null
        ? (durationSeconds * 1000).round()
        : draft.durationMs;

    final mimeType = _resolveMimeType(format: format, fallback: draft.mimeType);

    final thumbnailUrl = _buildThumbnailUrl(secureUrl: secureUrl);

    return VideoUploadResult(
      url: secureUrl,
      publicId: publicId,
      mimeType: mimeType,
      bytes: uploadedBytes,
      width: width,
      height: height,
      durationMs: durationMs,
      thumbnailUrl: thumbnailUrl,
    );
  }

  String _resolveMimeType({
    required String? format,
    required String? fallback,
  }) {
    if (format != null && format.isNotEmpty) {
      return 'video/$format';
    }

    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }

    return 'video/mp4';
  }

  /// Converts the uploaded Cloudinary video URL into a JPG
  /// thumbnail URL.
  ///
  /// Example:
  ///
  /// video:
  /// https://res.cloudinary.com/demo/video/upload/v123/ece_chat_media/foo.mp4
  ///
  /// thumbnail:
  /// https://res.cloudinary.com/demo/video/upload/v123/ece_chat_media/foo.jpg
  String _buildThumbnailUrl({required String secureUrl}) {
    final uri = Uri.parse(secureUrl);

    final path = uri.path;

    final lastDot = path.lastIndexOf('.');

    final thumbnailPath = lastDot == -1
        ? '$path.jpg'
        : '${path.substring(0, lastDot)}.jpg';

    return uri.replace(path: thumbnailPath).toString();
  }
}
