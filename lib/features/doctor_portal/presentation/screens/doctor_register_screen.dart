import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/doctor_profile.dart';
import '../../../../shared/providers/app_providers.dart';
import 'doctor_shell.dart';
import 'doctor_login_screen.dart';

/// Pixel-perfect Doctor Registration Screen
/// Clean design with sections for Personal Details and Professional Credentials
class DoctorRegisterScreen extends ConsumerStatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  ConsumerState<DoctorRegisterScreen> createState() =>
      _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends ConsumerState<DoctorRegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _specializationController = TextEditingController();
  final _expController = TextEditingController();
  final _feeController = TextEditingController();
  final _clinicController = TextEditingController();
  final _timeController = TextEditingController();

  bool _otpVerified = false;
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
    _phoneController.dispose();
    _otpController.dispose();
    _specializationController.dispose();
    _expController.dispose();
    _feeController.dispose();
    _clinicController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _getOtp() {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter phone number first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP sent (demo)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _verifyOtp() {
    if (_otpController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter 4-digit OTP'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _otpVerified = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP Verified'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter full name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!_otpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verify OTP first'),
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
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    ref.read(doctorProfileProvider.notifier).setProfile(
          DoctorProfile(
            id: 'doctor_${DateTime.now().millisecondsSinceEpoch}',
            name: name.isEmpty ? 'Doctor' : name,
            email: '${_phoneController.text.trim()}@masika.ai',
            phone: _phoneController.text.trim(),
            specialty: _specializationController.text.trim(),
            clinic: _clinicController.text.trim(),
            experience: _expController.text.trim(),
          ),
        );
    setState(() => _isSubmitting = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DoctorShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSubtitle(),
                    const SizedBox(height: 20),
                    _buildFormCard(),
                    const SizedBox(height: 24),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              onTap: () => Navigator.of(context).pop(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Join Masika AI',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _maroon,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Create your professional doctor profile',
          style: TextStyle(
            fontSize: 15,
            color: _textGray,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
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
          _buildPhoneWithOtp(),
          const SizedBox(height: 12),
          _buildOtpWithVerify(),
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
          
          // Upload License
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

  Widget _buildPhoneWithOtp() {
    return Row(
      children: [
        Expanded(
          child: _buildInput(
            controller: _phoneController,
            hint: 'Phone Number',
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _getOtp,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Get OTP',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _maroon,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpWithVerify() {
    return Row(
      children: [
        Expanded(
          child: _buildInput(
            controller: _otpController,
            hint: 'Enter 4-digit OTP',
            icon: Icons.lock_outline,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _verifyOtp,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'VERIFY',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _otpVerified ? Colors.green : _maroon,
              ),
            ),
          ),
        ),
      ],
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
    
    return Container(
      padding: const EdgeInsets.all(20),
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
          ...specializations.map((spec) => ListTile(
            title: Text(spec),
            onTap: () {
              setState(() => _specializationController.text = spec);
              Navigator.pop(context);
            },
          )),
        ],
      ),
    );
  }

  Widget _buildUploadLicense() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload Medical License (PDF, JPG up to 5MB)'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _labelGray.withValues(alpha: 0.2),
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
              'Upload Medical License',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _textGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PDF, JPG UP TO 5MB',
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
