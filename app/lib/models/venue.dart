class Venue {
  final int? id;
  final String name;
  final String imageUrl;
  final String? sport;
  final String? location;

  Venue({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.sport,
    this.location,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['_id'],
      name: json['name'],
      imageUrl: json['image_url'],
      sport: json['sport'],
      location: json['location'],
    );
  }
}
