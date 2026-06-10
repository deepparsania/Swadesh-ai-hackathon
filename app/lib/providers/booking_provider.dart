import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/slot.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Slot> _slots = [];
  List<Booking> _myBookings = [];
  bool _isLoadingSlots = false;
  bool _isLoadingBookings = false;
  String? _error;
  
  int? _currentVenueId;
  String? _currentDateStr;

  BookingProvider(this._apiService) {
    _apiService.onSlotStatusChanged = _handleSlotStatusChange;
    _apiService.connectWebSocket();
  }

  @override
  void dispose() {
    _apiService.disconnectWebSocket();
    super.dispose();
  }

  List<Slot> get slots => _slots;
  List<Booking> get myBookings => _myBookings;
  bool get isLoadingSlots => _isLoadingSlots;
  bool get isLoadingBookings => _isLoadingBookings;
  String? get error => _error;

  void _handleSlotStatusChange(Map<String, dynamic> data) {
    if (_currentVenueId != null && data['venue_id'] == _currentVenueId) {
      if (_currentDateStr != null && data['date'] == _currentDateStr) {
        final startTime = data['start_time'];
        final index = _slots.indexWhere((s) => s.startTime == startTime);
        if (index != -1) {
          _slots[index] = _slots[index].copyWith(
            status: data['status'],
            bookingId: data['booking_id'],
            userId: data['user_id'],
          );
          notifyListeners();
        }
      }
    }
  }

  Future<void> fetchSlots(int venueId, DateTime date) async {
    _isLoadingSlots = true;
    _error = null;
    _currentVenueId = venueId;
    _currentDateStr = DateFormat('yyyy-MM-dd').format(date);
    notifyListeners();
    try {
      _slots = await _apiService.getSlots(venueId, _currentDateStr!);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingSlots = false;
      notifyListeners();
    }
  }

  Future<void> bookSlot(String userId, int venueId, DateTime date, String startTime) async {
    _error = null;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    try {
      await _apiService.bookSlot(userId, venueId, dateStr, startTime);
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
      await _apiService.cancelBooking(userId, bookingId);
      await fetchMyBookings(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
