import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/onboarding_storage.dart';
import '../../domain/onboarding_model.dart';
import '../widgets/onboarding_page.dart';
import '../../../auth/presentation/screens/welcome_screen.dart';

/// Onboarding: 4 pages (3 content + 1 swipe-to-complete). Same layout and animations throughout.
/// Get Started: tap or swipe left on last content page → Welcome. Theme-matched premium look.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _contentPages = 3;
  static const int _totalPages = 4; // 4th = swipe target, triggers completion
  late final PageController _pageController;
  int _currentPage = 0;

  static Color get _maroon => AppColors.primary;
  static const _teal = Color(0xFF8ECFC4);

  Color get _currentBackgroundColor {
    if (_currentPage >= _contentPages - 1) return _teal;
    return _pages[_currentPage].topBackgroundColor;
  }

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
          illustrationBuilder: (_) => _buildIllustration(Icons.calendar_month_rounded),
        ),
        OnboardingPageData(
          title: 'Expert Consultations',
          description:
              'Access a network of specialized gynecologists and health experts from the comfort of your home. Real-time advice, personalized for you.',
          topBackgroundColor: _maroon,
          illustrationBackgroundColor: const Color(0xFFB2DFDB),
          illustrationBuilder: (_) => _buildIllustration(Icons.medical_services_rounded),
        ),
        OnboardingPageData(
          title: 'Ready to Start?',
          description:
              'Your personalized wellness journey and AI-powered health insights are just a tap or swipe away.',
          topBackgroundColor: _teal,
          illustrationBackgroundColor: const Color(0xFFB2DFDB),
          showOverlayButtons: true,
          overlayTopRightIcon: Icons.favorite_rounded,
          overlayBottomLeftIcon: Icons.psychology_rounded,
          illustrationBuilder: (_) => _buildIllustration(Icons.rocket_launch_rounded),
        ),
      ];

  static Widget _buildIllustration(IconData icon) {
    return Center(
      child: Icon(
        icon,
        size: 88,
        color: Colors.white.withValues(alpha: 0.95),
      ),
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
    if (index == _totalPages - 1) {
      HapticFeedback.lightImpact();
      _completeOnboarding();
    }
  }

  void _onNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
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
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.03, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  static const _bottomBg = Color(0xFFF8F7F5);
  static const _bottomBarMinHeight = 168.0;

  @override
  Widget build(BuildContext context) {
    final isLastContentPage = _currentPage == _contentPages - 1;
    final primaryColor = _currentPage < _pages.length
        ? _pages[_currentPage].topBackgroundColor
        : _teal;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      color: _currentBackgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  final data = _pages[index.clamp(0, _contentPages - 1)];
                  return OnboardingPageWidget(
                    key: ValueKey(index),
                    data: data,
                    illustrationShape: OnboardingIllustrationShape.roundedRect,
                  );
                },
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              color: _bottomBg,
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: _bottomBarMinHeight),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.06),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  ),
                  child: isLastContentPage
                      ? KeyedSubtree(
                          key: const ValueKey<bool>(true),
                          child: _buildLastPageActions(primaryColor),
                        )
                      : KeyedSubtree(
                          key: const ValueKey<bool>(false),
                          child: _buildNormalActions(primaryColor),
                        ),
                ),
              ),
            ),
          ],
        ),
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
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(),
        _PageIndicator(
          pageCount: _contentPages,
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PageIndicator(
          pageCount: _contentPages,
          currentPage: _currentPage,
          activeColor: _maroon,
        ),
        const SizedBox(height: 6),
        Text(
          'Swipe left or tap below',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        _GetStartedButton(onPressed: _completeOnboarding),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {},
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
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
  static const _maroon = Color(0xFF6C102C);

  const _GetStartedButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<_GetStartedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
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
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 2,
            shadowColor: AppColors.primary.withValues(alpha: 0.35),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
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
          duration: const Duration(milliseconds: 220),
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
