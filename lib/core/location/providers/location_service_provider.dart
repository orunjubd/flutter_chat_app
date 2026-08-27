import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/location/services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});
