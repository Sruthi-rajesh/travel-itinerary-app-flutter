import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travel_app/models/place.dart';
import 'package:travel_app/pages/tourist_details_page.dart';

class NearbyPlaces extends StatelessWidget {
  const NearbyPlaces({
    super.key,
    required this.places,
    required this.userLat,
    required this.userLng,
  });

  final List<Place> places;
  final double userLat;
  final double userLng;

  String _kmAway(Place p) {
    final meters = Geolocator.distanceBetween(userLat, userLng, p.lat, p.lng);
    final km = meters / 1000.0;
    return "${km.toStringAsFixed(1)} km away";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: places.map((place) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TouristDetailsPage(place: place)),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      place.image,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          place.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        Text(_kmAway(place), style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      Text(place.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall),
                      const Icon(Icons.star, size: 16),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
