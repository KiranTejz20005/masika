class Recommendation {
  final String id;
  final String title;
  final String type; // 'shop', 'insights', 'wellness'
  final String? price;
  final String? imageUrl;
  final String? description;
  final String? actionText;

  Recommendation({
    required this.id,
    required this.title,
    required this.type,
    this.price,
    this.imageUrl,
    this.description,
    this.actionText,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'price': price,
        'imageUrl': imageUrl,
        'description': description,
        'actionText': actionText,
      };

  factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        type: json['type'] ?? '',
        price: json['price'],
        imageUrl: json['imageUrl'],
        description: json['description'],
        actionText: json['actionText'],
      );
}
