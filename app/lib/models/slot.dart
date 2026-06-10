class Slot {
  final String startTime;
  final String endTime;
  final String status;
  final String? bookingId;
  final String? userId;

  Slot({
    required this.startTime,
    required this.endTime,
    required this.status,
    this.bookingId,
    this.userId,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'],
      bookingId: json['booking_id'],
      userId: json['user_id'],
    );
  }

  Slot copyWith({String? status, String? bookingId, String? userId}) {
    return Slot(
      startTime: this.startTime,
      endTime: this.endTime,
      status: status ?? this.status,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
    );
  }
}
