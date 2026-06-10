import 'dart:math';

import '../models/user.dart';
import '../models/venue.dart';
import '../models/slot.dart';
import '../models/booking.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class MockApiService {
  // Hardcoded users
  final List<User> _users = [
    User(id: 'u1', name: 'Alice'),
    User(id: 'u2', name: 'Bob'),
  ];

  final List<Venue> _venues = [
    Venue(id: 'v1', name: 'Downtown Badminton', imageUrl: 'https://dummyimage.com/150/0000FF/808080?Text=Badminton'),
    Venue(id: 'v2', name: 'Green Park Turf', imageUrl: 'https://dummyimage.com/150/FF0000/FFFFFF?Text=Turf'),
    Venue(id: 'v3', name: 'City Sports Complex', imageUrl: 'https://dummyimage.com/150/00FF00/000000?Text=Complex'),
  ];

  // In-memory "database"
  final Map<String, Slot> _slotsDb = {};
  final Map<String, Booking> _bookingsDb = {};

  MockApiService() {
    _seedSlots();
  }

  void _seedSlots() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var venue in _venues) {
      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        final date = today.add(Duration(days: dayOffset));
        for (int hour = 6; hour < 22; hour++) {
          final start = DateTime(date.year, date.month, date.day, hour);
          final end = start.add(Duration(hours: 1));
          final slotId = '${venue.id}_${start.millisecondsSinceEpoch}';
          _slotsDb[slotId] = Slot(
            id: slotId,
            venueId: venue.id,
            startTime: start,
            endTime: end,
            isBooked: false,
          );
        }
      }
    }
  }

  Future<List<User>> getUsers() async {
    await Future.delayed(Duration(milliseconds: 500));
    return _users;
  }

  Future<List<Venue>> getVenues() async {
    await Future.delayed(Duration(milliseconds: 500));
    return _venues;
  }

  Future<List<Slot>> getSlots(String venueId, DateTime date) async {
    await Future.delayed(Duration(milliseconds: 500));
    final targetDate = DateTime(date.year, date.month, date.day);
    return _slotsDb.values.where((s) {
      final slotDate = DateTime(s.startTime.year, s.startTime.month, s.startTime.day);
      return s.venueId == venueId && slotDate == targetDate;
    }).toList();
  }

  Future<Booking> bookSlot(String userId, String slotId) async {
    await Future.delayed(Duration(milliseconds: 800));

    // Simulate concurrency issue randomly (20% chance)
    if (Random().nextDouble() < 0.2) {
      throw ApiException('Slot was just taken by someone else!');
    }

    final slot = _slotsDb[slotId];
    if (slot == null) {
      throw ApiException('Slot not found');
    }
    
    if (slot.isBooked) {
      throw ApiException('Slot is already booked');
    }

    _slotsDb[slotId] = slot.copyWith(isBooked: true);
    final venue = _venues.firstWhere((v) => v.id == slot.venueId);

    final bookingId = 'b_${DateTime.now().millisecondsSinceEpoch}';
    final booking = Booking(
      id: bookingId,
      userId: userId,
      slot: _slotsDb[slotId]!,
      venue: venue,
    );

    _bookingsDb[bookingId] = booking;
    return booking;
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _bookingsDb.values.where((b) => b.userId == userId).toList();
  }

  Future<void> cancelBooking(String bookingId) async {
    await Future.delayed(Duration(milliseconds: 500));
    final booking = _bookingsDb[bookingId];
    if (booking != null) {
      final slot = _slotsDb[booking.slot.id];
      if (slot != null) {
         _slotsDb[slot.id] = slot.copyWith(isBooked: false);
      }
      _bookingsDb.remove(bookingId);
    }
  }
}
