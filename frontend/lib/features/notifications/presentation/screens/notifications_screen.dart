import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/app_notification.dart';
import '../../../../shared/providers/app_providers.dart';

/// Pixel-perfect Notifications screen: Unread/Read tabs, grouped list, Mark all as read.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  static const _maroon = Color(0xFF8D2D3B);
  static const _bg = Color(0xFFF8F7F5);
  static const _sectionGray = Color(0xFF9E9E9E);
  static const _cardBg = Color(0xFFFAFAFA);
  static const _iconBg = Color(0xFFFFE4EE);
  static const _titleColor = Color(0xFF1A1A1A);
  static const _bodyColor = Color(0xFF4B4B4B);

  bool _showUnread = true;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(notificationsProvider);
    final filtered = _showUnread
        ? all.where((n) => !n.isRead).toList()
        : all.where((n) => n.isRead).toList();

    final today = filtered.where((n) => n.dateGroup == 'today').toList();
    final yesterday =
        filtered.where((n) => n.dateGroup == 'yesterday').toList();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _maroon,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTypography.screenTitle.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: _bodyColor, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSegmentedControl(),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmpty()
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      if (today.isNotEmpty) ...[
                        _sectionLabel('TODAY'),
                        const SizedBox(height: 10),
                        ...today.map((n) => _NotificationCard(
                              notification: n,
                              iconBg: _iconBg,
                              maroon: _maroon,
                              cardBg: _cardBg,
                              titleColor: _titleColor,
                              bodyColor: _bodyColor,
                              sectionGray: _sectionGray,
                            )),
                        const SizedBox(height: 20),
                      ],
                      if (yesterday.isNotEmpty) ...[
                        _sectionLabel('YESTERDAY'),
                        const SizedBox(height: 10),
                        ...yesterday.map((n) => _NotificationCard(
                              notification: n,
                              iconBg: _iconBg,
                              maroon: _maroon,
                              cardBg: _cardBg,
                              titleColor: _titleColor,
                              bodyColor: _bodyColor,
                              sectionGray: _sectionGray,
                            )),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
          ),
          _buildMarkAllReadButton(),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: _SegmentTab(
                label: 'Unread',
                isSelected: _showUnread,
                onTap: () => setState(() => _showUnread = true),
                maroon: _maroon,
              ),
            ),
            Expanded(
              child: _SegmentTab(
                label: 'Read',
                isSelected: !_showUnread,
                onTap: () => setState(() => _showUnread = false),
                maroon: _maroon,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _sectionGray,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        _showUnread ? 'No unread notifications' : 'No read notifications',
        style: TextStyle(
          fontSize: 14,
          color: _sectionGray,
        ),
      ),
    );
  }

  Widget _buildMarkAllReadButton() {
    final all = ref.watch(notificationsProvider);
    final hasUnread = all.any((n) => !n.isRead);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: hasUnread
                ? () {
                    ref.read(notificationsProvider.notifier).markAllAsRead();
                    setState(() => _showUnread = false);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _maroon,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _sectionGray.withValues(alpha: 0.3),
              disabledForegroundColor: Colors.white70,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_rounded, size: 22),
                SizedBox(width: 8),
                Text(
                  'Mark all as read',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.maroon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color maroon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? maroon : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.iconBg,
    required this.maroon,
    required this.cardBg,
    required this.titleColor,
    required this.bodyColor,
    required this.sectionGray,
  });

  final AppNotification notification;
  final Color iconBg;
  final Color maroon;
  final Color cardBg;
  final Color titleColor;
  final Color bodyColor;
  final Color sectionGray;

  static IconData _iconFor(int iconId) {
    switch (iconId) {
      case 0:
        return Icons.science_rounded;
      case 1:
        return Icons.person_rounded;
      case 2:
        return Icons.calendar_today_rounded;
      case 3:
        return Icons.lightbulb_outline_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _iconFor(notification.iconId),
                    color: maroon,
                    size: 24,
                  ),
                ),
                if (!notification.isRead)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: maroon,
                        shape: BoxShape.circle,
                        border: Border.all(color: cardBg, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        notification.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: sectionGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: bodyColor,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
