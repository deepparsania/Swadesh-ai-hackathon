import 'slot.dart';
import 'venue.dart';

class Booking {
  final String id;
  final String userId;
  final Slot slot;
  final Venue venue;

  Booking({
    required this.id,
    required this.userId,
    required this.slot,
    required this.venue,
  });
}
