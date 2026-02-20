import 'package:flutter/material.dart';
import 'package:travel_app/models/place.dart';
import 'package:travel_app/pages/tourist_details_page.dart';

class ViewAllPlacesPage extends StatelessWidget {
  const ViewAllPlacesPage({
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
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = places[index];

          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(p.image, width: 56, height: 56, fit: BoxFit.cover),
            ),
            title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(p.address, maxLines: 1, overflow: TextOverflow.ellipsis),
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
