// core/video/services/flutter_compress_video_compression_service.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_compress/flutter_compress.dart';

import 'package:chat_app/core/media/models/media_draft.dart';
import 'package:chat_app/core/video/services/video_compression_service.dart';
import 'package:chat_app/core/video/services/video_metadata_service.dart';

class FlutterCompressVideoCompressionService extends VideoCompressionService {
  const FlutterCompressVideoCompressionService(this._metadataService);

  final VideoMetadataService _metadataService;

  /// Longest side after compression. Downscale-only — a video already
  /// smaller than this on both dimensions is left unchanged, matching
  /// the target table (e.g. 640×360 stays 640×360).
  static const int maxDimension = 1080;

  @override
  Future<MediaDraft> compress(MediaDraft draft) async {
    if (!draft.isVideo) {
      throw ArgumentError(
        'VideoCompressionService requires a video MediaDraft.',
      );
    }
    // =======================================================================
    // 🚀 THE RESOLUTION SKIELD HOOK: EARLY VALIDATION ESCAPE PATH
    // =======================================================================
    // ✅ REQUIREMENT MET: Video files smaller than 1080p completely bypass the re-encoding thread!
    // ✅ ফিক্সড: ভিডিওর রেজোলিউশন অলরেডি ১০৮০p এর নিচে থাকলে কম্প্রেসার ইঞ্জিন রান না হয়ে ডিরেক্ট রিটার্ন হবে!
    final width = draft.width;
    final height = draft.height;

    if (width != null &&
        height != null &&
        width <= maxDimension &&
        height <= maxDimension) {
      debugPrint(
        '⚡ [CompressionEngine] Video is already optimized ($width x $height). Skipping hardware re-encoding loop.',
      );
      return draft; // Instant return prevents laggy processing passes [INDEX]!
    }
    // ------------------------------------------------------------
    // 🎬 Video Processing Pipeline continues below if video is heavy
    // -----------------------------------------------------------
    final api = FlutterCompress.instance;

    const config = VideoCompressConfig(
      maxWidth: maxDimension,
      maxHeight: maxDimension,
      codec: VideoCodec
          .h264, // force H.264 — HEVC আর্টিফ্যাক্ট এড়াতে প্রয়োজন হয় না
    );

    debugPrint('Compression target: max ${maxDimension}x$maxDimension');

    final result = await api.compress(draft.file.path, config);

    // Instantiate the physical file object first so we can securely read its metrics [INDEX]
    final outputFile = File(result.outputPath);

    final int compressedBytes = await outputFile.length();
    debugPrint(
      '🎥 After compression: '
      '${result.width}x${result.height}, $compressedBytes bytes',
    );

    // Re-derive real metadata from the compressed output rather than
    // trusting the compressor's own reported dimensions — reuses the
    // same extraction step already confirmed reliable in the picker flow.
    final metadata = await _metadataService.extract(outputFile);
    final fileSize = await outputFile.length();

    return draft.copyWith(
      file: outputFile,
      fileSize: fileSize,
      mimeType: 'video/mp4',
      width: metadata.width,
      height: metadata.height,
      durationMs: metadata.duration.inMilliseconds,
    );
  }
}
