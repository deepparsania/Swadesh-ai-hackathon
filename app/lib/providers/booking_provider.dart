import 'package:flutter/material.dart';
import '../models/slot.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  final MockApiService _apiService;
  List<Slot> _slots = [];
  List<Booking> _myBookings = [];
  bool _isLoadingSlots = false;
  bool _isLoadingBookings = false;
  String? _error;

  BookingProvider(this._apiService);

  List<Slot> get slots => _slots;
  List<Booking> get myBookings => _myBookings;
  bool get isLoadingSlots => _isLoadingSlots;
  bool get isLoadingBookings => _isLoadingBookings;
  String? get error => _error;

  Future<void> fetchSlots(String venueId, DateTime date) async {
    _isLoadingSlots = true;
    _error = null;
    notifyListeners();
    try {
      _slots = await _apiService.getSlots(venueId, date);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingSlots = false;
      notifyListeners();
    }
  }

  Future<void> bookSlot(String userId, String slotId, String venueId, DateTime date) async {
    _error = null;
    try {
      await _apiService.bookSlot(userId, slotId);
      await fetchSlots(venueId, date);
    } on ApiException catch (e) {
      _error = e.message;
      await fetchSlots(venueId, date);
      rethrow;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> fetchMyBookings(String userId) async {
    _isLoadingBookings = true;
    notifyListeners();
    try {
      _myBookings = await _apiService.getUserBookings(userId);
    } finally {
      _isLoadingBookings = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String userId, String bookingId) async {
    try {
      await _apiService.cancelBooking(bookingId);
      await fetchMyBookings(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
