import 'package:flutter/material.dart';
import 'package:travel_app/models/place.dart';
import 'package:travel_app/pages/tourist_details_page.dart';

class RecommendedPlaces extends StatelessWidget {
  const RecommendedPlaces({super.key, required this.places});
  final List<Place> places;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: places.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final place = places[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TouristDetailsPage(place: place)),
              );
            },
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      place.image,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    place.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(place.address, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16),
                      const SizedBox(width: 4),
                      Text(place.rating.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
