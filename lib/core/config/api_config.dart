class ApiConfig {
  const ApiConfig._();

  static String cloudinaryUploadUrl({
    required String cloudName,
    required String resourceType,
  }) {
    return 'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload';
  }
}
