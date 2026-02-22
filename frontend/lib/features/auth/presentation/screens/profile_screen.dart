import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../consultation/presentation/screens/my_bookings_screen.dart';
import '../../../health_onboarding/presentation/screens/health_onboarding_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../health_insights/presentation/screens/health_insight_screen.dart';
import 'edit_profile_screen.dart';
import 'welcome_screen.dart';

/// Settings-style profile screen: user card, HEALTH RECORDS, SUPPORT & LEGAL,
/// Change Language, Logout. Pixel-perfect per design reference.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _maroon = Color(0xFF8B3037);
  static const _bg = Color(0xFFF9F7F8);
  static const _sectionGray = Color(0xFFAAAAAA);
  static const _cardBg = Color(0xFFFDFCFC);
  static const _iconBg = Color(0xFFF0EBEC);
  static const _textDark = Color(0xFF333333);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final name = profile?.name.isNotEmpty == true ? profile!.name : 'Guest User';
    final email = profile?.email?.isNotEmpty == true
        ? profile!.email!
        : 'sarah.j@example.com';

    final theme = Theme.of(context);
    final bg = theme.scaffoldBackgroundColor;
    final textColor = theme.colorScheme.onSurface;
    final subtextColor = theme.colorScheme.onSurface.withValues(alpha: 0.7);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.primary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: AppTypography.screenTitle.copyWith(color: textColor),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _buildProfileCard(context, ref, name, email, theme),
            const SizedBox(height: 24),
            _sectionLabel('UPGRADE TO PREMIUM', subtextColor),
            const SizedBox(height: 10),
            _buildUpgradeToPremiumCard(context),
            const SizedBox(height: 24),
            _sectionLabel('HEALTH RECORDS', subtextColor),
            const SizedBox(height: 10),
            _SettingsRow(
              icon: Icons.calendar_today_rounded,
              label: 'My Bookings',
              onTap: () => _push(context, const MyBookingsScreen()),
            ),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.show_chart_rounded,
              label: 'Diagnosis History',
              onTap: () => _push(context, const HealthInsightScreen()),
            ),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.description_rounded,
              label: 'Reports',
              onTap: () => _push(context, const ReportsScreen()),
            ),
            const SizedBox(height: 24),
            _sectionLabel('SUPPORT & LEGAL', subtextColor),
            const SizedBox(height: 10),
            _SettingsRow(
              icon: Icons.help_outline_rounded,
              label: 'FAQ',
              onTap: () => _push(
                context,
                _ContentScreen(
                  title: 'FAQ',
                  body: 'Frequently asked questions and support.\n\n'
                      'How do I create an account? You can sign up using your email or phone with OTP. '
                      'You can also continue as guest and create an account later from Profile.\n\n'
                      'How do I track my cycle? Tap the + button to open the cycle logger. '
                      'Enter period start/end, flow, and symptoms. The app predicts future cycles and fertile windows.\n\n'
                      'Is my data secure? Yes. We use encryption and comply with privacy regulations. '
                      'Your health data is never sold or shared with third parties.',
                ),
              ),
            ),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.gavel_rounded,
              label: 'Terms of Service',
              onTap: () => _push(
                context,
                _ContentScreen(
                  title: 'Terms of Service',
                  body: 'By using Masika AI you agree to our terms.\n\n'
                      'You must be at least 13 years old. Users under 18 should have parental consent. '
                      'You are responsible for the accuracy of data you enter. '
                      'The app is provided "as is" and is not a medical device. '
                      'Always consult a healthcare provider for medical decisions. '
                      'We may modify or discontinue features with reasonable notice.',
                ),
              ),
            ),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.info_outline_rounded,
              label: 'About Us',
              onTap: () => _push(
                context,
                _ContentScreen(
                  title: 'About Us',
                  body: 'Masika AI — Empowering Women\'s Wellness.\n\n'
                      'We are building a comprehensive menstrual wellness platform with '
                      'cycle tracking, AI insights, and personalized care. '
                      'Our mission is to make menstrual health accessible and stigma-free. '
                      'Contact: support@masika.app',
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildChangeLanguage(context, ref),
            const SizedBox(height: 20),
            _buildLogoutButton(context, ref),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Masika AI v2.4.0',
                style: TextStyle(
                  fontSize: 12,
                  color: subtextColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref, String name, String email, ThemeData theme) {
    final profile = ref.watch(userProfileProvider);
    final avatarUrl = profile?.avatarUrl;
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.7);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _push(context, const EditProfileScreen()),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? Image.network(avatarUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.person_rounded, color: primary, size: 36))
                  : Icon(Icons.person_rounded, color: primary, size: 36),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _push(context, const EditProfileScreen()),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: muted,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _push(context, const EditProfileScreen()),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Edit name & photo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary)),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded, size: 20, color: primary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        final healthProfile = ref.read(healthProfileProvider);
                        _push(
                          context,
                          HealthOnboardingScreen(
                            initialProfile: healthProfile,
                            isEditMode: true,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('View Profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary)),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded, size: 20, color: primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeToPremiumCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _showPremiumPlansSheet(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _maroon.withValues(alpha: 0.14),
                _maroon.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _maroon.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _maroon.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _maroon.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _maroon.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.workspace_premium_rounded, color: _maroon, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Upgrade to Premium',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _maroon,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Unlock AI Diagnosis — ₹99/mo or ₹1,149/year',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _maroon.withValues(alpha: 0.85),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _maroon.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded, size: 20, color: _maroon),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPremiumPlansSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.workspace_premium_rounded, color: _maroon, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'To use AI Diagnosis, choose a plan below.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            _PremiumPlanTile(
              title: 'Monthly',
              price: '₹99',
              period: 'per month',
              subtitle: 'Billed monthly. Cancel anytime.',
              onTap: () => _onSelectPlan(context, 'monthly'),
            ),
            const SizedBox(height: 12),
            _PremiumPlanTile(
              title: 'Yearly',
              price: '₹1,149',
              period: 'per year',
              subtitle: 'Save vs monthly. Billed annually.',
              isRecommended: true,
              onTap: () => _onSelectPlan(context, 'yearly'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _onSelectPlan(BuildContext context, String plan) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          plan == 'yearly'
              ? 'Yearly plan (₹1,149) selected. Payment integration coming soon.'
              : 'Monthly plan (₹99) selected. Payment integration coming soon.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _sectionLabel(String text, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color ?? _sectionGray,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildChangeLanguage(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final code = locale?.languageCode ?? 'en';
    const labels = {'en': 'English', 'hi': 'Hindi', 'te': 'Telugu', 'bn': 'Bengali'};
    final currentLabel = labels[code] ?? 'English';

    return GestureDetector(
      onTap: () => _showLanguageSheet(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.language_rounded, color: _maroon, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Change Language',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ),
            Text(
              currentLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _sectionGray,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _maroon,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    const options = {'en': 'English', 'hi': 'Hindi', 'te': 'Telugu', 'bn': 'Bengali'};
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Change Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            ...options.entries.map((e) => ListTile(
                  title: Text(e.value),
                  onTap: () {
                    ref.read(localeProvider.notifier).state = Locale(e.key);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () => _onLogout(context, ref),
      style: OutlinedButton.styleFrom(
        foregroundColor: _maroon,
        side: const BorderSide(color: _maroon, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, size: 20),
          SizedBox(width: 10),
          Text(
            'Logout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onLogout(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    await ref.read(userProfileProvider.notifier).clearProfile();
    if (!context.mounted) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Settings row: icon in pink circle, label, arrow
// ═══════════════════════════════════════════════════════════════

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Premium plan tile for upgrade sheet
// ═══════════════════════════════════════════════════════════════

class _PremiumPlanTile extends StatelessWidget {
  const _PremiumPlanTile({
    required this.title,
    required this.price,
    required this.period,
    required this.subtitle,
    required this.onTap,
    this.isRecommended = false,
  });

  final String title;
  final String price;
  final String period;
  final String subtitle;
  final VoidCallback onTap;
  final bool isRecommended;

  static const _maroon = Color(0xFF8B3037);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isRecommended ? _maroon.withValues(alpha: 0.06) : const Color(0xFFF9F7F8),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isRecommended ? Border.all(color: _maroon, width: 2) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isRecommended)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _maroon,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'BEST VALUE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _maroon,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          period,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _maroon),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Generic content screen for FAQ / Terms / About
// ═══════════════════════════════════════════════════════════════

class _ContentScreen extends StatelessWidget {
  final String title;
  final String body;

  const _ContentScreen({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFF8F7F5),
        elevation: 0,
        foregroundColor: const Color(0xFF1A1A1A),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              body,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
