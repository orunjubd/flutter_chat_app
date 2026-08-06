import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/image_processing_service.dart';

final imageProcessingProvider = Provider<ImageProcessingService>((ref) {
  return const ImageProcessingService();
});
