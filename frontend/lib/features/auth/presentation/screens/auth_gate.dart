import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/screens/dashboard_shell.dart';
import '../../../doctor_portal/presentation/screens/doctor_shell.dart';
import '../../../onboarding/presentation/screens/onboarding_wizard_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/app_providers.dart';
import 'welcome_screen.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _healthCheckDone = false;

  @override
  Widget build(BuildContext context) {
    final doctorProfile = ref.watch(doctorProfileProvider);
    if (doctorProfile != null) {
      return const DoctorShell();
    }
    final profile = ref.watch(userProfileProvider);
    if (profile != null) {
      final current = ref.watch(localeProvider)?.languageCode;
      if (current != profile.languageCode) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(localeProvider.notifier).state =
              Locale(profile.languageCode);
        });
      }
    }
    if (profile == null) {
      return const WelcomeScreen();
    }
    if (profile.name.isEmpty) {
      return const OnboardingWizardScreen();
    }
    return _HealthGate(
      onCheckDone: () => setState(() => _healthCheckDone = true),
      healthCheckDone: _healthCheckDone,
    );
  }
}

/// After login: load health profile; if missing show health form, else home.
class _HealthGate extends ConsumerStatefulWidget {
  const _HealthGate({
    required this.onCheckDone,
    required this.healthCheckDone,
  });

  final VoidCallback onCheckDone;
  final bool healthCheckDone;

  @override
  ConsumerState<_HealthGate> createState() => _HealthGateState();
}

class _HealthGateState extends ConsumerState<_HealthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    // Refresh profile from Supabase so we have the latest saved data for this account
    final userRepo = ref.read(userRepositoryProvider);
    final profile = await userRepo.getCurrentUserProfile();
    if (profile != null) {
      await ref.read(userProfileProvider.notifier).setProfile(profile);
    }
    await ref.read(healthProfileProvider.notifier).reload();
    if (mounted) widget.onCheckDone();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.healthCheckDone) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
    final healthProfile = ref.watch(healthProfileProvider);
    if (healthProfile == null) {
      return const OnboardingWizardScreen();
    }
    return const DashboardShell();
  }
}
