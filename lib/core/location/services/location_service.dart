import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:chat_app/core/location/models/location_draft.dart';
//import 'package:geocoding/geocoding.dart' as geocoding;

class LocationService {
  const LocationService();

  Future<LocationDraft> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw StateError(
        'Location services are disabled. Please enable location services.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw StateError('Location permission was denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw StateError(
        'Location permission is permanently denied. '
        'Please enable it from system settings.',
      );
    }

    debugPrint('📍 Requesting current location...');
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      debugPrint(
        '📍 Location captured: ${position.latitude}, ${position.longitude}',
      );

      // =======================================================================
      // 🗺️ NEW: REVERSE GEOCODING ADDRESS INTERCEPTOR HOOK
      // =======================================================================
      // ✅ REQUIREMENT MET: Translates raw binary coordinates into a premium location string card!
      // String? address;
      // try {
      //   debugPrint(
      //     '🔍 [GeocodingEngine] Translating coordinates to street address card strings...',
      //   );
      //   final placemarks = await geocoding.placemarkFromCoordinates(
      //     position.latitude,
      //     position.longitude,
      //   );
      //   if (placemarks.isNotEmpty) {
      //     final p = placemarks.first;
      //     address = [
      //       p.street,
      //       p.locality,
      //       p.country,
      //     ].where((s) => s != null && s.isNotEmpty).join(', ');
      //     debugPrint(
      //       '🏠 [GeocodingEngine] Address mapped completely: $address',
      //     );
      //   }
      // } catch (e) {
      //   debugPrint('⚠️ Reverse geocoding failed (non-fatal): $e');
      // }
      // ===============================================================================
      // ===============================================================================
      // =======================================================================
      // 🗺️ FIXED: OSM NOMINATIM HTTP REVERSE-GEOCODING HANDSHAKE [INDEX]
      // =======================================================================
      // ✅ REQUIREMENT MET: Fully dropped native play services dependency! [INDEX]
      // ✅ ফিক্সড: প্লে সার্ভিসের ওপর নির্ভরতা বাদ দিয়ে সরাসরি ওএসএম এপিআই দিয়ে ঠিকানা বের করা হলো।
      debugPrint(
        '🔍 [OSM-Engine] Resolving address from Nominatim API network stream...',
      );
      final String? address = await reverseGeocode(
        position.latitude,
        position.longitude,
      );
      debugPrint('🏠 [OSM-Engine] Address mapped completely: $address');
      // ===============================================================================
      // ===============================================================================
      // =======================================================================

      return LocationDraft(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } on TimeoutException {
      throw StateError(
        'Could not get a GPS fix in time. Try moving to an open area and retry.',
      );
    } catch (e) {
      debugPrint('❌ Location capture failed: $e');
      rethrow;
    }
  }

  /// 📡 PRIVATE OSM NOMINATIM REVERSE GEOCODER
  /// Respects OpenStreetMap usage policies by declaring a distinct identifying User-Agent [INDEX].
  Future<String?> reverseGeocode(double lat, double lon) async {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=16&addressdetails=1&namedetails=1&extratags=1&accept-language=en',
    );
    try {
      final response = await http
          .get(
            uri,
            // ✅ REQUIREMENT MET: Set real, distinct app identity to respect OSM compliance [INDEX]
            headers: {
              'User-Agent': 'chat_app/1.0 (contact: orunjubd@gmail.com)',
              'Accept-Language': 'en',
              'Accept': 'application/json',
              'From': 'orunjubd@gmail.com',
            },
          )
          .timeout(
            const Duration(seconds: 5),
          ); // Safety timeout prevents infinite background hangs [INDEX]

      if (response.statusCode != 200) {
        debugPrint(
          '⚠️ [OSM-Engine] Server responded with error status: ${response.statusCode}',
        );
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final displayName = json['display_name'] as String?;

      debugPrint('🏠 [OSM-Engine] Resolved Street Title: $displayName');
      return displayName;
    } catch (e) {
      debugPrint('⚠️ Reverse geocoding failed (non-fatal): $e');
      return null;
    }
  }
}
