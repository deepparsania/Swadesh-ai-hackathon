import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
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

class ApiService {
  static const String baseUrl = 'https://swadesh-ai-hackathon.onrender.com';
  static const String wsUrl = 'wss://swadesh-ai-hackathon.onrender.com';

  final List<User> _users = [
    User(id: 'user_1', name: 'User 1'),
    User(id: 'user_2', name: 'User 2'),
    User(id: 'user_3', name: 'User 3'),
  ];

  WebSocketChannel? _channel;
  Function(Map<String, dynamic>)? onSlotStatusChanged;

  void connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          if (data['event'] == 'slot_status_changed' && onSlotStatusChanged != null) {
            onSlotStatusChanged!(data['data']);
          }
        },
        onError: (error) => print('WebSocket Error: $error'),
        onDone: () => print('WebSocket Closed'),
      );
    } catch (e) {
      print('WebSocket connection failed: $e');
    }
  }

  void disconnectWebSocket() {
    _channel?.sink.close();
  }

  Future<List<User>> getUsers() async {
    return _users;
  }

  Future<List<Venue>> getVenues() async {

    try {
      final response = await http.get(Uri.parse('$baseUrl/venues'));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print(data);
        return data.map((v) => Venue.fromJson(v)).toList();
      } else {
        throw ApiException('Failed to load venues');
      }
    } catch (e) {
      debugPrint(e.toString());

      // Return empty list if backend is not running yet
      return [];
    }
  }

  Future<List<Slot>> getSlots(int venueId, String date, [String? timeOfDay]) async {
    try {
      String url = '$baseUrl/venues/$venueId/slots?date=$date';
      if (timeOfDay != null) {
        url += '&timeOfDay=$timeOfDay';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List slots = data['slots'];
        return slots.map((s) => Slot.fromJson(s)).toList();
      } else {
        throw ApiException('Failed to load slots');
      }
    } catch (e) {
      return [];
    }
  }

  Future<Booking> bookSlot(String userId, int venueId, String date, String startTime) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': userId,
      },
      body: jsonEncode({
        'venue_id': venueId,
        'date': date,
        'start_time': startTime,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Booking.fromJson(data['booking']);
    } else if (response.statusCode == 409) {
      final data = jsonDecode(response.body);
      throw ApiException(data['message'] ?? 'Slot already taken');
    } else {
      throw ApiException('Failed to book slot');
    }
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/bookings'),
        headers: {'X-User-Id': userId},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print(data);
        return data.map((b) => Booking.fromJson(b)).toList();
      } else {
        throw ApiException('Failed to load bookings');
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<void> cancelBooking(String userId, String bookingId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/bookings/$bookingId'),
      headers: {'X-User-Id': userId},
    );
    if (response.statusCode != 200) {
      throw ApiException('Failed to cancel booking');
    }
  }
}
