/// A booked consultation with a specialist. Used for My Bookings and history.
class Appointment {
  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.timeSlot,
    required this.notes,
    required this.bookedAt,
    this.doctorImageUrl,
    this.doctorRating,
  });

  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String timeSlot;
  final String notes;
  final DateTime bookedAt;
  final String? doctorImageUrl;
  final double? doctorRating;

  /// Legacy: doctor name (for backward compatibility).
  String get doctor => doctorName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorSpecialty': doctorSpecialty,
        'timeSlot': timeSlot,
        'notes': notes,
        'bookedAt': bookedAt.toIso8601String(),
        'doctorImageUrl': doctorImageUrl,
        'doctorRating': doctorRating,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? json['doctor'] as String? ?? '',
      doctorSpecialty: json['doctorSpecialty'] as String? ?? '',
      timeSlot: json['timeSlot'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      bookedAt: json['bookedAt'] != null
          ? DateTime.tryParse(json['bookedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      doctorImageUrl: json['doctorImageUrl'] as String?,
      doctorRating: (json['doctorRating'] as num?)?.toDouble(),
    );
  }

  /// True if the booking date is today or in the future (upcoming or present).
  bool get isUpcoming {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookedDay = DateTime(bookedAt.year, bookedAt.month, bookedAt.day);
    return !bookedDay.isBefore(today);
  }

  bool get isPast => !isUpcoming;
}
