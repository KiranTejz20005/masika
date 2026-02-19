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
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String specialty;
  final String registrationNumber;
  final String clinic;
  final String experience;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'specialty': specialty,
        'registrationNumber': registrationNumber,
        'clinic': clinic,
        'experience': experience,
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
    );
  }
}
