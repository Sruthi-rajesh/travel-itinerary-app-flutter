import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final double lat;
  final double lng;
  final String label;
  final bool isFallback;

  const LocationResult({
    required this.lat,
    required this.lng,
    required this.label,
    required this.isFallback,
  });
}

class LocationService {
  static const double fallbackLat = -37.8136;
  static const double fallbackLng = 144.9631;
  static const String fallbackLabel = "Melbourne, VIC";

  Future<LocationResult> getLocationWithLabel() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return const LocationResult(
          lat: fallbackLat,
          lng: fallbackLng,
          label: fallbackLabel,
          isFallback: true,
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const LocationResult(
          lat: fallbackLat,
          lng: fallbackLng,
          label: fallbackLabel,
          isFallback: true,
        );
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode (optional)
      String label = fallbackLabel;
      try {
        final placemarks =
            await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final city = (p.locality ?? "").trim();
          final admin = (p.administrativeArea ?? "").trim();

          if (city.isNotEmpty && admin.isNotEmpty) {
            label = "$city, $admin";
          } else if (city.isNotEmpty) {
            label = city;
          }
        }
      } catch (_) {
        // ignore
      }

      return LocationResult(
        lat: pos.latitude,
        lng: pos.longitude,
        label: label,
        isFallback: false,
      );
    } catch (_) {
      return const LocationResult(
        lat: fallbackLat,
        lng: fallbackLng,
        label: fallbackLabel,
        isFallback: true,
      );
    }
  }
}
