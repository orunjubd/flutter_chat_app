import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/media_compression_service.dart';

final mediaCompressionProvider = Provider<MediaCompressionService>((ref) {
  return const MediaCompressionService();
});
