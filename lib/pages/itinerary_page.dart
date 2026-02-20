import 'dart:math';
import 'package:flutter/material.dart';
import 'package:travel_app/models/place.dart';
import 'package:travel_app/models/poi.dart';
import 'package:travel_app/services/overpass_service.dart';
import 'package:travel_app/widgets/place_map.dart';
import 'package:url_launcher/url_launcher.dart';

enum SortMode { closest, az }

class ItineraryPage extends StatefulWidget {
  const ItineraryPage({super.key, required this.place});
  final Place place;

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  final _overpass = OverpassService();
  SortMode _sortMode = SortMode.closest;

  late Future<List<Poi>> _foodFuture;
  late Future<List<Poi>> _shoppingFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _foodFuture = _overpass.fetchNearbyPois(
      lat: widget.place.lat,
      lng: widget.place.lng,
      mode: "food",
      radiusMeters: 1200,
      limit: 30,
    );

    _shoppingFuture = _overpass.fetchNearbyPois(
      lat: widget.place.lat,
      lng: widget.place.lng,
      mode: "shopping",
      radiusMeters: 1200,
      limit: 30,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Itinerary"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Food"),
              Tab(text: "Shopping"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reload,
              tooltip: "Retry",
            ),
            PopupMenuButton<SortMode>(
              icon: const Icon(Icons.sort),
              onSelected: (m) => setState(() => _sortMode = m),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: SortMode.closest,
                  child: Text("Sort: Closest"),
                ),
                PopupMenuItem(
                  value: SortMode.az,
                  child: Text("Sort: A–Z"),
                ),
              ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your plan for:",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Text(
                place.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                "Tap a place to open it in Google Maps",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _PoiTab(
                      place: place,
                      future: _foodFuture,
                      sortMode: _sortMode,
                    ),
                    _PoiTab(
                      place: place,
                      future: _shoppingFuture,
                      sortMode: _sortMode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PoiTab extends StatelessWidget {
  const _PoiTab({
    required this.place,
    required this.future,
    required this.sortMode,
  });

  final Place place;
  final Future<List<Poi>> future;
  final SortMode sortMode;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Poi>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return _InfoBox(
            text:
                "Could not load nearby places.\n\nError:\n${snap.error}\n\nTip: On Flutter Web this can be Overpass rate-limit / server timeout. Tap refresh to retry, or test on Android/iOS emulator.",
          );
        }

        final data = snap.data;
        if (data == null || data.isEmpty) {
          return const _InfoBox(text: "No places found nearby.");
        }

        var pois = data;

        // Sort
        if (sortMode == SortMode.closest) {
          pois = [...pois]
            ..sort((a, b) {
              final da = _distanceMeters(place.lat, place.lng, a.lat, a.lng);
              final db = _distanceMeters(place.lat, place.lng, b.lat, b.lng);
              return da.compareTo(db);
            });
        } else {
          pois = [...pois]
            ..sort((a, b) =>
                a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        }

        return Column(
          children: [
            // ✅ FIX overflow: give map a fixed height
            SizedBox(
              height: 220,
              child: PlaceMap(
                lat: place.lat,
                lng: place.lng,
                pois: pois.take(20).toList(),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.separated(
                itemCount: pois.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final p = pois[i];
                  final dist =
                      _distanceMeters(place.lat, place.lng, p.lat, p.lng);

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _openInGoogleMaps(p.lat, p.lng, p.name),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.08),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.place_outlined, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  p.address ?? "Address not available",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${dist.toStringAsFixed(0)} m away",
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          _TypeChip(text: p.type),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ Fix 3: reliable Google Maps open on Flutter Web (new tab)
  static Future<void> _openInGoogleMaps(double lat, double lng, String name) async {
    final url =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    await launchUrl(url, webOnlyWindowName: '_blank');
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = text.toUpperCase().replaceAll("_", " ");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
      ),
      child: Text(
        t,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
      ),
      child: Text(text),
    );
  }
}

// Distance helpers
double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371000.0;
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) *
          cos(_deg2rad(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _deg2rad(double d) => d * (pi / 180.0);