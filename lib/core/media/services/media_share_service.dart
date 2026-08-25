// lib/core/media/services/media_share_service.dart
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Downloads a remote media file to a local temp file so it can be
/// shared as actual bytes (via share_plus's `files:`), not a bare
/// link — matching how WhatsApp/Telegram share media.
///
/// TODO: no cleanup exists yet for these temp files — same open item
/// as VideoThumbnailService's local thumbnails. Worth revisiting
/// together at some point (e.g. periodic temp-dir sweep on app start).
class MediaShareService {
  const MediaShareService();
  static const cacheDirName = 'share_cache';

  Future<File> downloadToTempFile(
    String url, {
    required String fileName,
    void Function(int receivedBytes, int? totalBytes)? onProgress,
  }) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('Failed to download media (${response.statusCode}).');
      }

      final tempDir = await getTemporaryDirectory();
      final shareDir = Directory('${tempDir.path}/share_cache');
      if (!await shareDir.exists()) {
        await shareDir.create(recursive: true);
      }

      final file = File(
        '${shareDir.path}/${DateTime.now().microsecondsSinceEpoch}_$fileName',
      );
      final sink = file.openWrite();

      var received = 0;
      final total = response.contentLength;

      await response.stream.forEach((chunk) {
        received += chunk.length;
        sink.add(chunk);
        onProgress?.call(received, total);
      });

      await sink.close();
      return file;
    } finally {
      client.close();
    }
  }

  /// Derives a reasonable filename from a URL's last path segment,
  /// falling back to [fallback] if none is present.
  String fileNameFromUrl(String url, {required String fallback}) {
    final path = Uri.parse(url).path;
    final segment = path
        .split('/')
        .lastWhere((s) => s.isNotEmpty, orElse: () => '');
    return segment.isEmpty ? fallback : segment;
  }

  Future<void> clearCache() async {
    final tempDir = await getTemporaryDirectory();
    final dir = Directory('${tempDir.path}/$cacheDirName');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
