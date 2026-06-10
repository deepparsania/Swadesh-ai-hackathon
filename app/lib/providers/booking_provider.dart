import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> fetchSlots(int venueId, DateTime date, [String? timeOfDay]) async {
    _isLoadingSlots = true;
    _error = null;
    _currentVenueId = venueId;
    _currentDateStr = DateFormat('yyyy-MM-dd').format(date);
    notifyListeners();
    try {
      _slots = await _apiService.getSlots(venueId, _currentDateStr!, timeOfDay);
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
      await fetchSlots(venueId, date);
      _error = e.message;
      rethrow;
    } catch (e) {
      await fetchSlots(venueId, date);
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> fetchMyBookings(String userId) async {
    _isLoadingBookings = true;
    notifyListeners();

    // Try cache first
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('my_bookings_$userId');
    if (cachedData != null) {
      try {
        final List data = jsonDecode(cachedData);
        _myBookings = data.map((b) => Booking.fromJson(b)).toList();
        _isLoadingBookings = false;
        notifyListeners();
      } catch (e) {}
    }

    try {
      final freshBookings = await _apiService.getUserBookings(userId);
      _myBookings = freshBookings;
      
      final jsonList = freshBookings.map((b) => b.toJson()).toList();
      await prefs.setString('my_bookings_$userId', jsonEncode(jsonList));
    } catch (e) {
      if (cachedData == null) {
        _error = e.toString();
      }
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
