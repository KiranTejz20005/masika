import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/doctor_profile.dart';
import '../../../../shared/providers/app_providers.dart';
import 'doctor_shell.dart';
import 'doctor_login_screen.dart';

// Reference: light off-white bg, white rounded card for form, dark red accent
const _maroon = Color(0xFF6C102C);
const _bg = Color(0xFFF5F5F5);
const _cardBg = Color(0xFFFFFFFF);
const _labelGray = Color(0xFF9E9E9E);
const _inputBg = Color(0xFFF0EFEF);
const _inputRadius = 14.0;
const _cardRadius = 24.0;

class DoctorRegisterScreen extends ConsumerStatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  ConsumerState<DoctorRegisterScreen> createState() =>
      _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends ConsumerState<DoctorRegisterScreen>
    with TickerProviderStateMixin {
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

  late AnimationController _staggerController;
  late Animation<double> _personalAnim;
  late Animation<double> _proAnim;
  late Animation<double> _uploadAnim;
  late Animation<double> _termsAnim;
  late Animation<double> _buttonAnim;
  late Animation<double> _footerAnim;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _personalAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.28, curve: Curves.easeOutCubic),
    );
    _proAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.18, 0.48, curve: Curves.easeOutCubic),
    );
    _uploadAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.38, 0.65, curve: Curves.easeOutCubic),
    );
    _termsAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.55, 0.78, curve: Curves.easeOutCubic),
    );
    _buttonAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.72, 0.92, curve: Curves.easeOutCubic),
    );
    _footerAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.85, 1.0, curve: Curves.easeOutCubic),
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
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
    setState(() {});
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
        content: Text('Verified'),
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
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Material(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(24),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _maroon,
                  size: 20,
                ),
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
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: _maroon,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Create your professional doctor profile',
          style: TextStyle(
            fontSize: 14,
            color: _labelGray,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StaggerSlide(
            animation: _personalAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('PERSONAL DETAILS'),
                const SizedBox(height: 12),
                _buildInput(
                  controller: _nameController,
                  hint: 'Full Name',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildInput(
                        controller: _phoneController,
                        hint: 'Phone Number',
                        icon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 90,
                      child: Material(
                        color: _maroon.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(_inputRadius),
                        child: InkWell(
                          onTap: _getOtp,
                          borderRadius: BorderRadius.circular(_inputRadius),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Get OTP',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _maroon,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        controller: _otpController,
                        hint: 'Enter 4-digit OTP',
                        icon: Icons.lock_outline_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _verifyOtp,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'VERIFY',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _maroon,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _StaggerSlide(
            animation: _proAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('PROFESSIONAL CREDENTIALS'),
                const SizedBox(height: 12),
                _buildInput(
                  controller: _specializationController,
                  hint: 'Specialization',
                  icon: Icons.medical_services_outlined,
                  suffix: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _labelGray,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        controller: _expController,
                        hint: 'Exp (Years)',
                        icon: Icons.show_chart_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInput(
                        controller: _feeController,
                        hint: 'Fee (\$)',
                        icon: Icons.attach_money_rounded,
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
                  icon: Icons.schedule_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _StaggerSlide(
            animation: _uploadAnim,
            child: _buildUploadLicense(),
          ),
          const SizedBox(height: 20),
          _StaggerSlide(
            animation: _termsAnim,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _agreedToTerms,
                    onChanged: (v) =>
                        setState(() => _agreedToTerms = v ?? false),
                    activeColor: _maroon,
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) return _maroon;
                      return _cardBg;
                    }),
                    side: BorderSide(
                      color: _labelGray.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    shape: const CircleBorder(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    children: [
                      Text(
                        'By registering, I agree to Masika AI\'s ',
                        style: TextStyle(fontSize: 13, color: _labelGray),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Terms of Service',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _maroon,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        ' and ',
                        style: TextStyle(fontSize: 13, color: _labelGray),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _maroon,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _StaggerSlide(
            animation: _buttonAnim,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _register,
                style: FilledButton.styleFrom(
                  backgroundColor: _maroon,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _maroon.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_inputRadius),
                  ),
                  elevation: 0,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isSubmitting
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          key: ValueKey('text'),
                          'Register as Doctor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return AnimatedBuilder(
      animation: _footerAnim,
      builder: (context, child) {
        return Opacity(
          opacity: _footerAnim.value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - _footerAnim.value)),
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have a professional account? ',
            style: TextStyle(fontSize: 13, color: _labelGray),
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
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _maroon,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _labelGray,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(_inputRadius),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: _labelGray),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(icon, color: _labelGray, size: 22),
          ),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffix,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(_inputRadius),
          border: Border.all(
            color: _labelGray.withValues(alpha: 0.4),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_upload_rounded, size: 40, color: _maroon),
            const SizedBox(height: 12),
            const Text(
              'Upload Medical License',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B4B4B),
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
}

/// Staggered fade + slide up for form sections.
class _StaggerSlide extends StatelessWidget {
  const _StaggerSlide({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
