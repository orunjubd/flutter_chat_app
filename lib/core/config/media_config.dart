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
}
