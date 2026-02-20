import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:travel_app/models/place.dart';
import 'package:travel_app/services/location_service.dart';
import 'package:travel_app/pages/search_page.dart';
import 'package:travel_app/pages/view_all_places_page.dart';

import 'package:travel_app/widgets/custom_icon_button.dart';
import 'package:travel_app/widgets/location_card.dart';
import 'package:travel_app/widgets/recommended_places.dart';
import 'package:travel_app/widgets/nearby_places.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.allPlaces});
  final List<Place> allPlaces;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _loc = LocationService();
  late Future<LocationResult> _locFuture;

  String _selectedCategory = "all";

  @override
  void initState() {
    super.initState();
    _locFuture = _loc.getLocationWithLabel();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

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

  Widget _categoryChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedCategory = value),
    );
  }

  List<Place> _filterPlaces(List<Place> places) {
    if (_selectedCategory == "all") return places;
    return places.where((p) => p.category.toLowerCase() == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationResult>(
      future: _locFuture,
      builder: (context, snap) {
        final loc = snap.data ??
            const LocationResult(
              lat: LocationService.fallbackLat,
              lng: LocationService.fallbackLng,
              label: LocationService.fallbackLabel,
              isFallback: true,
            );

        final sorted = [...widget.allPlaces]
          ..sort((a, b) {
            final da = _distanceMeters(loc.lat, loc.lng, a.lat, a.lng);
            final db = _distanceMeters(loc.lat, loc.lng, b.lat, b.lng);
            return da.compareTo(db);
          });

        final filtered = _filterPlaces(sorted);
        final recommended = filtered.take(5).toList();
        final nearby = filtered.take(10).toList();

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting()),
                Text("Melbourne Explorer", style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            actions: [
              CustomIconButton(
                icon: const Icon(Ionicons.search_outline),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SearchPage(allPlaces: widget.allPlaces)),
                  );
                },
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CustomIconButton(
                  icon: const Icon(Ionicons.notifications_outline),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No notifications yet ✅")),
                    );
                  },
                ),
              ),
            ],
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(14),
            children: [
              LocationCard(
                label: loc.label,
                subtitle: "Near you",
                isFallback: loc.isFallback,
                onRefresh: () {
                  setState(() {
                    _locFuture = _loc.getLocationWithLabel();
                  });
                },
              ),
              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _categoryChip("All", "all"),
                    const SizedBox(width: 10),
                    _categoryChip("Attractions", "attraction"),
                    const SizedBox(width: 10),
                    _categoryChip("Cafes", "cafe"),
                    const SizedBox(width: 10),
                    _categoryChip("Restaurants", "restaurant"),
                    const SizedBox(width: 10),
                    _categoryChip("Shopping", "shopping"),
                    const SizedBox(width: 10),
                    _categoryChip("Parks", "park"),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _SectionHeader(
                title: "Recommendation",
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewAllPlacesPage(title: "Recommendation", places: filtered),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              RecommendedPlaces(places: recommended),

              const SizedBox(height: 18),

              _SectionHeader(
                title: "Nearby From You",
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewAllPlacesPage(title: "Nearby From You", places: filtered),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              NearbyPlaces(places: nearby, userLat: loc.lat, userLng: loc.lng),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        TextButton(onPressed: onViewAll, child: const Text("View All")),
      ],
    );
  }
}
