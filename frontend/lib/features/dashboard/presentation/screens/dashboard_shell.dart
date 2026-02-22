import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../health_insights/presentation/screens/ai_diagnostics_screen.dart';
import '../../../consultation/presentation/screens/consultation_screen.dart';
import '../../../reports/presentation/screens/screening_screen.dart';
import '../../../cycle_tracking/presentation/screens/cycle_tracking_screen.dart';

/// Main app shell with bottom nav: HOME, AI DIAGNOSIS, DOCTOR, SCREENING, PERIOD.
/// Swipe left/right on content to change tabs with slide transition.
class DashboardShell extends ConsumerStatefulWidget {
  const DashboardShell({super.key});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  PageController? _pageController;
  bool _navbarVisible = true;
  double _lastScrollPixels = 0;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  static const _screeningTabIndex = 3;
  static const _periodTabIndex = 4;

  bool _handleScroll(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) return false;
    final index = ref.read(navIndexProvider);
    if (index == _screeningTabIndex || index == _periodTabIndex) return false;
    final pixels = notification.metrics.pixels;
    if (_lastScrollPixels < 0) {
      _lastScrollPixels = pixels;
      return false;
    }
    final delta = pixels - _lastScrollPixels;
    _lastScrollPixels = pixels;
    if (delta > 8 && pixels > 20) {
      if (_navbarVisible) setState(() => _navbarVisible = false);
    } else if (delta < -8 || pixels < 30) {
      if (!_navbarVisible) setState(() => _navbarVisible = true);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(navIndexProvider);
    _pageController ??= PageController(initialPage: index);

    if (_pageController!.hasClients && _pageController!.page?.round() != index) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController!.hasClients && index != _pageController!.page?.round()) {
          _pageController!.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }

    const pages = [
      DashboardScreen(),
      AiDiagnosticsScreen(),
      ConsultationScreen(),
      ScreeningScreen(),
      CycleTrackingScreen(),
    ];

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && index != 0) {
          _goToHome();
        }
      },
      child: Scaffold(
        body: NotificationListener<ScrollNotification>(
          onNotification: _handleScroll,
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (i) {
                  HapticFeedback.lightImpact();
                  ref.read(navIndexProvider.notifier).state = i;
                  _lastScrollPixels = -1;
                  if (!_navbarVisible) setState(() => _navbarVisible = true);
                },
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),
              if (index != 0) _BackToHomeButton(onPressed: _goToHome),
            ],
          ),
        ),
        extendBody: true,
        bottomNavigationBar: TweenAnimationBuilder<double>(
          key: ValueKey(_navbarVisible),
          tween: Tween(begin: _navbarVisible ? 1 : 0, end: _navbarVisible ? 0 : 1),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, value * 120),
              child: child,
            );
          },
          child: _MainNavBar(
            currentIndex: index,
            onTap: (i) {
              HapticFeedback.lightImpact();
              ref.read(navIndexProvider.notifier).state = i;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_pageController!.hasClients &&
                    _pageController!.page?.round() != i) {
                  _pageController!.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                }
              });
            },
          ),
        ),
      ),
    );
  }

  void _goToHome() {
    ref.read(navIndexProvider.notifier).state = 0;
    if (_pageController!.hasClients) {
      _pageController!.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }
}

// Back button shown on non-home tabs; tap goes to home.
class _BackToHomeButton extends StatelessWidget {
  const _BackToHomeButton({required this.onPressed});

  final VoidCallback onPressed;

  static const _maroon = Color(0xFF8B002B);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 4, left: 8),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            elevation: 2,
            shadowColor: Colors.black26,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.keyboard_arrow_left_rounded,
                  color: _maroon,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Main Nav Bar — HOME, AI DIAGNOSIS, DOCTOR, SCREENING, PERIOD (visible on all tabs)
// ═══════════════════════════════════════════════════════════════

class _MainNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _MainNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _labels = [
    'HOME',
    'AI DIAGNOSIS',
    'DOCTOR',
    'SCREENING',
    'PERIOD',
  ];

  static const _icons = [
    Icons.home_rounded,
    Icons.monitor_heart_rounded,
    Icons.medical_services_rounded,
    Icons.settings_rounded,
    Icons.calendar_month_rounded,
  ];

  static const _activeColor = Color(0xFF8B002B);
  static const _inactiveColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    const barHeight = 78.0;

    return Padding(
      padding: EdgeInsets.only(left: 14, right: 14, bottom: bottomPad + 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              children: List.generate(5, (i) {
                return Expanded(
                  child: _NavItem(
                    icon: _icons[i],
                    label: _labels[i],
                    isSelected: currentIndex == i,
                    onTap: () => onTap(i),
                    activeColor: _activeColor,
                    inactiveColor: _inactiveColor,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: activeColor.withValues(alpha: 0.12),
        highlightColor: activeColor.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 38,
                width: 38,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isSelected)
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: activeColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    Icon(
                      icon,
                      size: 20,
                      color: isSelected ? Colors.white : inactiveColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: AppTypography.navBarLabel.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
