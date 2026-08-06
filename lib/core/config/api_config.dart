class ApiConfig {
  const ApiConfig._();

  /// Cloudinary upload endpoint
  static String cloudinaryUploadUrl({required String cloudName}) {
    return 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
  }
}
