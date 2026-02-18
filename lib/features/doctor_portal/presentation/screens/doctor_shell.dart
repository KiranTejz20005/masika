import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_providers.dart';
import 'doctor_home_screen.dart';
import 'doctor_chat_screen.dart';
import 'doctor_video_screen.dart';
import 'doctor_calendar_screen.dart';
import 'doctor_profile_screen.dart';

/// Doctor Portal shell: Home, Video, Chat, Calendar, Profile.
/// Nav bar matches patient app: white rounded bar, sliding circular maroon indicator.
class DoctorShell extends ConsumerWidget {
  const DoctorShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(doctorNavIndexProvider);

    const pages = [
      DoctorHomeScreen(),
      DoctorVideoScreen(),
      DoctorChatScreen(),
      DoctorCalendarScreen(),
      DoctorProfileScreen(),
    ];

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && index != 0) {
          ref.read(doctorNavIndexProvider.notifier).state = 0;
        }
      },
      child: Scaffold(
        body: IndexedStack(index: index, children: pages),
        extendBody: true,
        bottomNavigationBar: _DoctorNavBar(
          currentIndex: index,
          onTap: (i) {
            HapticFeedback.lightImpact();
            ref.read(doctorNavIndexProvider.notifier).state = i;
          },
        ),
      ),
    );
  }
}

const _maroon = Color(0xFF8B002B);
const _navInactive = Color(0xFF9E9E9E);

class _DoctorNavBar extends StatefulWidget {
  const _DoctorNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<_DoctorNavBar> createState() => _DoctorNavBarState();
}

class _DoctorNavBarState extends State<_DoctorNavBar> {
  static const _labels = [
    'Home',
    'Video',
    'Chat',
    'Calendar',
    'Profile',
  ];

  static const _icons = [
    Icons.home_rounded,
    Icons.play_circle_outline_rounded,
    Icons.chat_bubble_outline_rounded,
    Icons.calendar_today_rounded,
    Icons.person_outline_rounded,
  ];

  late int _fromIndex;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant _DoctorNavBar oldWidget) {
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
                                  color: _maroon,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _maroon.withValues(alpha: 0.3),
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
                              child: _DoctorNavItem(
                                icon: _icons[i],
                                label: _labels[i],
                                isSelected: widget.currentIndex == i,
                                onTap: () => widget.onTap(i),
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

class _DoctorNavItem extends StatelessWidget {
  const _DoctorNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: _maroon.withValues(alpha: 0.12),
        highlightColor: _maroon.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? Colors.white : _navInactive,
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : _navInactive,
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
