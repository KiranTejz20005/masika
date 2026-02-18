import 'package:flutter/material.dart';

import '../../data/onboarding_storage.dart';
import '../../domain/onboarding_model.dart';
import '../widgets/onboarding_page.dart';
import '../../../auth/presentation/screens/welcome_screen.dart';

/// 3-screen onboarding per reference: maroon (1–2), teal (3), pixel-perfect layout.
/// Shown on first launch or after app version bump; then navigates to Welcome.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _pageCount = 3;
  late final PageController _pageController;
  int _currentPage = 0;

  static const _maroon = Color(0xFF6C102C);
  static const _tealTop = Color(0xFF8ECFC4);

  static List<OnboardingPageData> get _pages => [
        OnboardingPageData(
          title: 'Track Your Cycle',
          titleAccent: 'with AI',
          description:
              'Harness the power of artificial intelligence to gain deeper insights into your reproductive health and hormonal patterns.',
          topBackgroundColor: _maroon,
          illustrationBackgroundColor: const Color(0xFFE8D4C4),
          showOverlayButtons: true,
          overlayTopRightIcon: Icons.bar_chart_rounded,
          overlayBottomLeftIcon: Icons.favorite_rounded,
          illustrationBuilder: (_) => _placeholderIllustration(Icons.face_rounded),
        ),
        OnboardingPageData(
          title: 'Expert Consultations',
          description:
              'Access a network of specialized gynecologists and health experts from the comfort of your home. Real-time advice, personalized for you.',
          topBackgroundColor: _maroon,
          illustrationBackgroundColor: const Color(0xFFB2DFDB),
          illustrationBuilder: (_) => _placeholderIllustration(Icons.medical_services_rounded),
        ),
        OnboardingPageData(
          title: 'Ready to Start?',
          description:
              'Your personalized wellness journey and AI-powered health insights are just a tap away.',
          topBackgroundColor: _tealTop,
          illustrationBackgroundColor: const Color(0xFFB2DFDB),
          showOverlayButtons: true,
          overlayTopRightIcon: Icons.favorite_rounded,
          overlayBottomLeftIcon: Icons.psychology_rounded,
          illustrationBuilder: (_) => _placeholderIllustration(Icons.self_improvement_rounded),
        ),
      ];

  static Widget _placeholderIllustration(IconData icon) {
    return Center(
      child: Icon(icon, size: 80, color: Colors.white.withValues(alpha: 0.9)),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _onNext() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _onSkip() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await OnboardingStorage.setCompleted();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  static const _bottomBg = Color(0xFFF8F7F5);

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pageCount - 1;
    final primaryColor = _pages[_currentPage].topBackgroundColor;

    return Scaffold(
      backgroundColor: isLastPage ? _tealTop : _pages[_currentPage].topBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              itemCount: _pageCount,
              itemBuilder: (context, index) {
                final data = _pages[index];
                return OnboardingPageWidget(
                  key: ValueKey(index),
                  data: data,
                  illustrationShape: index == 0
                      ? OnboardingIllustrationShape.circle
                      : OnboardingIllustrationShape.roundedRect,
                );
              },
            ),
          ),
          Container(
            color: _bottomBg,
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: isLastPage ? _buildLastPageActions(primaryColor) : _buildNormalActions(primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalActions(Color primaryColor) {
    return Row(
      children: [
        TextButton(
          onPressed: _onSkip,
          child: Text(
            'Skip',
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF6C6C6C),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(),
        _PageIndicator(
          pageCount: _pageCount,
          currentPage: _currentPage,
          activeColor: primaryColor,
        ),
        const Spacer(),
        _NextFAB(onPressed: _onNext, color: primaryColor),
      ],
    );
  }

  Widget _buildLastPageActions(Color primaryColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PageIndicator(
          pageCount: _pageCount,
          currentPage: _currentPage,
          activeColor: _maroon,
        ),
        const SizedBox(height: 20),
        _GetStartedButton(onPressed: _completeOnboarding),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {}, // Terms link - can wire to terms screen later
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFAAAAAA),
                fontWeight: FontWeight.w400,
              ),
              children: [
                const TextSpan(text: 'By starting, you agree to our '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: _maroon,
                    decoration: TextDecoration.underline,
                    decorationColor: _maroon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GetStartedButton extends StatefulWidget {
  const _GetStartedButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<_GetStartedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  static const _maroon = Color(0xFF6C102C);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ScaleTransition(
        scale: _scale,
        child: FilledButton(
          onPressed: widget.onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: _maroon,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 2,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(width: 8),
              Text('>>>', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.pageCount,
    required this.currentPage,
    required this.activeColor,
  });

  final int pageCount;
  final int currentPage;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : const Color(0xFFD0D0D0),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _NextFAB extends StatelessWidget {
  const _NextFAB({required this.onPressed, required this.color});

  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
