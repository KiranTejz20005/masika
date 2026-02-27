/// Doctor profile for Doctor Portal session (full details for process section).
class DoctorProfile {
  const DoctorProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.specialty = '',
    this.registrationNumber = '',
    this.clinic = '',
    this.experience = '',
    this.profileImageUrl = '',
    this.rating = 0.0,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String specialty;
  final String registrationNumber;
  final String clinic;
  final String experience;
  final String profileImageUrl;
  final double rating;

  /// Create a copy with updated fields.
  DoctorProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? specialty,
    String? registrationNumber,
    String? clinic,
    String? experience,
    String? profileImageUrl,
    double? rating,
  }) {
    return DoctorProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialty: specialty ?? this.specialty,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      clinic: clinic ?? this.clinic,
      experience: experience ?? this.experience,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'specialty': specialty,
        'registrationNumber': registrationNumber,
        'clinic': clinic,
        'experience': experience,
        'profileImageUrl': profileImageUrl,
        'rating': rating,
      };

  static DoctorProfile fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Doctor',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      registrationNumber: json['registrationNumber'] as String? ?? '',
      clinic: json['clinic'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
