import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_providers.dart';
import '../../../dashboard/presentation/screens/dashboard_shell.dart';

/// Pixel-perfect registration screen: Create Your Account with full form,
/// date picker; saves data to user profile with smooth animations.
/// When [embedded] is true, renders only the form (no Scaffold) for same-page use.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({
    super.key,
    this.embedded = false,
    this.onBack,
  });

  final bool embedded;
  final VoidCallback? onBack;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _birthDateStr;
  DateTime? _birthDate;

  static const _maroon = Color(0xFF8C1D3F);
  static const _white = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F7F5);
  static const _labelGray = Color(0xFF4B4B4B);
  static const _inputBg = Color(0xFFF0EFEF);
  static const _iconGray = Color(0xFF9B9B9B);
  static const _hintGray = Color(0xFFAAAAAA);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: _maroon),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _birthDate = picked;
        _birthDateStr =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  int? _ageFromBirthDate() {
    if (_birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - _birthDate!.year;
    if (now.month < _birthDate!.month ||
        (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
      age--;
    }
    return age;
  }

  Future<void> _completeRegistration() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      _showSnackBar('Enter your full name');
      return;
    }
    if (email.isEmpty) {
      _showSnackBar('Enter your email');
      return;
    }
    if (phone.isEmpty) {
      _showSnackBar('Enter your phone number');
      return;
    }
    if (password.length < 6) {
      _showSnackBar('Password must be at least 6 characters');
      return;
    }
    if (_birthDate == null) {
      _showSnackBar('Select your birth date');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Register (Supabase when configured)
      final userRepo = ref.read(userRepositoryProvider);
      await userRepo.registerUser(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      // Get the created user profile
      final profile = await userRepo.getCurrentUserProfile();

      if (profile != null) {
        // Update with additional info
        final age = _ageFromBirthDate() ?? 0;
        await userRepo.updateUserProfile(profile.id, {
          'age': age,
          'cycleLength': 28,
          'periodDuration': 5,
          'languageCode': 'en',
          'dateOfBirth': _birthDateStr,
        });

        // Get updated profile
        final updatedProfile = await userRepo.getCurrentUserProfile();
        if (updatedProfile != null) {
          ref.read(userProfileProvider.notifier).setProfile(updatedProfile);
        }
        ref.read(isUserLoggedInProvider.notifier).state = true;
      }

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _navigateToDashboard();
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        final msg = e.toString().replaceAll('Exception: ', '');
        final lower = msg.toLowerCase();
        if (lower.contains('email') && (lower.contains('invalid') || lower.contains('email_address_invalid'))) {
          _showSnackBar('Please enter a valid email address.');
        } else {
          _showSnackBar(msg);
        }
      }
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DashboardShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  void _goToLogin() {
    if (widget.embedded) {
      widget.onBack?.call();
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _buildFormContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 8 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _buildCard(),
        ),
        const SizedBox(height: 20),
        _buildSecurityBar(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
        child: _buildFormContent(),
      );
    }
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
          child: _buildFormContent(),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildFullNameField(),
          const SizedBox(height: 18),
          _buildEmailField(),
          const SizedBox(height: 18),
          _buildPhoneField(),
          const SizedBox(height: 18),
          _buildPasswordField(),
          const SizedBox(height: 18),
          _buildBirthDateField(),
          const SizedBox(height: 24),
          _buildCompleteButton(),
          const SizedBox(height: 18),
          _buildLoginLink(),
          const SizedBox(height: 14),
          _buildTermsFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: _maroon,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.eco_rounded,
            color: _white,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Create Your Account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _labelGray,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Personalized wellness and diagnostic care for women, powered by AI.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _hintGray,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _labelGray,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFullNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('FULL NAME'),
        _buildInput(
          controller: _nameController,
          hint: 'Sarah Jenkins',
          icon: Icons.person_outline_rounded,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('EMAIL ADDRESS'),
        _buildInput(
          controller: _emailController,
          hint: 'sarah@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('PHONE NUMBER'),
        _buildInput(
          controller: _phoneController,
          hint: '+1 (555) 000-000',
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('PASSWORD'),
        Container(
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: _labelGray,
            ),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: _iconGray, fontSize: 15),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(Icons.lock_outline_rounded, color: _iconGray, size: 22),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _iconGray,
                  size: 22,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Min. 8 characters',
          style: TextStyle(
            fontSize: 12,
            color: _hintGray,
          ),
        ),
      ],
    );
  }

  Widget _buildBirthDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('BIRTH DATE'),
        InkWell(
          onTap: _pickBirthDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: _inputBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: _iconGray, size: 22),
                const SizedBox(width: 12),
                Text(
                  _birthDateStr ?? 'mm/dd/yyyy',
                  style: TextStyle(
                    fontSize: 15,
                    color: _birthDateStr != null ? _labelGray : _hintGray,
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_month_rounded, color: _iconGray, size: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: _labelGray,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _iconGray, fontSize: 15),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(icon, color: _iconGray, size: 22),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: _isSubmitting ? null : _completeRegistration,
        style: FilledButton.styleFrom(
          backgroundColor: _maroon,
          foregroundColor: _white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _white,
                ),
              )
            : const Text(
                'Complete Registration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(
            fontSize: 14,
            color: _labelGray,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: _goToLogin,
          child: const Text(
            'Log in',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _maroon,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsFooter() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'By registering, you agree to Masika AI\'s ',
          style: TextStyle(
            fontSize: 12,
            color: _hintGray,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Terms of Service',
            style: TextStyle(
              fontSize: 12,
              color: _maroon,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(
          ' and ',
          style: TextStyle(
            fontSize: 12,
            color: _hintGray,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 12,
              color: _maroon,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 20,
        runSpacing: 12,
        children: [
          _SecurityBadge(
            icon: Icons.shield_rounded,
            label: 'MEDICAL GRADE SECURITY',
          ),
          _SecurityBadge(
            icon: Icons.check_circle_outline_rounded,
            label: 'HIPAA COMPLIANT',
          ),
        ],
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  static const _iconGray = Color(0xFF9B9B9B);
  static const _labelGray = Color(0xFF4B4B4B);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: _iconGray),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _labelGray,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
