import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:chat_app/core/location/models/location_draft.dart';
import 'package:chat_app/core/location/services/location_service.dart';

class LocationPreviewScreen extends StatefulWidget {
  const LocationPreviewScreen({
    super.key,
    required this.draft,
    required this.onSend,
  });

  final LocationDraft draft;
  final Future<void> Function(LocationDraft draft) onSend;

  @override
  State<LocationPreviewScreen> createState() => _LocationPreviewScreenState();
}

class _LocationPreviewScreenState extends State<LocationPreviewScreen> {
  final LocationService _locationService = const LocationService();

  late LatLng _selected = LatLng(widget.draft.latitude, widget.draft.longitude);
  String? _address;
  bool _resolvingAddress = false;
  bool _sending = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _address = widget.draft.address;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onMapMoved(MapCamera camera, bool hasGesture) {
    _selected = camera.center;
    if (!hasGesture) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      setState(() => _resolvingAddress = true);

      final address = await _locationService.reverseGeocode(
        _selected.latitude,
        _selected.longitude,
      );

      if (!mounted) return;
      setState(() {
        _address = address;
        _resolvingAddress = false;
      });
    });
  }

  Future<void> _sendLocation() async {
    if (_sending) return;
    setState(() => _sending = true);

    final finalDraft = widget.draft.copyWith(
      latitude: _selected.latitude,
      longitude: _selected.longitude,
      address: _address,
    );

    try {
      await widget.onSend(finalDraft);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to send location: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send location')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _selected,
                    initialZoom: 16,
                    onPositionChanged: _onMapMoved,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName:
                          'com.yourcompany.chatapp', // your real applicationId
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          '© OpenStreetMap contributors © CARTO',
                        ),
                      ],
                    ),
                  ],
                ),
                // Fixed center pin — never inside MarkerLayer, since it
                // must stay screen-anchored while the map pans under it.
                const IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 36,
                      ), // visually anchor the tip, not the icon center
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _resolvingAddress
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _address ??
                        '${_selected.latitude.toStringAsFixed(5)}, '
                            '${_selected.longitude.toStringAsFixed(5)}',
                    textAlign: TextAlign.center,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _sending ? null : _sendLocation,
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: const Text('Send location'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
