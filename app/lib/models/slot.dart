class Slot {
  final String id;
  final String venueId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isBooked;

  Slot({
    required this.id,
    required this.venueId,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
  });

  Slot copyWith({bool? isBooked}) {
    return Slot(
      id: id,
      venueId: venueId,
      startTime: startTime,
      endTime: endTime,
      isBooked: isBooked ?? this.isBooked,
    );
  }
}
