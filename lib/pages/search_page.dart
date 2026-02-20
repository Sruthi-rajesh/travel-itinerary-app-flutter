import 'package:flutter/material.dart';
import 'package:travel_app/models/place.dart';
import 'package:travel_app/pages/tourist_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.allPlaces});
  final List<Place> allPlaces;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String q = "";

  @override
  Widget build(BuildContext context) {
    final results = widget.allPlaces.where((p) {
      final s = (p.name + " " + p.address + " " + p.category).toLowerCase();
      return s.contains(q.toLowerCase().trim());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search places...",
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => q = v),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final p = results[i];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(p.image, width: 56, height: 56, fit: BoxFit.cover),
            ),
            title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(p.address, maxLines: 1, overflow: TextOverflow.ellipsis),
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
