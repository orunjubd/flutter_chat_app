import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chat_app/features/chat/data/models/message.dart';

class FullscreenMapViewer extends StatelessWidget {
  const FullscreenMapViewer({super.key, required this.message});

  final LocationMessage message;

  Future<void> _openInMaps() async {
    final uri = Uri.parse(
      'geo:${message.latitude},${message.longitude}?q=${message.latitude},${message.longitude}',
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final point = LatLng(message.latitude, message.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(message.address ?? 'Shared location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: _openInMaps,
            tooltip: 'Open in Maps',
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: point, initialZoom: 16),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.chat_app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: point,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 44,
                ),
              ),
            ],
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () =>
                    launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
