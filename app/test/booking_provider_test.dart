import 'package:flutter_test/flutter_test.dart';
import 'package:app/providers/booking_provider.dart';
import 'package:app/services/api_service.dart';
import 'package:app/models/booking.dart';
import 'package:app/models/slot.dart';

class MockApiService extends ApiService {
  bool shouldFail = false;
  
  @override
  void connectWebSocket() {}

  @override
  void disconnectWebSocket() {}

  @override
  Future<List<Slot>> getSlots(int venueId, String date, [String? timeOfDay]) async {
    return [
      Slot(startTime: "09:00", endTime: "10:00", status: "available"),
    ];
  }

  @override
  Future<Booking> bookSlot(String userId, int venueId, String date, String startTime) async {
    if (shouldFail) {
      throw ApiException("Slot already taken");
    }
    return Booking(
      id: "booking_123",
      venueId: venueId,
      date: date,
      startTime: startTime,
      userId: userId,
    );
  }
}

void main() {
  group('BookingProvider Tests', () {
    late MockApiService mockApiService;
    late BookingProvider provider;

    setUp(() {
      mockApiService = MockApiService();
      provider = BookingProvider(mockApiService);
    });

    test('bookSlot successful updates state without error', () async {
      await provider.bookSlot('user_1', 1, DateTime(2026, 6, 12), '09:00');
      
      expect(provider.error, isNull);
    });

    test('bookSlot throws ApiException and sets error on concurrency conflict', () async {
      mockApiService.shouldFail = true;
      
      try {
        await provider.bookSlot('user_1', 1, DateTime(2026, 6, 12), '09:00');
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<ApiException>());
        expect((e as ApiException).message, 'Slot already taken');
      }
      
      expect(provider.error, 'Slot already taken');
    });
  });
}
