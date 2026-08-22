class MediaConfig {
  const MediaConfig._();

  /// Cloudinary
  static const String cloudName = 'ktbhangj';

  static const String uploadPreset = 'ece_chat_preset';

  /// Optional future folder
  static const String folder = 'ece_chat_media';

  /// Upload timeout
  static const Duration uploadTimeout = Duration(minutes: 2);

  /// Maximum upload size
  static const int maxImageSizeInMB = 10;

  /// Maximum image width
  static const int maxImageWidth = 1920;

  /// Maximum image height
  static const int maxImageHeight = 1920;

  static const int imageQuality = 90; // 0-100

  /// Maximum video upload size
  static const int maxVideoSizeInMB = 100;

  /// Maximum video width
  static const int maxVideoWidth = 1280;

  /// Maximum video height
  static const int maxVideoHeight = 720;

  static const int videoQuality =
      80; // 0-100, used if compressing before upload

  /// Maximum video duration
  static const Duration maxVideoDuration = Duration(minutes: 5);

  /// Convenience getter — bytes derived from MB, matching how the
  /// picker service checks fileSize (which is in bytes).
  static int get maxVideoSizeInBytes => maxVideoSizeInMB * 1024 * 1024;

  /// শুধু debug/testing এর জন্য। true হলে pick করার সময়
  /// maxVideoWidth/maxVideoHeight ছাড়ানো ভিডিও reject হবে।
  /// production-এ অবশ্যই false থাকতে হবে — resolution limit
  /// ভবিষ্যতের compression/resize ধাপের জন্য, valid 4K আপলোড
  /// reject করার জন্য নয়।
  static const bool enforceVideoResolutionForTesting = false;

  static const Set<String> allowedVideoMimeTypes = {
    'video/mp4',
    'video/quicktime', // .mov
    'video/x-matroska', // .mkv
    'video/webm',
  };

  static const Set<String> allowedVideoExtensions = {
    'mp4',
    'mov',
    'mkv',
    'webm',
  };
}
