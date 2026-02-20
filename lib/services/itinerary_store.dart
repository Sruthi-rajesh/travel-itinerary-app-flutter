import 'package:flutter/foundation.dart';
import 'package:travel_app/models/place.dart';
import 'package:travel_app/models/poi.dart';
import 'package:travel_app/models/saved_itinerary.dart';

class ItineraryStore {
  static final ValueNotifier<List<SavedItinerary>> notifier =
      ValueNotifier<List<SavedItinerary>>([]);

  static List<SavedItinerary> get items => notifier.value;

  static void save({
    required Place place,
    required String category, // "Food" or "Shopping"
    required List<Poi> pois,
    int maxStops = 12,
  }) {
    final trimmed = pois.take(maxStops).toList();

    final it = SavedItinerary(
      id: "${DateTime.now().millisecondsSinceEpoch}",
      title: "${place.name} • $category",
      category: category,
      placeName: place.name,
      placeLat: place.lat,
      placeLng: place.lng,
      stops: trimmed.length,
      createdAt: DateTime.now(),
      items: trimmed,
    );

    notifier.value = [it, ...notifier.value];

    // triggers listeners
    notifier.notifyListeners();
  }

  static void remove(String id) {
    notifier.value = notifier.value.where((x) => x.id != id).toList();
    notifier.notifyListeners();
  }

  static void clearAll() {
    notifier.value = [];
    notifier.notifyListeners();
  }
}
