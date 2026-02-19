/// Structured health profile for insights, schedule, reports, and consultation.
/// Stored in Hive (offline) and Supabase when configured.
class UserHealthProfile {
  UserHealthProfile({
    required this.userId,
    this.cycleLength = 28,
    this.periodDuration = 5,
    this.flowRate = 'medium',
    this.painDuringPeriod = false,
    this.padsPerDay = 3,
    this.clotting = false,
    this.weaknessLevel = 'medium',
    this.dietDescription = '',
    this.healthConcernDescription = '',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  final String userId;
  final int cycleLength;
  final int periodDuration;
  final String flowRate; // low, medium, high
  final bool painDuringPeriod;
  final int padsPerDay;
  final bool clotting;
  final String weaknessLevel; // low, medium, high
  final String dietDescription;
  final String healthConcernDescription;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'cycleLength': cycleLength,
        'periodDuration': periodDuration,
        'flowRate': flowRate,
        'painDuringPeriod': painDuringPeriod,
        'padsPerDay': padsPerDay,
        'clotting': clotting,
        'weaknessLevel': weaknessLevel,
        'dietDescription': dietDescription,
        'healthConcernDescription': healthConcernDescription,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory UserHealthProfile.fromJson(Map<String, dynamic> json) {
    return UserHealthProfile(
      userId: json['userId'] as String? ?? '',
      cycleLength: json['cycleLength'] as int? ?? 28,
      periodDuration: json['periodDuration'] as int? ?? 5,
      flowRate: json['flowRate'] as String? ?? 'medium',
      painDuringPeriod: json['painDuringPeriod'] as bool? ?? false,
      padsPerDay: json['padsPerDay'] as int? ?? 3,
      clotting: json['clotting'] as bool? ?? false,
      weaknessLevel: json['weaknessLevel'] as String? ?? 'medium',
      dietDescription: json['dietDescription'] as String? ?? '',
      healthConcernDescription: json['healthConcernDescription'] as String? ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  UserHealthProfile copyWith({
    String? userId,
    int? cycleLength,
    int? periodDuration,
    String? flowRate,
    bool? painDuringPeriod,
    int? padsPerDay,
    bool? clotting,
    String? weaknessLevel,
    String? dietDescription,
    String? healthConcernDescription,
    DateTime? updatedAt,
  }) {
    return UserHealthProfile(
      userId: userId ?? this.userId,
      cycleLength: cycleLength ?? this.cycleLength,
      periodDuration: periodDuration ?? this.periodDuration,
      flowRate: flowRate ?? this.flowRate,
      painDuringPeriod: painDuringPeriod ?? this.painDuringPeriod,
      padsPerDay: padsPerDay ?? this.padsPerDay,
      clotting: clotting ?? this.clotting,
      weaknessLevel: weaknessLevel ?? this.weaknessLevel,
      dietDescription: dietDescription ?? this.dietDescription,
      healthConcernDescription:
          healthConcernDescription ?? this.healthConcernDescription,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
