import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../backend/services/database_service.dart';
import '../../../../core/services/ml_backend_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/diagnosis_record.dart';
import '../../../../shared/providers/app_providers.dart';
import 'analysis_result_screen.dart';

/// AI Diagnostics screen: Age & Cycle, Symptoms, Diet, Lab Reports cards,
/// Analyze Data button. Matches design reference.
class AiDiagnosticsScreen extends ConsumerStatefulWidget {
  const AiDiagnosticsScreen({super.key});

  @override
  ConsumerState<AiDiagnosticsScreen> createState() => _AiDiagnosticsScreenState();
}

class _AiDiagnosticsScreenState extends ConsumerState<AiDiagnosticsScreen>
    with TickerProviderStateMixin {
  static const _maroon = Color(0xFF6A1A21);
  static const _inputBg = Color(0xFFF5F4F2);
  static const _labelGray = Color(0xFF4B4B4B);
  bool _isAnalyzing = false;
  int _analyzingStep = 0;
  static const _analyzingMessages = [
    'Analyzing your symptoms...',
    'Processing cycle data...',
    'Generating your report...',
  ];
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;
  Timer? _analyzingStepTimer;
  final _mlService = MlBackendService();
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
  /// Selected medical PDF from file picker (path for display; extraction can use it later).
  String? _selectedPdfPath;
  String? _selectedPdfName;

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
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _analyzingStepTimer?.cancel();
    _pulseController?.dispose();
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
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8F7F5),
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: _maroon),
          onPressed: () => ref.read(navIndexProvider.notifier).state = 0,
        ),
        title: Text(
          'AI Diagnostics',
          style: AppTypography.screenTitle.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
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
            ),
          ),
        ],
      ),
          bottomSheet: _buildAnalyzeButton(),
        ),
        if (_isAnalyzing && _pulseAnimation != null) _buildAnalyzingOverlay(),
      ],
    );
  }

  Widget _buildAnalyzingOverlay() {
    final animation = _pulseAnimation!;
    return _AnalyzingOverlay(
      pulseAnimation: animation,
      step: _analyzingStep,
      messages: _analyzingMessages,
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
        _buildUploadMedicalPdfCard(),
      ],
    );
  }

  Future<void> _pickMedicalPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      if (!mounted) return;
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final name = file.name.isNotEmpty ? file.name : 'medical.pdf';
      setState(() {
        _selectedPdfPath = file.path;
        _selectedPdfName = name;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: $name'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick file: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildUploadMedicalPdfCard() {
    final hasFile = _selectedPdfName != null && _selectedPdfName!.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickMedicalPdf,
        borderRadius: BorderRadius.circular(16),
        splashColor: _maroon.withValues(alpha: 0.12),
        highlightColor: _maroon.withValues(alpha: 0.06),
        child: Container(
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
              Icon(
                hasFile ? Icons.picture_as_pdf_rounded : Icons.upload_rounded,
                color: _maroon,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                hasFile ? 'Medical PDF selected' : 'Upload Medical PDF',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _maroon,
                ),
              ),
              const SizedBox(height: 4),
              if (hasFile)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _selectedPdfName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _labelGray.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => setState(() {
                        _selectedPdfPath = null;
                        _selectedPdfName = null;
                      }),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: _maroon,
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'Tap to choose a PDF — AI will extract lab values',
                  style: TextStyle(
                    fontSize: 12,
                    color: _labelGray.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
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

  Future<void> _runPrediction() async {
    final data = _collectFormData();
    final features = formToFeatures(data);
    setState(() {
      _isAnalyzing = true;
      _analyzingStep = 0;
    });
    _analyzingStepTimer?.cancel();
    _analyzingStepTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (!mounted || !_isAnalyzing) return;
      setState(() => _analyzingStep = (_analyzingStep + 1) % _analyzingMessages.length);
    });
    try {
      final result = await _mlService.predict(features, inputData: data);
      if (!mounted) return;
      _analyzingStepTimer?.cancel();
      _analyzingStepTimer = null;
      setState(() => _isAnalyzing = false);

      final userId = ref.read(userProfileProvider)?.id;
      if (userId != null && userId.isNotEmpty) {
        try {
          await DatabaseService().insertDiagnosis(
            patientId: userId,
            inputData: data,
            prediction: result.prediction,
            probabilities: result.probabilities,
          );
          ref.invalidate(diagnosisHistoryProvider);
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Result saved locally; sync to cloud may have failed.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }

      if (!mounted) return;
      final record = DiagnosisRecord(
        prediction: result.prediction,
        probabilities: result.probabilities,
        report: result.report,
        inputData: data,
        createdAt: DateTime.now(),
      );
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AnalysisResultScreen(
            record: record,
            showInputSummary: true,
          ),
        ),
      );
    } on PredictionException catch (e) {
      if (!mounted) return;
      _analyzingStepTimer?.cancel();
      _analyzingStepTimer = null;
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('SocketException') ||
              e.toString().contains('Connection refused') ||
              e.toString().contains('Failed host lookup')
          ? 'Cannot reach analysis API. Set ML_BACKEND_URL in .env to your API base URL (e.g. https://your-api.com). Add ML_API_KEY if your API requires authentication.'
          : 'Error: $e';
      _analyzingStepTimer?.cancel();
      _analyzingStepTimer = null;
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
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
            onPressed: _isAnalyzing ? null : _runPrediction,
            style: FilledButton.styleFrom(
              backgroundColor: _maroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: _isAnalyzing
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
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
                style: AppTypography.screenTitle.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimary,
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

/// Full-screen overlay shown while analysis is running: pulse animation + cycling messages.
class _AnalyzingOverlay extends StatelessWidget {
  const _AnalyzingOverlay({
    required this.pulseAnimation,
    required this.step,
    required this.messages,
  });

  final Animation<double> pulseAnimation;
  final int step;
  final List<String> messages;

  static const _maroon = Color(0xFF6A1A21);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, _) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: pulseAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _maroon.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        size: 48,
                        color: _maroon,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_maroon),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Text(
                      messages[step.clamp(0, messages.length - 1)],
                      key: ValueKey<int>(step),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B4B4B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
