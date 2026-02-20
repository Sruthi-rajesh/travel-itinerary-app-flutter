class Place {
  final String id;
  final String name;
  final String category; // shopping, restaurant, attraction, park, cafe
  final String image;    // asset path for now
  final String address;
  final double lat;
  final double lng;
  final double rating;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.address,
    required this.lat,
    required this.lng,
    required this.rating,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
    );
  }
}
