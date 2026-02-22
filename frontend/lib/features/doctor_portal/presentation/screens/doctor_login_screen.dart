import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/doctor_profile.dart';
import '../../../../shared/providers/app_providers.dart';
import 'doctor_shell.dart';
import 'doctor_register_screen.dart';
import '../../../auth/presentation/screens/welcome_screen.dart';

/// Doctor Portal login: pixel-perfect replica of design reference.
/// Maroon gradient header with stethoscope, Login/Register tabs, 
/// MEDICAL EMAIL ID, PASSWORD fields, Login as Doctor button, Return to Patient.
class DoctorLoginScreen extends ConsumerStatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  ConsumerState<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends ConsumerState<DoctorLoginScreen> {
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int _tabIndex = 0;

  // Design colors matching reference
  static const _maroon = Color(0xFF8C1D3F);
  static const _white = Color(0xFFFFFFFF);
  static const _labelGray = Color(0xFF4B4B4B);
  static const _inputBg = Color(0xFFF0EFEF);
  static const _iconMuted = Color(0xFFAD7B85);
  static const _registerInactive = Color(0xFFB47C8B);
  static const _bottomBg = Color(0xFFF8F8F8);
  static const _cardRadiusTop = 36.0;
  static const _cardRadiusBottom = 28.0;
  static const _inputRadius = 14.0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginAsDoctor() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final doctorRepo = ref.read(doctorRepositoryProvider);
      await doctorRepo.loginDoctor(email: email, password: password);

      // Get doctor profile (Supabase when configured)
      final profile = await doctorRepo.getCurrentDoctorProfile();

      if (profile != null) {
        ref.read(doctorProfileProvider.notifier).setProfile(profile);
        ref.read(isDoctorLoggedInProvider.notifier).state = true;
        _navigateToDoctorPortal();
      } else {
        // Create profile if not exists
        final newProfile = DoctorProfile(
          id: doctorRepo.currentDoctorId ?? '',
          name: email.split('@').first,
          email: email,
        );
        await doctorRepo.saveDoctorProfile(newProfile);
        ref.read(doctorProfileProvider.notifier).setProfile(newProfile);
        ref.read(isDoctorLoggedInProvider.notifier).state = true;
        _navigateToDoctorPortal();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToDoctorPortal() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DoctorShell()),
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
    return Scaffold(
      backgroundColor: _bottomBg,
      body: Stack(
        children: [
          // Background gradient section
          _buildHeader(),
          // Main content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 180),
                  _buildLoginCard(),
                  _buildReturnToPatientButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 320,
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
            const SizedBox(height: 40),
            // Frosted glass circle with stethoscope icon
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
            const Text(
              'Doctor Portal',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: _white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Masika Professional Network',
              style: TextStyle(
                fontSize: 15,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.only(
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
        children: [
          _buildTabs(),
          const SizedBox(height: 28),
          if (_tabIndex == 0)
            _buildForm()
          else
            DoctorRegisterScreen(
              embedded: true,
              onBack: () => setState(() => _tabIndex = 0),
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = 0),
              child: Container(
                decoration: BoxDecoration(
                  color: _tabIndex == 0 ? _maroon : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _tabIndex == 0 ? _white : _registerInactive,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = 1),
              child: Container(
                decoration: BoxDecoration(
                  color: _tabIndex == 1 ? _maroon : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _tabIndex == 1 ? _white : _registerInactive,
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

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('MEDICAL EMAIL ID'),
        const SizedBox(height: 8),
        _buildEmailField(),
        const SizedBox(height: 20),
        _buildLabel('PASSWORD'),
        const SizedBox(height: 8),
        _buildPasswordField(),
        const SizedBox(height: 14),
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
                  color: _iconMuted.withValues(alpha: 0.6),
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
              onTap: () {},
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
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: _labelGray,
        ),
        decoration: InputDecoration(
          hintText: 'doctor@masika.ai',
          hintStyle: TextStyle(
            fontSize: 15,
            color: _labelGray.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(Icons.email_outlined, color: _iconMuted, size: 22),
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
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: _labelGray,
          letterSpacing: 2,
        ),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: const TextStyle(
            fontSize: 15,
            color: _iconMuted,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(Icons.lock_outline_rounded, color: _iconMuted, size: 22),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: _iconMuted,
                size: 22,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
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
        onPressed: _isLoading ? null : _loginAsDoctor,
        style: FilledButton.styleFrom(
          backgroundColor: _maroon,
          foregroundColor: _white,
          disabledBackgroundColor: _maroon.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: _white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Login as Doctor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnToPatientButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Material(
        color: _white,
        borderRadius: BorderRadius.circular(24),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: Container(
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: _returnToPatientLogin,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    color: _maroon,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Return to Patient Login',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _maroon,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
