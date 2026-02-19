class CycleLog {
  CycleLog({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.cycleLengthDays,
    required this.symptoms,
    required this.mood,
    required this.flow,
  });

  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final int cycleLengthDays;
  final List<String> symptoms;
  final String mood;
  final String flow;

  Map<String, dynamic> toJson() => {
        'id': id,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'cycleLengthDays': cycleLengthDays,
        'symptoms': symptoms,
        'mood': mood,
        'flow': flow,
      };

  factory CycleLog.fromJson(Map<String, dynamic> json) => CycleLog(
        id: json['id'] as String? ?? '',
        startDate: DateTime.parse(
          json['startDate'] as String? ?? DateTime.now().toIso8601String(),
        ),
        endDate: DateTime.parse(
          json['endDate'] as String? ?? DateTime.now().toIso8601String(),
        ),
        cycleLengthDays: json['cycleLengthDays'] as int? ?? 28,
        symptoms: List<String>.from(json['symptoms'] as List? ?? []),
        mood: json['mood'] as String? ?? 'calm',
        flow: json['flow'] as String? ?? 'medium',
      );
}
