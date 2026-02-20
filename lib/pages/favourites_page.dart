import 'package:flutter/material.dart';
import 'package:travel_app/models/place.dart';
import 'package:travel_app/pages/tourist_details_page.dart';
import 'package:travel_app/services/favourites_store.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key, required this.allPlaces});
  final List<Place> allPlaces;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved")),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: FavouritesStore.favIds, // ✅ correct
        builder: (context, favIds, _) {
          final favPlaces = allPlaces.where((p) => favIds.contains(p.id)).toList();

          if (favPlaces.isEmpty) {
            return const Center(child: Text("No favourites yet ❤️"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favPlaces.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final p = favPlaces[i];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    p.image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
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
          );
        },
      ),
    );
  }
}
