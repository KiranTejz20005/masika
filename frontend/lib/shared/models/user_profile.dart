class UserProfile {
  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.languageCode,
    required this.cycleLength,
    required this.periodDuration,
    this.email,
    this.phone,
    this.dateOfBirth,
  });

  final String id;
  final String name;
  final int age;
  final String languageCode;
  final int cycleLength;
  final int periodDuration;
  /// Email from registration (optional).
  final String? email;
  /// Phone from registration (optional).
  final String? phone;
  /// Birth date from registration, e.g. yyyy-MM-dd (optional).
  final String? dateOfBirth;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'languageCode': languageCode,
        'cycleLength': cycleLength,
        'periodDuration': periodDuration,
        'email': email,
        'phone': phone,
        'dateOfBirth': dateOfBirth,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        age: json['age'] as int? ?? 0,
        languageCode: json['languageCode'] as String? ?? 'en',
        cycleLength: json['cycleLength'] as int? ?? 28,
        periodDuration: json['periodDuration'] as int? ?? 5,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        dateOfBirth: json['dateOfBirth'] as String?,
      );

  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    String? languageCode,
    int? cycleLength,
    int? periodDuration,
    String? email,
    String? phone,
    String? dateOfBirth,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      languageCode: languageCode ?? this.languageCode,
      cycleLength: cycleLength ?? this.cycleLength,
      periodDuration: periodDuration ?? this.periodDuration,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}
