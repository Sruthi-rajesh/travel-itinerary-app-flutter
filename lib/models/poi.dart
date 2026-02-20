class Poi {
  final String id;
  final String name;
  final String type;
  final double lat;
  final double lng;
  final String? address;

  Poi({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
    this.address,
  });
}
