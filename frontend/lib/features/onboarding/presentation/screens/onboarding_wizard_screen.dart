import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/user_health_profile.dart';
import '../../../../shared/models/user_profile.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../auth/data/user_repository.dart';
import '../../../dashboard/presentation/screens/dashboard_shell.dart';

/// Single onboarding flow: name, age, language → cycle basics → symptoms → lifestyle → concerns → confirm.
/// Shown when profile name is empty or health profile is missing. Replaces separate profile setup + health form.
class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  ConsumerState<OnboardingWizardScreen> createState() =>
      _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends ConsumerState<OnboardingWizardScreen> {
  static const _totalSteps = 6;
  final _formKey = GlobalKey<FormState>();
  int _step = 0;
  bool _saving = false;
  String? _errorMessage;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _languageCode = 'en';

  int _cycleLength = 28;
  int _periodDuration = 5;
  String _flowRate = 'medium';
  bool _painDuringPeriod = false;
  int _padsPerDay = 3;
  bool _clotting = false;
  String _weaknessLevel = 'medium';
  final _dietController = TextEditingController();
  final _concernController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profile = ref.read(userProfileProvider);
      final healthProfile = ref.read(healthProfileProvider);
      if (profile != null && profile.name.isNotEmpty) {
        _nameController.text = profile.name;
        _ageController.text = profile.age > 0 ? profile.age.toString() : '';
        _languageCode = profile.languageCode;
        _cycleLength = profile.cycleLength;
        _periodDuration = profile.periodDuration;
      }
      if (healthProfile != null) {
        _cycleLength = healthProfile.cycleLength;
        _periodDuration = healthProfile.periodDuration;
        _flowRate = healthProfile.flowRate;
        _painDuringPeriod = healthProfile.painDuringPeriod;
        _padsPerDay = healthProfile.padsPerDay;
        _clotting = healthProfile.clotting;
        _weaknessLevel = healthProfile.weaknessLevel;
        _dietController.text = healthProfile.dietDescription;
        _concernController.text = healthProfile.healthConcernDescription;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _dietController.dispose();
    _concernController.dispose();
    super.dispose();
  }

  bool _validateStep() {
    _errorMessage = null;
    if (_step == 0) {
      if (_nameController.text.trim().isEmpty) {
        _errorMessage = 'Please enter your name';
        return false;
      }
      final age = int.tryParse(_ageController.text);
      if (age == null || age < 10 || age > 100) {
        _errorMessage = 'Please enter a valid age (10–100)';
        return false;
      }
    }
    if (_step == 1) {
      if (_cycleLength < 21 || _cycleLength > 45) {
        _errorMessage = 'Cycle length is usually between 21 and 45 days';
        return false;
      }
      if (_periodDuration < 1 || _periodDuration > 10) {
        _errorMessage = 'Period duration is usually 1–10 days';
        return false;
      }
    }
    if (_step == 2) {
      if (_padsPerDay < 1 || _padsPerDay > 10) {
        _errorMessage = 'Please enter pads per day (1–10)';
        return false;
      }
    }
    return true;
  }

  void _next() {
    if (!_validateStep()) {
      setState(() {});
      return;
    }
    HapticFeedback.lightImpact();
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _back() {
    HapticFeedback.lightImpact();
    if (_step > 0) {
      setState(() {
        _step--;
        _errorMessage = null;
      });
    }
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _saving = true);
    _errorMessage = null;
    final existingProfile = ref.read(userProfileProvider);
    final userId = (existingProfile != null &&
            existingProfile.id.isNotEmpty &&
            existingProfile.id != 'guest')
        ? existingProfile.id
        : const Uuid().v4();
    final age = int.tryParse(_ageController.text) ?? 25;
    final profile = UserProfile(
      id: userId,
      name: _nameController.text.trim(),
      age: age,
      languageCode: _languageCode,
      cycleLength: _cycleLength,
      periodDuration: _periodDuration,
    );
    final healthProfile = UserHealthProfile(
      userId: userId,
      cycleLength: _cycleLength,
      periodDuration: _periodDuration,
      flowRate: _flowRate,
      painDuringPeriod: _painDuringPeriod,
      padsPerDay: _padsPerDay,
      clotting: _clotting,
      weaknessLevel: _weaknessLevel,
      dietDescription: _dietController.text.trim(),
      healthConcernDescription: _concernController.text.trim(),
    );
    ref.read(userProfileProvider.notifier).setProfile(profile);
    ref.read(localeProvider.notifier).state = Locale(_languageCode);
    await UserRepository().saveProfile(profile);
    await ref.read(healthProfileProvider.notifier).setHealthProfile(healthProfile);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DashboardShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  String get _stepTitle {
    switch (_step) {
      case 0:
        return 'About you';
      case 1:
        return 'Cycle basics';
      case 2:
        return 'Symptoms';
      case 3:
        return 'Lifestyle';
      case 4:
        return 'Concerns';
      case 5:
        return 'Confirm';
      default:
        return 'Onboarding';
    }
  }

  Widget _stepContent() {
    switch (_step) {
      case 0:
        return _buildStepAboutYou();
      case 1:
        return _buildStepCycleBasics();
      case 2:
        return _buildStepSymptoms();
      case 3:
        return _buildStepLifestyle();
      case 4:
        return _buildStepConcerns();
      case 5:
        return _buildStepConfirmation();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStepAboutYou() {
    final t = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.t('name'),
                  style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: t.t('name'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                  ),
                  validator: Validators.requiredField,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Text(
                  t.t('age'),
                  style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g. 28',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                  ),
                  validator: Validators.requiredField,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Text(
                  t.t('language'),
                  style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _languageCode,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                  ),
                  items: [
                    DropdownMenuItem(value: 'en', child: Text(t.t('lang_en'))),
                    DropdownMenuItem(value: 'hi', child: Text(t.t('lang_hi'))),
                    DropdownMenuItem(value: 'te', child: Text(t.t('lang_te'))),
                    DropdownMenuItem(value: 'bn', child: Text(t.t('lang_bn'))),
                  ],
                  onChanged: (v) => setState(() => _languageCode = v ?? 'en'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCycleBasics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cycle length (days)',
                style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton.filled(
                    onPressed: () =>
                        setState(() => _cycleLength = (_cycleLength - 1).clamp(21, 45)),
                    icon: const Icon(Icons.remove, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '$_cycleLength',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () =>
                        setState(() => _cycleLength = (_cycleLength + 1).clamp(21, 45)),
                    icon: const Icon(Icons.add, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Text(
                'Typically 21–45 days',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Period duration (days)',
                style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton.filled(
                    onPressed: () => setState(
                        () => _periodDuration = (_periodDuration - 1).clamp(1, 10)),
                    icon: const Icon(Icons.remove, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '$_periodDuration',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () => setState(
                        () => _periodDuration = (_periodDuration + 1).clamp(1, 10)),
                    icon: const Icon(Icons.add, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepSymptoms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Flow rate',
                style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Row(
                children: ['low', 'medium', 'high'].map((v) {
                  final selected = _flowRate == v;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(v),
                        selected: selected,
                        onSelected: (_) => setState(() => _flowRate = v),
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pain during period?',
                style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('No'),
                      selected: !_painDuringPeriod,
                      onSelected: (_) => setState(() => _painDuringPeriod = false),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Yes'),
                      selected: _painDuringPeriod,
                      onSelected: (_) => setState(() => _painDuringPeriod = true),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pads used per day',
                style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton.filled(
                    onPressed: () =>
                        setState(() => _padsPerDay = (_padsPerDay - 1).clamp(1, 10)),
                    icon: const Icon(Icons.remove, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '$_padsPerDay',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () =>
                        setState(() => _padsPerDay = (_padsPerDay + 1).clamp(1, 10)),
                    icon: const Icon(Icons.add, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clotting?',
                style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('No'),
                      selected: !_clotting,
                      onSelected: (_) => setState(() => _clotting = false),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Yes'),
                      selected: _clotting,
                      onSelected: (_) => setState(() => _clotting = true),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weakness level',
                style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Row(
                children: ['low', 'medium', 'high'].map((v) {
                  final selected = _weaknessLevel == v;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(v),
                        selected: selected,
                        onSelected: (_) => setState(() => _weaknessLevel = v),
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepLifestyle() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diet (optional)',
            style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _dietController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'e.g. Vegetarian, high iron, supplements...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConcerns() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current health concerns (optional)',
            style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _concernController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'e.g. Irregular cycles, PMS, fatigue...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConfirmation() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review your profile',
            style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          _summaryRow('Name', _nameController.text.trim()),
          _summaryRow('Age', _ageController.text),
          _summaryRow('Cycle length', '$_cycleLength days'),
          _summaryRow('Period duration', '$_periodDuration days'),
          _summaryRow('Flow rate', _flowRate),
          _summaryRow('Pain during period', _painDuringPeriod ? 'Yes' : 'No'),
          _summaryRow('Pads per day', '$_padsPerDay'),
          _summaryRow('Clotting', _clotting ? 'Yes' : 'No'),
          _summaryRow('Weakness', _weaknessLevel),
          if (_dietController.text.trim().isNotEmpty)
            _summaryRow('Diet', _dietController.text.trim()),
          if (_concernController.text.trim().isNotEmpty)
            _summaryRow('Concerns', _concernController.text.trim()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_step + 1) / _totalSteps;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          _stepTitle,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: _step > 0
            ? IconButton(
                onPressed: _back,
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hp = ResponsiveConfig.horizontalPadding(context);
            final bottomPad = MediaQuery.paddingOf(context).bottom;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(hp, 8, hp, 16),
                  child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(hp, 8, hp, 24),
                    child: _stepContent(),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(hp, 0, hp, 8),
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(hp, 8, hp, 24 + bottomPad),
                  child: Row(
                    children: [
                      if (_step > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : _back,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                      if (_step > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: _step > 0 ? 1 : 2,
                        child: FilledButton(
                          onPressed: _saving ? null : _next,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_step == _totalSteps - 1
                                  ? 'Save & Continue'
                                  : 'Next'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
