class Order {
  Order({
    required this.id,
    required this.total,
    required this.items,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final double total;
  final List<String> items;
  final String status;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'total': total,
        'items': items,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };
}
