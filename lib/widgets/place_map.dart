import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_app/models/poi.dart';

class PlaceMap extends StatelessWidget {
  const PlaceMap({
    super.key,
    required this.lat,
    required this.lng,
    this.pois,
    this.height,
    this.borderRadius = 15,
    this.zoom = 14,
  });

  final double lat;
  final double lng;
  final List<Poi>? pois;
  final double? height;
  final double borderRadius;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final center = LatLng(lat, lng);

    final poiMarkers = (pois ?? []).map((p) {
      return Marker(
        point: LatLng(p.lat, p.lng),
        width: 34,
        height: 34,
        child: Tooltip(
          message: p.name,
          child: const Icon(Icons.location_pin, size: 34, color: Colors.blue),
        ),
      );
    }).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height, // ✅ parent controls height now
        width: double.infinity,
        child: FlutterMap(
          options: MapOptions(initialCenter: center, initialZoom: zoom),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: "com.example.travel_app",
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 44,
                  height: 44,
                  child: const Icon(Icons.location_pin, size: 44, color: Colors.red),
                ),
                ...poiMarkers,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
