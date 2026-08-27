// // lib/core/location/services/location_capture_service.dart

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// import 'package:chat_app/core/location/models/location_draft.dart';

// class LocationCaptureService {
//   const LocationCaptureService();

//   Future<LocationDraft?> captureCurrentLocation() async {
//     try {
//       final serviceEnabled = await Geolocator.isLocationServiceEnabled();

//       if (!serviceEnabled) {
//         throw StateError(
//           'Location services are disabled. Please enable location services.',
//         );
//       }

//       var permission = await Geolocator.checkPermission();

//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }

//       if (permission == LocationPermission.denied) {
//         throw StateError('Location permission was denied.');
//       }

//       if (permission == LocationPermission.deniedForever) {
//         throw StateError('Location permission is permanently denied.');
//       }

//       debugPrint('📍 Requesting current location...');

//       final position = await Geolocator.getCurrentPosition(
//         locationSettings: const LocationSettings(
//           accuracy: LocationAccuracy.high,
//         ),
//       );

//       debugPrint(
//         '📍 Location captured: '
//         '${position.latitude}, ${position.longitude}',
//       );

//       return LocationDraft(
//         latitude: position.latitude,
//         longitude: position.longitude,
//       );
//     } catch (e) {
//       debugPrint('❌ Location capture failed: $e');
//       rethrow;
//     }
//   }
// }
