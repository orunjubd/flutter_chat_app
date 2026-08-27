import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/core/location/screen/fullscreen_map_viewer.dart';

class LocationMessageBubble extends StatelessWidget {
  const LocationMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  final LocationMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(message.latitude, message.longitude);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FullscreenMapViewer(message: message),
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 220, maxWidth: 260),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 160,
              child: IgnorePointer(
                child: FlutterMap(
                  options: MapOptions(initialCenter: point, initialZoom: 15),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.chat_app', // match your applicationId
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (message.address != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  message.address!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// String _osmTileUrl(double lat, double lon, {required int zoom}) {
//   final x = ((lon + 180.0) / 360.0 * (1 << zoom)).floor();
//   final latRad = lat * pi / 180.0;
//   final y =
//       ((1.0 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2.0 * (1 << zoom))
//           .floor();
//   return 'https://tile.openstreetmap.org/$zoom/$x/$y.png';
// }
