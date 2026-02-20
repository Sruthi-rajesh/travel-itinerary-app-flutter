import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:travel_app/models/poi.dart';

class OverpassService {
  final List<String> endpoints;

  OverpassService({
    List<String>? endpoints,
  }) : endpoints = endpoints ??
            const [
              "https://overpass-api.de/api/interpreter",
              "https://overpass.kumi.systems/api/interpreter",
              "https://overpass.nchc.org.tw/api/interpreter",
            ];

  Future<List<Poi>> fetchNearbyPois({
    required double lat,
    required double lng,
    required String mode,
    int radiusMeters = 1200,
    int limit = 30,
  }) async {
    final query = _buildQuery(lat: lat, lng: lng, radius: radiusMeters, mode: mode);

    Exception? lastError;

    for (final endpoint in endpoints) {
      try {
        final res = await http
            .post(
              Uri.parse(endpoint),
              headers: {
                "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
                // helps some servers identify your app
                "User-Agent": "travel_app_flutter/1.0 (contact: you@example.com)",
              },
              body: {"data": query},
            )
            .timeout(const Duration(seconds: 25));

        if (res.statusCode != 200) {
          throw Exception("Overpass failed: ${res.statusCode}");
        }

        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final elements = (json["elements"] as List).cast<Map<String, dynamic>>();

        final raw = <Poi>[];
        for (final e in elements) {
          final tags = (e["tags"] as Map?)?.cast<String, dynamic>() ?? {};
          final name = (tags["name"]?.toString().trim() ?? "");
          if (name.isEmpty) continue;

          final latVal = (e["lat"] ?? e["center"]?["lat"]) as num?;
          final lngVal = (e["lon"] ?? e["center"]?["lon"]) as num?;
          if (latVal == null || lngVal == null) continue;

          raw.add(
            Poi(
              id: "${e["type"]}:${e["id"]}",
              name: name,
              type: _inferType(tags, mode),
              lat: latVal.toDouble(),
              lng: lngVal.toDouble(),
              address: _formatAddress(tags),
            ),
          );
        }

        // dedupe
        final deduped = <Poi>[];
        for (final p in raw) {
          final key = _normalizeName(p.name);
          final exists = deduped.any((x) {
            final sameName = _normalizeName(x.name) == key;
            final close = _distanceMeters(x.lat, x.lng, p.lat, p.lng) < 80;
            return sameName && close;
          });
          if (!exists) deduped.add(p);
        }

        deduped.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return deduped.take(limit).toList();
      } catch (e) {
        lastError = Exception("Endpoint $endpoint failed: $e");
        continue; // try next mirror
      }
    }

    throw lastError ?? Exception("All Overpass endpoints failed.");
  }

  String _buildQuery({
    required double lat,
    required double lng,
    required int radius,
    required String mode,
  }) {
    final filters = mode == "food"
        ? '''
node(around:$radius,$lat,$lng)["amenity"~"restaurant|cafe|fast_food|bar|pub"];
way(around:$radius,$lat,$lng)["amenity"~"restaurant|cafe|fast_food|bar|pub"];
relation(around:$radius,$lat,$lng)["amenity"~"restaurant|cafe|fast_food|bar|pub"];
'''
        : '''
node(around:$radius,$lat,$lng)["shop"~"supermarket|mall|convenience|department_store|clothes|shoes|electronics"];
way(around:$radius,$lat,$lng)["shop"~"supermarket|mall|convenience|department_store|clothes|shoes|electronics"];
relation(around:$radius,$lat,$lng)["shop"~"supermarket|mall|convenience|department_store|clothes|shoes|electronics"];
''';

    return '''
[out:json][timeout:25];
(
$filters
);
out center;
''';
  }

  String _inferType(Map<String, dynamic> tags, String mode) {
    if (mode == "food") {
      final a = tags["amenity"]?.toString();
      return (a == null || a.isEmpty) ? "food" : a;
    } else {
      final s = tags["shop"]?.toString();
      return (s == null || s.isEmpty) ? "shopping" : s;
    }
  }

  String? _formatAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    final house = tags["addr:housenumber"]?.toString();
    final street = tags["addr:street"]?.toString();
    final suburb = tags["addr:suburb"]?.toString();
    final city = tags["addr:city"]?.toString();

    final line1 = [house, street].where((x) => x != null && x.trim().isNotEmpty).join(" ");
    if (line1.trim().isNotEmpty) parts.add(line1);

    final line2 = [suburb, city].where((x) => x != null && x.trim().isNotEmpty).join(", ");
    if (line2.trim().isNotEmpty) parts.add(line2);

    return parts.isEmpty ? null : parts.join(" • ");
  }

  String _normalizeName(String s) {
    return s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double d) => d * (pi / 180.0);
}
