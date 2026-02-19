class Appointment {
  Appointment({
    required this.id,
    required this.doctor,
    required this.timeSlot,
    required this.notes,
  });

  final String id;
  final String doctor;
  final String timeSlot;
  final String notes;
}
