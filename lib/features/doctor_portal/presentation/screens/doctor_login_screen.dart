import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/doctor_profile.dart';
import '../../../../shared/providers/app_providers.dart';
import 'doctor_shell.dart';
import 'doctor_register_screen.dart';
import '../../../auth/presentation/screens/welcome_screen.dart';

/// Doctor Portal login: maroon header (stethoscope, Doctor Portal),
/// Login/Register tabs, MEDICAL EMAIL ID, PASSWORD, Login as Doctor, Return to Patient.
class DoctorLoginScreen extends ConsumerStatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  ConsumerState<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends ConsumerState<DoctorLoginScreen> {
  bool _rememberMe = false;
  bool _obscurePassword = true;
  final _emailController = TextEditingController(text: 'doctor@masika.ai');
  final _passwordController = TextEditingController();

  static const _maroon = Color(0xFF8B002B);
  static const _white = Color(0xFFFFFFFF);
  static const _labelGray = Color(0xFF4B4B4B);
  static const _inputBg = Color(0xFFF0EFEF);
  static const _iconMaroon = Color(0xFF8B002B);
  static const _registerInactive = Color(0xFFB47C8B);
  static const _bottomBg = Color(0xFFF8F7F5);
  static const _cardRadiusTop = 44.0;
  static const _cardRadiusBottom = 36.0;
  static const _inputRadius = 14.0;
  static const _horizontalMargin = 24.0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginAsDoctor() {
    final email = _emailController.text.trim();
    final name = email.isNotEmpty ? 'Dr. ${email.split('@').first}' : 'Doctor';
    ref.read(doctorProfileProvider.notifier).setProfile(
          DoctorProfile(
            id: 'doctor_${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            email: email.isEmpty ? 'doctor@masika.ai' : email,
          ),
        );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DoctorShell()),
    );
  }

  void _openRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DoctorRegisterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _returnToPatientLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: _bottomBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 24 + bottomPad),
                child: Column(
                  children: [
                    _buildLoginCard(),
                    _buildReturnToPatientButton(),
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
    return Container(
      width: double.infinity,
      color: _maroon,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_horizontalMargin, 24, _horizontalMargin, 44),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _white.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.medical_services_rounded,
                  size: 36,
                  color: _white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Doctor Portal',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: _white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Masika Professional Network',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _white.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: _horizontalMargin),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(_cardRadiusTop),
            topRight: Radius.circular(_cardRadiusTop),
            bottomLeft: Radius.circular(_cardRadiusBottom),
            bottomRight: Radius.circular(_cardRadiusBottom),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabs(),
            const SizedBox(height: 24),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(
            color: _maroon,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Text(
            'Login',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _white,
            ),
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: _openRegister,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Text(
              'Register',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _registerInactive,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('MEDICAL EMAIL ID'),
        const SizedBox(height: 10),
        _buildEmailField(),
        const SizedBox(height: 20),
        _buildLabel('PASSWORD'),
        const SizedBox(height: 10),
        _buildPasswordField(),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (v) => setState(() => _rememberMe = v ?? false),
                activeColor: _maroon,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return _maroon;
                  return _white;
                }),
                side: BorderSide(
                  color: _iconMaroon.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Remember me',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _labelGray,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Forgot password? Reset link (demo)'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _maroon,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildLoginButton(),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _labelGray,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(_inputRadius),
      ),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontSize: 15, color: _labelGray),
        decoration: InputDecoration(
          hintText: 'doctor@masika.ai',
          hintStyle: const TextStyle(fontSize: 15, color: _iconMaroon),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(Icons.mail_outline_rounded, color: _iconMaroon, size: 22),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(_inputRadius),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(fontSize: 15, color: _labelGray),
        decoration: InputDecoration(
          hintText: '• • • • • • • •',
          hintStyle: const TextStyle(fontSize: 15, color: _iconMaroon),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(Icons.lock_outline_rounded, color: _iconMaroon, size: 22),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: _iconMaroon,
              size: 22,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 54,
      child: FilledButton(
        onPressed: _loginAsDoctor,
        style: FilledButton.styleFrom(
          backgroundColor: _maroon,
          foregroundColor: _white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login as Doctor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnToPatientButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_horizontalMargin, 24, _horizontalMargin, 8),
      child: SizedBox(
        height: 54,
        child: OutlinedButton(
          onPressed: _returnToPatientLogin,
          style: OutlinedButton.styleFrom(
            foregroundColor: _maroon,
            side: const BorderSide(color: _maroon, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
            backgroundColor: _white,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline_rounded, size: 22),
              SizedBox(width: 10),
              Text(
                'Return to Patient Login',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
