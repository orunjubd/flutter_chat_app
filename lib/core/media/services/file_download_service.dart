import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FileDownloadService {
  const FileDownloadService();

  /// Downloads a remote file into the application's temporary
  /// directory and returns the resulting local File.
  ///
  /// This is intentionally independent of Cloudinary.
  /// Any HTTPS file URL can be supplied.
  Future<File> downloadFile({
    required String url,
    required String fileName,
  }) async {
    final uri = Uri.tryParse(url);

    if (uri == null || !uri.hasScheme) {
      throw const FileDownloadException('The supplied file URL is invalid.');
    }

    if (uri.scheme != 'https' && uri.scheme != 'http') {
      throw const FileDownloadException(
        'Only HTTP and HTTPS downloads are supported.',
      );
    }

    final response = await http
        .get(
          uri,
          headers: {
            'Accept':
                '*/*', // Instructs Cloudinary that the app accepts any raw binary stream output format safely
            'User-Agent': 'ECE-Chat-App/1.0',
          },
        )
        .timeout(const Duration(minutes: 2));

    debugPrint('🌐 Download HTTP status: ${response.statusCode}');
    debugPrint('🌐 Content-Type: ${response.headers['content-type']}');
    debugPrint('🌐 Content-Length: ${response.headers['content-length']}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('❌ Cloudinary download response:');
      debugPrint(
        response.body.length > 500
            ? response.body.substring(0, 500)
            : response.body,
      );

      throw FileDownloadException(
        'Download failed with HTTP ${response.statusCode}.',
      );
    }

    if (response.bodyBytes.isEmpty) {
      throw const FileDownloadException('The downloaded file is empty.');
    }

    final directory = await getTemporaryDirectory();

    final safeFileName = _sanitizeFileName(fileName);

    final file = File(
      '${directory.path}${Platform.pathSeparator}$safeFileName',
    );

    await file.writeAsBytes(response.bodyBytes, flush: true);

    if (!await file.exists()) {
      throw const FileDownloadException(
        'The downloaded file could not be created.',
      );
    }

    final fileLength = await file.length();

    if (fileLength == 0) {
      throw const FileDownloadException('The downloaded file is empty.');
    }

    return file;
  }

  /// Prevents accidental path traversal when a filename comes
  /// from remote/database data.
  String _sanitizeFileName(String fileName) {
    final trimmed = fileName.trim();

    if (trimmed.isEmpty) {
      return 'downloaded_file';
    }

    final sanitized = trimmed
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return sanitized.isEmpty ? 'downloaded_file' : sanitized;
  }
}

class FileDownloadException implements Exception {
  const FileDownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}
