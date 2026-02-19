class RewardPoint {
  RewardPoint({
    required this.id,
    required this.points,
    required this.reason,
    required this.createdAt,
  });

  final String id;
  final int points;
  final String reason;
  final DateTime createdAt;
}
