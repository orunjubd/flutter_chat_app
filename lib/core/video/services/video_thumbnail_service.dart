import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailService {
  const VideoThumbnailService();
  static const cacheDirName = 'video_thumbnails';

  /// Generates a local JPEG thumbnail for [videoFile].
  ///
  /// The generated file is stored in the application's temporary directory,
  /// under a unique name per call — this is NOT a content-addressed cache;
  /// picking the same source video twice will generate two separate
  /// thumbnail files, since image_picker copies videos into a fresh cache
  /// path on every pick anyway (see path structure in test logs).
  ///
  /// This thumbnail is intended for local/pending UI only. It must NOT be
  /// persisted as the message's Firestore `thumbnailUrl`, because the local
  /// file exists only on this device — the real, shareable thumbnailUrl
  /// comes from Cloudinary's upload response.
  ///
  /// TODO: no cleanup path exists yet for these files. Once
  /// MediaMessageSender.sendVideo() confirms the Cloudinary thumbnail is
  /// available, the local file this method returns should be deleted.
  Future<File?> generate(File videoFile) async {
    if (!await videoFile.exists()) {
      throw FileSystemException('Video file does not exist.', videoFile.path);
    }

    final tempDirectory = await getTemporaryDirectory();
    final thumbnailDirectory = Directory(
      '${tempDirectory.path}/video_thumbnails',
    );
    if (!await thumbnailDirectory.exists()) {
      await thumbnailDirectory.create(recursive: true);
    }

    final filename = '${DateTime.now().microsecondsSinceEpoch}.jpg';
    final outputPath = '${thumbnailDirectory.path}/$filename';

    final generatedPath = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      thumbnailPath: outputPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 640,
      quality: 75,
      timeMs: 0,
    );

    if (generatedPath == null || generatedPath.isEmpty) {
      return null;
    }

    final thumbnailFile = File(generatedPath);
    if (!await thumbnailFile.exists()) {
      return null;
    }

    return thumbnailFile;
  }

  Future<void> clearCache() async {
    final tempDir = await getTemporaryDirectory();
    final dir = Directory('${tempDir.path}/$cacheDirName');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
