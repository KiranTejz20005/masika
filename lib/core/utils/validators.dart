/// Centralized input validation. Use for all forms to ensure consistent rules.
class Validators {
  Validators._();

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final trimmed = value.trim();
    final pattern = RegExp(r'^[\w.-]+@[\w-]+\.\w{2,}$');
    if (!pattern.hasMatch(trimmed)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < minLength) return 'At least $minLength characters';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) return 'Enter a valid phone number';
    return null;
  }
}
