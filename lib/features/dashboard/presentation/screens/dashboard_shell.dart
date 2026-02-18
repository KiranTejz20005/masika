import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  static const _pageCount = 5;
  PageController? _pageController;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
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
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (i) {
                HapticFeedback.lightImpact();
                ref.read(navIndexProvider.notifier).state = i;
              },
              children: pages,
              physics: const NeverScrollableScrollPhysics(),
            ),
            if (index != 0) _BackToHomeButton(onPressed: _goToHome),
          ],
        ),
        extendBody: true,
        bottomNavigationBar: index == 0
            ? _MainNavBar(
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
              )
            : null,
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
//  Main Nav Bar — Liquid glass sliding pill + HOME, AI DIAGNOSIS, DOCTOR, SCREENING, PERIOD
// ═══════════════════════════════════════════════════════════════

class _MainNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _MainNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<_MainNavBar> {
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

  late int _fromIndex;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant _MainNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _fromIndex = oldWidget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return LayoutBuilder(
      builder: (context, constraints) {
        const barHeight = 64.0;
        final contentHeight = (constraints.maxHeight - bottomPad - 8).clamp(barHeight, barHeight);
        return Padding(
          padding: EdgeInsets.only(left: 14, right: 14, bottom: bottomPad + 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: contentHeight,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: LayoutBuilder(
                builder: (context, innerConstraints) {
                  final itemWidth = innerConstraints.maxWidth / 5;
                  const circleSize = 44.0;
                  final leftOffset = (itemWidth - circleSize) / 2;
                  final innerHeight = contentHeight - 12;
                  final circleTop = (innerHeight - circleSize) / 2;
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: _fromIndex.toDouble(),
                          end: widget.currentIndex.toDouble(),
                        ),
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Positioned(
                            left: value * itemWidth + leftOffset,
                            top: circleTop,
                            width: circleSize,
                            height: circleSize,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _activeColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _activeColor.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Row(
                        children: List.generate(5, (i) {
                          return Expanded(
                            child: _NavItem(
                              icon: _icons[i],
                              label: _labels[i],
                              isSelected: widget.currentIndex == i,
                              onTap: () => widget.onTap(i),
                              activeColor: _activeColor,
                              inactiveColor: _inactiveColor,
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
            ),
          ),
        );
      },
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
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? Colors.white : inactiveColor,
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : inactiveColor,
                  letterSpacing: 0.2,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
