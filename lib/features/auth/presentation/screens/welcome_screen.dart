import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/user_profile.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../dashboard/presentation/screens/dashboard_shell.dart';
import '../../../doctor_portal/presentation/screens/doctor_login_screen.dart';
import 'register_screen.dart';

/// Pixel-perfect login screen per design reference.
/// Top maroon branding, white login card, healthcare professional CTA.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _rememberMe = false;
  bool _obscurePassword = true;
  final _emailController = TextEditingController(text: 'hello@masika.ai');
  final _passwordController = TextEditingController();

  int _tabIndex = 0;
  bool _isNavigating = false;

  // Design reference: deep red/maroon #8C1D3F, white cards, rounded corners throughout
  static const _maroon = Color(0xFF8C1D3F);
  static const _white = Color(0xFFFFFFFF);
  static const _labelGray = Color(0xFF4B4B4B);
  static const _inputBg = Color(0xFFF0EFEF);
  static const _iconMuted = Color(0xFFAD7B85);
  static const _forgotRed = Color(0xFF8C1D3F);
  static const _registerInactive = Color(0xFFB47C8B);
  static const _bottomBg = Color(0xFFF8F8F8);
  static const _healthcareGray = Color(0xFF9B9B9B);
  static const _cardRadiusTop = 36.0;
  static const _cardRadiusBottom = 28.0;
  static const _inputRadius = 14.0;
  static const _healthcareCardRadius = 24.0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _continueAsGuest() {
    final profile = UserProfile(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Guest User',
      age: 25,
      languageCode: 'en',
      cycleLength: 28,
      periodDuration: 5,
    );
    ref.read(userProfileProvider.notifier).setProfile(profile);
    _navigateToDashboard();
  }

  void _openRegisterScreen() {
    if (_isNavigating) return;
    _isNavigating = true;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RegisterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: Curves.easeOutCubic),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    ).then((_) {
      if (mounted) {
        _isNavigating = false;
        setState(() {
          _tabIndex = 0;
        });
      }
    });
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DashboardShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bottomBg,
      body: Stack(
        children: [
          // Background gradient section
          _buildTopSection(context),
          // Main content with scroll
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 180), // Space for header content
                  _buildLoginCard(context),
                  _buildHealthcareButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
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
            // Frosted glass circle with female symbol
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
                  Icons.female,
                  size: 40,
                  color: _white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Masika AI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: _white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Empowering Women's Wellness",
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

  Widget _buildLoginCard(BuildContext context) {
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
          _buildLoginForm(),
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
              onTap: () {
                setState(() => _tabIndex = 1);
                _openRegisterScreen();
              },
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

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('EMAIL ID'),
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
                side: BorderSide(color: _iconMuted.withValues(alpha: 0.6), width: 1.5),
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
                  color: _forgotRed,
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
          hintText: 'hello@masika.ai',
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
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: _iconMuted,
                size: 22,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
        onPressed: () {
          _continueAsGuest();
        },
        style: FilledButton.styleFrom(
          backgroundColor: _maroon,
          foregroundColor: _white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login',
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

  Widget _buildHealthcareButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Material(
        color: _white,
        borderRadius: BorderRadius.circular(_healthcareCardRadius),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: Container(
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(_healthcareCardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DoctorLoginScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(_healthcareCardRadius),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: _maroon,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.favorite,
                      color: _white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HEALTHCARE PROFESSIONAL?',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _healthcareGray,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Continue as Doctor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _maroon,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: _healthcareGray,
                    size: 16,
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
