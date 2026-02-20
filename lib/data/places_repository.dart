import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/place.dart';

class PlacesRepository {
  Future<List<Place>> loadMelbournePlaces() async {
    final raw = await rootBundle.loadString('assets/data/melbourne_places.json');
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Place.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
