import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/user_health_profile.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../dashboard/presentation/screens/dashboard_shell.dart';

/// Multi-step health data form shown after onboarding when no health profile exists.
/// Also used from Profile → Health Profile in edit mode (pop on save).
class HealthOnboardingScreen extends ConsumerStatefulWidget {
  const HealthOnboardingScreen({
    super.key,
    this.initialProfile,
    this.isEditMode = false,
  });

  /// When set (e.g. from Profile), form is pre-filled and on save we pop instead of going to home.
  final UserHealthProfile? initialProfile;
  final bool isEditMode;

  @override
  ConsumerState<HealthOnboardingScreen> createState() =>
      _HealthOnboardingScreenState();
}

class _HealthOnboardingScreenState extends ConsumerState<HealthOnboardingScreen> {
  static const _totalSteps = 5;
  int _step = 0;
  bool _saving = false;
  String? _errorMessage;

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
    final p = widget.initialProfile;
    if (p != null) {
      _cycleLength = p.cycleLength;
      _periodDuration = p.periodDuration;
      _flowRate = p.flowRate;
      _painDuringPeriod = p.painDuringPeriod;
      _padsPerDay = p.padsPerDay;
      _clotting = p.clotting;
      _weaknessLevel = p.weaknessLevel;
      _dietController.text = p.dietDescription;
      _concernController.text = p.healthConcernDescription;
    }
  }

  @override
  void dispose() {
    _dietController.dispose();
    _concernController.dispose();
    super.dispose();
  }

  UserHealthProfile _buildProfile() {
    final userId = ref.read(userProfileProvider)?.id ?? '';
    return UserHealthProfile(
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
  }

  bool _validateStep() {
    _errorMessage = null;
    if (_step == 0) {
      if (_cycleLength < 21 || _cycleLength > 45) {
        _errorMessage = 'Cycle length is usually between 21 and 45 days';
        return false;
      }
      if (_periodDuration < 1 || _periodDuration > 10) {
        _errorMessage = 'Period duration is usually 1–10 days';
        return false;
      }
    }
    if (_step == 1) {
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
    final profile = _buildProfile();
    final userId = ref.read(userProfileProvider)?.id ?? '';
    if (userId.isEmpty) {
      setState(() {
        _errorMessage = 'Please sign in first';
        _saving = false;
      });
      return;
    }
    await ref.read(healthProfileProvider.notifier).setHealthProfile(profile);
    if (!mounted) return;
    setState(() => _saving = false);
    if (widget.isEditMode) {
      Navigator.of(context).pop();
      return;
    }
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
        leading: _step > 0 || widget.isEditMode
            ? IconButton(
                onPressed: _step > 0
                    ? _back
                    : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
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
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: _stepContent(),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  _errorMessage!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
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
                          : Text(_step == _totalSteps - 1 ? 'Save & Continue' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _stepTitle {
    switch (_step) {
      case 0:
        return 'Cycle basics';
      case 1:
        return 'Symptoms';
      case 2:
        return 'Lifestyle';
      case 3:
        return 'Concerns';
      case 4:
        return 'Confirm';
      default:
        return 'Health profile';
    }
  }

  Widget _stepContent() {
    switch (_step) {
      case 0:
        return _buildStepCycleBasics();
      case 1:
        return _buildStepSymptoms();
      case 2:
        return _buildStepLifestyle();
      case 3:
        return _buildStepConcerns();
      case 4:
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

  Widget _buildStepCycleBasics() {
    final age = ref.watch(userProfileProvider)?.age;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (age != null && age > 0)
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Age', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('$age years', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
              ],
            ),
          ),
        const SizedBox(height: 16),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cycle length (days)', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton.filled(
                    onPressed: () => setState(() => _cycleLength = (_cycleLength - 1).clamp(21, 45)),
                    icon: const Icon(Icons.remove, size: 20),
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.12), foregroundColor: AppColors.primary),
                  ),
                  Expanded(
                    child: Text(
                      '$_cycleLength',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () => setState(() => _cycleLength = (_cycleLength + 1).clamp(21, 45)),
                    icon: const Icon(Icons.add, size: 20),
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.12), foregroundColor: AppColors.primary),
                  ),
                ],
              ),
              Text('Typically 21–45 days', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Period duration (days)', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton.filled(
                    onPressed: () => setState(() => _periodDuration = (_periodDuration - 1).clamp(1, 10)),
                    icon: const Icon(Icons.remove, size: 20),
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.12), foregroundColor: AppColors.primary),
                  ),
                  Expanded(
                    child: Text(
                      '$_periodDuration',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () => setState(() => _periodDuration = (_periodDuration + 1).clamp(1, 10)),
                    icon: const Icon(Icons.add, size: 20),
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.12), foregroundColor: AppColors.primary),
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
              Text('Flow rate', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
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
              Text('Pain during period?', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
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
              Text('Pads used per day', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton.filled(
                    onPressed: () => setState(() => _padsPerDay = (_padsPerDay - 1).clamp(1, 10)),
                    icon: const Icon(Icons.remove, size: 20),
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.12), foregroundColor: AppColors.primary),
                  ),
                  Expanded(
                    child: Text('$_padsPerDay', textAlign: TextAlign.center, style: AppTypography.headlineSmall.copyWith(color: AppColors.primary)),
                  ),
                  IconButton.filled(
                    onPressed: () => setState(() => _padsPerDay = (_padsPerDay + 1).clamp(1, 10)),
                    icon: const Icon(Icons.add, size: 20),
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.12), foregroundColor: AppColors.primary),
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
              Text('Clotting?', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
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
              Text('Weakness level', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
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
          Text('Diet (optional)', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
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
          Text('Current health concerns (optional)', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
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

  Widget _buildStepConfirmation() {
    final p = _buildProfile();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review your health profile', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _row('Cycle length', '${p.cycleLength} days'),
          _row('Period duration', '${p.periodDuration} days'),
          _row('Flow rate', p.flowRate),
          _row('Pain during period', p.painDuringPeriod ? 'Yes' : 'No'),
          _row('Pads per day', '${p.padsPerDay}'),
          _row('Clotting', p.clotting ? 'Yes' : 'No'),
          _row('Weakness', p.weaknessLevel),
          if (p.dietDescription.isNotEmpty) _row('Diet', p.dietDescription),
          if (p.healthConcernDescription.isNotEmpty) _row('Concerns', p.healthConcernDescription),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
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
}
