import 'dart:convert';
import 'dart:typed_data';

import 'package:chat_app/core/config/api_config.dart';
import 'package:http/http.dart' as http;

/// Uploads optimized profile images to Cloudinary.
///
/// Responsibility:
///     optimized image bytes → Cloudinary → secure URL
///
/// This service does NOT:
/// - pick images
/// - optimize images
/// - update Firestore
/// - update Riverpod state
class CloudinaryProfileImageService {
  const CloudinaryProfileImageService({
    required this.cloudName,
    required this.uploadPreset,
  });

  final String cloudName;
  final String uploadPreset;

  /// Uploads a profile image to Cloudinary.
  ///
  /// Returns Cloudinary's secure HTTPS URL.
  Future<String> upload({
    required Uint8List imageBytes,
    required String userId,
  }) async {
    final uri = Uri.parse(
      ApiConfig.cloudinaryUploadUrl(
        cloudName: cloudName,
        resourceType: 'image',
      ),
    );

    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = uploadPreset;

    // Keep profile images separate from chat media.
    request.fields['folder'] = 'ece/profile_images';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'profile_$userId.jpg',
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Cloudinary profile image upload failed '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final secureUrl = data['secure_url'];

    if (secureUrl is! String || secureUrl.trim().isEmpty) {
      throw const FormatException(
        'Cloudinary did not return a valid secure_url.',
      );
    }

    return secureUrl;
  }
}
