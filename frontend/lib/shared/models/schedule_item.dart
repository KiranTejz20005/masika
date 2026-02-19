class ScheduleItem {
  final String id;
  final String title;
  final String time;
  final String subtitle;
  final String phase;
  final String icon;
  final String color;

  ScheduleItem({
    required this.id,
    required this.title,
    required this.time,
    required this.subtitle,
    required this.phase,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'time': time,
        'subtitle': subtitle,
        'phase': phase,
        'icon': icon,
        'color': color,
      };

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => ScheduleItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        time: json['time'] ?? '',
        subtitle: json['subtitle'] ?? '',
        phase: json['phase'] ?? '',
        icon: json['icon'] ?? '',
        color: json['color'] ?? '',
      );
}
