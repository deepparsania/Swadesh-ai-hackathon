import 'venue.dart';

class Booking {
  final String id;
  final int? venueId;
  final String date;
  final String startTime;
  final String userId;
  final Venue? venue;

  Booking({
    required this.id,
    required this.venueId,
    required this.date,
    required this.startTime,
    required this.userId,
    this.venue,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      venueId: json['venue_id'],
      date: json['date'],
      startTime: json['start_time'],
      userId: json['user_id'] ?? '',
      venue: json['venue'] != null ? Venue.fromJson(json['venue']) : null,
    );
  }
}
