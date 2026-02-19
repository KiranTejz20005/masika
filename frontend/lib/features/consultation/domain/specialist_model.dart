/// Specialist model for Masika Specialists — used by specialists list, booking, and chat.
class Specialist {
  const Specialist({
    required this.id,
    required this.name,
    required this.specialty,
    required this.availabilityLabel,
    required this.rating,
    required this.imageUrl,
    this.isPremium = false,
    this.durationMinutes,
    this.isOnline = true,
  });

  final String id;
  final String name;
  final String specialty;
  final String availabilityLabel;
  final double rating;
  final String imageUrl;
  final bool isPremium;
  final int? durationMinutes;
  final bool isOnline;
}
