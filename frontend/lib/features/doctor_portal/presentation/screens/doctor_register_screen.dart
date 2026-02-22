import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_providers.dart';
import 'doctor_shell.dart';
import 'doctor_login_screen.dart';

/// Pixel-perfect Doctor Registration Screen
/// Clean design with sections for Personal Details and Professional Credentials.
/// When [embedded] is true, renders only the form (no full Scaffold) for same-page use.
class DoctorRegisterScreen extends ConsumerStatefulWidget {
  const DoctorRegisterScreen({
    super.key,
    this.embedded = false,
    this.onBack,
  });

  final bool embedded;
  final VoidCallback? onBack;

  @override
  ConsumerState<DoctorRegisterScreen> createState() =>
      _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends ConsumerState<DoctorRegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _expController = TextEditingController();
  final _feeController = TextEditingController();
  final _clinicController = TextEditingController();
  final _timeController = TextEditingController();

  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  // Design colors matching reference
  static const _maroon = Color(0xFF8C1D3F);
  static const _white = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F8F8);
  static const _labelGray = Color(0xFF9E9E9E);
  static const _textGray = Color(0xFF6B6B6B);
  static const _inputBg = Color(0xFFF5F5F5);
  static const _iconGray = Color(0xFF9E9E9E);
  static const _cardRadius = 24.0;
  static const _inputRadius = 12.0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _expController.dispose();
    _feeController.dispose();
    _clinicController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter full name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter email address'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter password (min 6 characters)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter phone number'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agree to Terms and Privacy Policy'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final doctorRepo = ref.read(doctorRepositoryProvider);
      await doctorRepo.registerDoctor(
        email: email,
        password: password,
        name: name,
        phone: phone,
        specialty: _specializationController.text.trim(),
        clinic: _clinicController.text.trim(),
        experience: _expController.text.trim(),
      );

      final profile = await doctorRepo.getCurrentDoctorProfile();
      if (profile != null) {
        ref.read(doctorProfileProvider.notifier).setProfile(profile);
        ref.read(isDoctorLoggedInProvider.notifier).state = true;
      }

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DoctorShell()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEmbeddedContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onBack,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _maroon),
                    const SizedBox(width: 6),
                    const Text(
                      'Back to Login',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _maroon,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildFormCard(),
        const SizedBox(height: 24),
        _buildFooter(),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: _buildEmbeddedContent(),
      );
    }
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildScrollableHeader(),
              const SizedBox(height: 20),
              _buildFormCard(),
              const SizedBox(height: 24),
              _buildFooter(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Red header (gradient, back button, logo, title) — scrolls with the page.
  Widget _buildScrollableHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF9C2848),
            Color(0xFF8C1D3F),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildBackButton(),
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _white.withValues(alpha: 0.35),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.medical_services_outlined,
                  size: 36,
                  color: _white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTitleSubtitle(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                if (widget.embedded) {
                  widget.onBack?.call();
                } else {
                  Navigator.of(context).pop();
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _maroon,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Join Masika AI',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create your professional doctor profile',
            style: TextStyle(
              fontSize: 15,
              color: _white.withValues(alpha: 0.92),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Details Section
          _buildSectionLabel('PERSONAL DETAILS'),
          const SizedBox(height: 16),
          _buildInput(
            controller: _nameController,
            hint: 'Full Name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _buildInput(
            controller: _emailController,
            hint: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _buildInput(
            controller: _passwordController,
            hint: 'Password (min 6 characters)',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          _buildInput(
            controller: _phoneController,
            hint: 'Phone Number',
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          
          // Professional Credentials Section
          _buildSectionLabel('PROFESSIONAL CREDENTIALS'),
          const SizedBox(height: 16),
          _buildSpecializationDropdown(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  controller: _expController,
                  hint: 'Exp (Years)',
                  icon: Icons.trending_up,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInput(
                  controller: _feeController,
                  hint: 'Fee (\$)',
                  icon: Icons.account_balance_wallet_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInput(
            controller: _clinicController,
            hint: 'Clinic Location',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          _buildInput(
            controller: _timeController,
            hint: 'Available Time (e.g. 09:00 - 17:00)',
            icon: Icons.access_time,
          ),
          const SizedBox(height: 24),
          
          // Upload License (optional)
          _buildUploadLicense(),
          const SizedBox(height: 20),
          
          // Terms Checkbox
          _buildTermsCheckbox(),
          const SizedBox(height: 24),
          
          // Register Button
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _labelGray,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSpecializationDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(_inputRadius),
      ),
      child: TextField(
        controller: _specializationController,
        readOnly: true,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: _textGray,
        ),
        decoration: InputDecoration(
          hintText: 'Specialization',
          hintStyle: TextStyle(
            fontSize: 15,
            color: _labelGray.withValues(alpha: 0.8),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(Icons.medical_services_outlined, color: _iconGray, size: 22),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(Icons.keyboard_arrow_down, color: _iconGray, size: 24),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onTap: () {
          // Show specialization dropdown
          showModalBottomSheet(
            context: context,
            builder: (context) => _buildSpecializationBottomSheet(),
          );
        },
      ),
    );
  }

  Widget _buildSpecializationBottomSheet() {
    final specializations = [
      'General Practitioner',
      'Gynecologist',
      'Obstetrician',
      'Endocrinologist',
      'Dermatologist',
      'Psychiatrist',
      'Nutritionist',
      'Other'
    ];

    final maxHeight = MediaQuery.of(context).size.height * 0.6;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.paddingOf(context).bottom + 8),
      decoration: const BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Specialization',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _maroon,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: (maxHeight - 80).clamp(120.0, double.infinity),
            child: ListView.builder(
              itemCount: specializations.length,
              itemBuilder: (context, index) {
                final spec = specializations[index];
                return ListTile(
                  title: Text(spec),
                  onTap: () {
                    setState(() => _specializationController.text = spec);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadLicense() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload Medical License (PDF, JPG up to 5MB) – optional'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: _inputBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _labelGray.withValues(alpha: 0.25),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 28,
              color: _maroon,
            ),
            const SizedBox(height: 12),
            const Text(
              'Upload Medical License (optional)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _textGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PDF, JPG up to 5MB',
              style: TextStyle(
                fontSize: 12,
                color: _labelGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
            activeColor: _maroon,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return _maroon;
              return _white;
            }),
            side: BorderSide(
              color: _labelGray.withValues(alpha: 0.5),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: _textGray,
                height: 1.4,
              ),
              children: [
                const TextSpan(
                  text: 'By registering, I agree to Masika AI\'s ',
                ),
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _maroon,
                  ),
                ),
                const TextSpan(
                  text: ' and ',
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _maroon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: _isSubmitting ? null : _register,
        style: FilledButton.styleFrom(
          backgroundColor: _maroon,
          foregroundColor: _white,
          disabledBackgroundColor: _maroon.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: _white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Register as Doctor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have a professional account? ',
          style: TextStyle(
            fontSize: 14,
            color: _textGray,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const DoctorLoginScreen(),
              ),
            );
          },
          child: const Text(
            'Sign In',
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

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(_inputRadius),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: _textGray,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 15,
            color: _labelGray.withValues(alpha: 0.8),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(icon, color: _iconGray, size: 22),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
