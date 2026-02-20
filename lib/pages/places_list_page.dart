import 'package:flutter/material.dart';
import 'package:travel_app/models/place.dart';
import 'package:travel_app/pages/tourist_details_page.dart';

class PlacesListPage extends StatelessWidget {
  const PlacesListPage({
    super.key,
    required this.title,
    required this.places,
  });

  final String title;
  final List<Place> places;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: places.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final p = places[i];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(p.image, width: 52, height: 52, fit: BoxFit.cover),
            ),
            title: Text(p.name),
            subtitle: Text(p.address),
            trailing: Text(p.rating.toStringAsFixed(1)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TouristDetailsPage(place: p)),
              );
            },
          );
        },
      ),
    );
  }
}
