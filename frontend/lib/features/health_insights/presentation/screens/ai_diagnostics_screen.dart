import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_providers.dart';

/// AI Diagnostics screen: Age & Cycle, Symptoms, Diet, Lab Reports cards,
/// Analyze Data button. Matches design reference.
class AiDiagnosticsScreen extends ConsumerStatefulWidget {
  const AiDiagnosticsScreen({super.key});

  @override
  ConsumerState<AiDiagnosticsScreen> createState() => _AiDiagnosticsScreenState();
}

class _AiDiagnosticsScreenState extends ConsumerState<AiDiagnosticsScreen> {
  static const _maroon = Color(0xFF6A1A21);
  static const _inputBg = Color(0xFFF5F4F2);
  static const _labelGray = Color(0xFF4B4B4B);
  /// Hint/placeholder text: readable, consistent with labels
  static final _hintStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF6B6B6B),
  );
  /// Typed text in inputs: matches dropdown selected value
  static const _inputTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: _maroon,
  );
  static final _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: _labelGray.withValues(alpha: 0.12)),
  );

  int _selectedTabIndex = 0;
  int _selectedCategoryIndex = 0;
  final _dietOptions = ['Balanced Diet', 'Veg', 'Junk Food', 'Irregular Meals'];

  // Age & Cycle
  final _currentAgeController = TextEditingController();
  final _ageAtFirstPeriodController = TextEditingController();
  final _cycleLengthController = TextEditingController();
  final _periodDurationController = TextEditingController();
  String? _regularity;
  String? _missedPeriod;

  // Symptoms
  String? _flowRate;
  final _padsPerDayController = TextEditingController();
  String? _bloodClots;
  String? _painLevel;
  int _weaknessDizzinessIndex = 0; // 0 = No, 1 = Yes
  final _otherSymptomsController = TextEditingController();

  // Lab (manual)
  final _hemoglobinController = TextEditingController();

  static const _regularityOptions = ['Regular', 'Irregular', 'Very Irregular'];
  static const _missedPeriodOptions = ['No', 'Yes'];
  static const _flowRateOptions = ['Light', 'Medium', 'Heavy'];
  static const _bloodClotsOptions = ['None', 'Few', 'Many'];
  static const _painLevelOptions = ['No Pain', 'Mild', 'Moderate', 'Severe'];

  @override
  void initState() {
    super.initState();
    _regularity = _regularityOptions.first;
    _missedPeriod = _missedPeriodOptions.first;
    _flowRate = _flowRateOptions.first;
    _bloodClots = _bloodClotsOptions.first;
    _painLevel = _painLevelOptions.first;
  }

  @override
  void dispose() {
    _currentAgeController.dispose();
    _ageAtFirstPeriodController.dispose();
    _cycleLengthController.dispose();
    _periodDurationController.dispose();
    _padsPerDayController.dispose();
    _otherSymptomsController.dispose();
    _hemoglobinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: _maroon),
          onPressed: () => ref.read(navIndexProvider.notifier).state = 0,
        ),
        title: const Text(
          'AI Diagnostics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _maroon,
          ),
        ),
        centerTitle: true,
        actions: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _inputBg,
            child: Icon(Icons.person_outline_rounded, color: _maroon, size: 22),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Tabs: AI Diagnostics | Comprehensive Data
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _TabChip(
                  label: 'AI Diagnostics',
                  isActive: _selectedTabIndex == 0,
                  onTap: () => setState(() => _selectedTabIndex = 0),
                ),
                const SizedBox(width: 16),
                _TabChip(
                  label: 'Comprehensive Data',
                  isActive: _selectedTabIndex == 1,
                  onTap: () => setState(() => _selectedTabIndex = 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedTabIndex == 0
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    children: [
                      _SectionCard(
                        icon: Icons.calendar_today_rounded,
                        title: 'Age & Cycle',
                        child: _buildAgeCycleFields(),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        icon: Icons.favorite_rounded,
                        title: 'Symptoms',
                        child: _buildSymptomsFields(),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        icon: Icons.restaurant_rounded,
                        title: 'Diet',
                        child: _buildDietChips(),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        icon: Icons.biotech_rounded,
                        title: 'Lab Reports',
                        child: _buildLabUpload(),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    children: [
                      _SectionCard(
                      icon: Icons.dataset_rounded,
                      title: 'Comprehensive Data',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Additional comprehensive health data entry will be available here.',
                          style: TextStyle(
                            fontSize: 14,
                            color: _labelGray.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ),
                    ],
                  ),
          ),
        ],
      ),
      bottomSheet: _buildAnalyzeButton(),
    );
  }

  Widget _buildAgeCycleFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _twoColumnRow(
          left: _field(
            label: 'Current Age',
            hint: 'Years',
            controller: _currentAgeController,
            keyboardType: TextInputType.number,
          ),
          right: _field(
            label: 'Age at First Period',
            hint: 'Years',
            controller: _ageAtFirstPeriodController,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 12),
        _twoColumnRow(
          left: _field(
            label: 'Cycle Length',
            hint: 'Days',
            controller: _cycleLengthController,
            keyboardType: TextInputType.number,
          ),
          right: _field(
            label: 'Period Duration',
            hint: 'Days',
            controller: _periodDurationController,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 12),
        _twoColumnRow(
          left: _dropdown(
            label: 'Regularity',
            value: _regularity,
            options: _regularityOptions,
            onSelected: (v) => setState(() => _regularity = v),
          ),
          right: _dropdown(
            label: 'Missed Period',
            value: _missedPeriod,
            options: _missedPeriodOptions,
            onSelected: (v) => setState(() => _missedPeriod = v),
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _twoColumnRow(
          left: _dropdown(
            label: 'Flow Rate',
            value: _flowRate,
            options: _flowRateOptions,
            onSelected: (v) => setState(() => _flowRate = v),
          ),
          right: _field(
            label: 'Pads per Day',
            hint: 'Count',
            controller: _padsPerDayController,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 12),
        _twoColumnRow(
          left: _dropdown(
            label: 'Blood Clots',
            value: _bloodClots,
            options: _bloodClotsOptions,
            onSelected: (v) => setState(() => _bloodClots = v),
          ),
          right: _dropdown(
            label: 'Pain Level',
            value: _painLevel,
            options: _painLevelOptions,
            onSelected: (v) => setState(() => _painLevel = v),
          ),
        ),
        const SizedBox(height: 12),
        _toggleRow(
          'Weakness/Dizziness',
          ['No', 'Yes'],
          _weaknessDizzinessIndex,
          (i) => setState(() => _weaknessDizzinessIndex = i),
        ),
        const SizedBox(height: 12),
        const Text(
          'Other Symptoms',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _labelGray,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _otherSymptomsController,
          maxLines: 3,
          minLines: 3,
          style: _inputTextStyle,
          cursorColor: _maroon,
          decoration: InputDecoration(
            hintText: 'Describe any other concerns...',
            hintStyle: _hintStyle,
            filled: true,
            fillColor: _inputBg,
            contentPadding: const EdgeInsets.all(14),
            border: _inputBorder,
            enabledBorder: _inputBorder,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _maroon.withValues(alpha: 0.5), width: 1.5),
            ),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDietChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          _dietOptions.length,
          (i) => Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(_dietOptions[i]),
              selected: _selectedCategoryIndex == i,
              onSelected: (v) => setState(() => _selectedCategoryIndex = i),
              selectedColor: _maroon,
              labelStyle: TextStyle(
                color: _selectedCategoryIndex == i ? Colors.white : _maroon,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              backgroundColor: _inputBg,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Hemoglobin (g/dL)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _labelGray,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Manual Input',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _maroon,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _hemoglobinController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: _inputTextStyle,
          cursorColor: _maroon,
          decoration: InputDecoration(
            hintText: 'e.g. 12.5',
            hintStyle: _hintStyle,
            filled: true,
            fillColor: _inputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: _inputBorder,
            enabledBorder: _inputBorder,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _maroon.withValues(alpha: 0.5), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _maroon.withValues(alpha: 0.3),
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.upload_rounded, color: _maroon, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Upload Medical PDF',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _maroon,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'AI will extract lab values automatically',
                style: TextStyle(
                  fontSize: 12,
                  color: _labelGray.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _collectFormData() {
    return {
      'currentAge': _currentAgeController.text.trim(),
      'ageAtFirstPeriod': _ageAtFirstPeriodController.text.trim(),
      'cycleLength': _cycleLengthController.text.trim(),
      'periodDuration': _periodDurationController.text.trim(),
      'regularity': _regularity ?? _regularityOptions.first,
      'missedPeriod': _missedPeriod ?? _missedPeriodOptions.first,
      'flowRate': _flowRate ?? _flowRateOptions.first,
      'padsPerDay': _padsPerDayController.text.trim(),
      'bloodClots': _bloodClots ?? _bloodClotsOptions.first,
      'painLevel': _painLevel ?? _painLevelOptions.first,
      'weaknessDizziness': _weaknessDizzinessIndex == 1 ? 'Yes' : 'No',
      'otherSymptoms': _otherSymptomsController.text.trim(),
      'diet': _dietOptions[_selectedCategoryIndex],
      'hemoglobin': _hemoglobinController.text.trim(),
    };
  }

  Widget _twoColumnRow({required Widget left, required Widget right}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _labelGray,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: _inputTextStyle,
          cursorColor: _maroon,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: _hintStyle,
            filled: true,
            fillColor: _inputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: _inputBorder,
            enabledBorder: _inputBorder,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _maroon.withValues(alpha: 0.5), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _labelGray.withValues(alpha: 0.2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onSelected,
  }) {
    final display = value ?? options.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _labelGray,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () {
            showModalBottomSheet<String>(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (ctx) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options
                        .map(
                          (o) => ListTile(
                            title: Text(
                              o,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _maroon,
                              ),
                            ),
                            selected: value == o,
                            onTap: () {
                              onSelected(o);
                              Navigator.pop(ctx, o);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: _inputBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _labelGray.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  display,
                  style: _inputTextStyle,
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: _maroon, size: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggleRow(
    String label,
    List<String> options,
    int selected,
    ValueChanged<int> onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _labelGray,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            options.length,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FilterChip(
                label: Text(options[i]),
                selected: selected == i,
                onSelected: (_) => onSelected(i),
                selectedColor: _maroon,
                labelStyle: TextStyle(
                  color: selected == i ? Colors.white : _maroon,
                  fontSize: 13,
                ),
                backgroundColor: _inputBg,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      color: const Color(0xFFF8F7F5),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: () {
              final data = _collectFormData();
              // TODO: send to Supabase when keys are provided
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Data collected. ${data.length} fields ready for analysis.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: _maroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Analyze Data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.auto_awesome, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  static const _maroon = Color(0xFF6A1A21);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? _maroon : _maroon.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 80,
            height: 3,
            decoration: BoxDecoration(
              color: isActive ? _maroon : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  static const _maroon = Color(0xFF6A1A21);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _maroon, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _maroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
