import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/app_providers.dart';
import 'doctor_home_screen.dart';
import 'doctor_chat_screen.dart';
import 'doctor_video_screen.dart';
import 'doctor_calendar_screen.dart';
import 'doctor_profile_screen.dart';

/// Doctor Portal shell: Home, Video, Chat, Calendar, Profile.
/// Nav bar matches patient app: white rounded bar, maroon circle indicator.
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

// ═══════════════════════════════════════════════════════════════
//  Doctor Nav Bar — matches patient DashboardShell navbar
//  Uppercase labels, solid white bg, maroon circle active indicator
// ═══════════════════════════════════════════════════════════════

class _DoctorNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _DoctorNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _labels = [
    'HOME',
    'VIDEO',
    'CHAT',
    'CALENDAR',
    'PROFILE',
  ];

  static const _icons = [
    Icons.home_rounded,
    Icons.play_circle_outline_rounded,
    Icons.chat_bubble_outline_rounded,
    Icons.calendar_today_rounded,
    Icons.person_outline_rounded,
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
                  child: _DoctorNavItem(
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

class _DoctorNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  const _DoctorNavItem({
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
