import 'package:travel_app/models/poi.dart';

class SavedItinerary {
  final String id;
  final String title; // e.g. "State Library Victoria - Food"
  final String category; // "Food" or "Shopping"
  final String placeName;
  final double placeLat;
  final double placeLng;
  final int stops;
  final DateTime createdAt;
  final List<Poi> items;

  SavedItinerary({
    required this.id,
    required this.title,
    required this.category,
    required this.placeName,
    required this.placeLat,
    required this.placeLng,
    required this.stops,
    required this.createdAt,
    required this.items,
  });
}
