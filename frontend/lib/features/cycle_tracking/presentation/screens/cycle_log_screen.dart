import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/cycle_log.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/providers/cycle_provider.dart';

class CycleLogScreen extends ConsumerStatefulWidget {
  const CycleLogScreen({super.key});

  @override
  ConsumerState<CycleLogScreen> createState() => _CycleLogScreenState();
}

class _CycleLogScreenState extends ConsumerState<CycleLogScreen>
    with SingleTickerProviderStateMixin {
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _mood = 'calm';
  String _flow = 'medium';
  final _symptoms = <String>{};
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  final _moodOptions = [
    {'value': 'happy', 'icon': Icons.sentiment_very_satisfied_rounded, 'label': 'Happy'},
    {'value': 'calm', 'icon': Icons.sentiment_satisfied_rounded, 'label': 'Calm'},
    {'value': 'irritable', 'icon': Icons.sentiment_dissatisfied_rounded, 'label': 'Irritable'},
    {'value': 'low', 'icon': Icons.sentiment_very_dissatisfied_rounded, 'label': 'Low'},
    {'value': 'anxious', 'icon': Icons.psychology_rounded, 'label': 'Anxious'},
  ];

  final _flowOptions = [
    {'value': 'spotting', 'label': 'Spotting', 'color': const Color(0xFFFFCDD2)},
    {'value': 'light', 'label': 'Light', 'color': const Color(0xFFEF9A9A)},
    {'value': 'medium', 'label': 'Medium', 'color': const Color(0xFFE57373)},
    {'value': 'heavy', 'label': 'Heavy', 'color': const Color(0xFFC62828)},
  ];

  final _symptomOptions = [
    'Cramps', 'Headache', 'Bloating', 'Fatigue',
    'Back Pain', 'Breast Tenderness', 'Mood Swings',
    'Nausea', 'Acne', 'Insomnia',
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    HapticFeedback.lightImpact();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDate: isStart ? _startDate : (_endDate ?? _startDate.add(const Duration(days: 4))),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B1538),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (selected == null) return;
    if (!mounted) return;
    setState(() {
      if (isStart) {
        _startDate = selected;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      } else {
        _endDate = selected;
      }
    });
  }

  void _save() {
    HapticFeedback.mediumImpact();
    final end = _endDate ?? _startDate.add(const Duration(days: 4));
    final log = CycleLog(
      id: const Uuid().v4(),
      startDate: _startDate,
      endDate: end,
      cycleLengthDays: end.difference(_startDate).inDays + 1,
      symptoms: _symptoms.toList(),
      mood: _mood,
      flow: _flow,
    );
    ref.read(cycleLogsProvider.notifier).add(log);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Text('Period logged successfully!', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      backgroundColor: const Color(0xFF8B1538),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 2),
    ));

    Navigator.pop(context);
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cycle = ref.watch(cycleDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F9),
      appBar: AppBar(
        title: Text(
          'Log Period',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
        ),
        backgroundColor: const Color(0xFFFAF8F9),
        elevation: 0,
        foregroundColor: const Color(0xFF1A1A1A),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            // ── Cycle Status Banner ──
            if (cycle.hasData) _buildCycleStatus(cycle),
            if (cycle.hasData) const SizedBox(height: 20),

            // ── Date Selection ──
            _sectionTitle('Period Dates', Icons.calendar_month_rounded),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _dateCard('Start Date', _startDate, true)),
                const SizedBox(width: 12),
                Expanded(child: _dateCard('End Date', _endDate, false)),
              ],
            ),
            const SizedBox(height: 24),

            // ── Flow Intensity ──
            _sectionTitle('Flow Intensity', Icons.water_drop_rounded),
            const SizedBox(height: 12),
            Row(
              children: _flowOptions.map((opt) {
                final selected = _flow == opt['value'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _flow = opt['value'] as String);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF8B1538) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? const Color(0xFF8B1538) : const Color(0xFFE8E8E8),
                          width: selected ? 2 : 1,
                        ),
                        boxShadow: selected
                            ? [BoxShadow(color: const Color(0xFF8B1538).withValues(alpha: 0.2), blurRadius: 8)]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: selected ? Colors.white : (opt['color'] as Color),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            opt['label'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : const Color(0xFF555555),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Mood ──
            _sectionTitle('How are you feeling?', Icons.emoji_emotions_rounded),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: _moodOptions.map((opt) {
                  final selected = _mood == opt['value'];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _mood = opt['value'] as String);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 72,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFFFFF0F4) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? const Color(0xFF8B1538) : const Color(0xFFE8E8E8),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            opt['icon'] as IconData,
                            size: 28,
                            color: selected ? const Color(0xFF8B1538) : Colors.grey[400],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            opt['label'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: selected ? const Color(0xFF8B1538) : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // ── Symptoms ──
            _sectionTitle('Symptoms', Icons.healing_rounded),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _symptomOptions.map((s) {
                final selected = _symptoms.contains(s);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (selected) {
                        _symptoms.remove(s);
                      } else {
                        _symptoms.add(s);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF8B1538) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? const Color(0xFF8B1538) : const Color(0xFFE8E8E8),
                      ),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : const Color(0xFF555555),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 36),

            // ── Save Button ──
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1538),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  shadowColor: const Color(0xFF8B1538).withValues(alpha: 0.3),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Save Period Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleStatus(CycleData cycle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFEEDDFB), Color(0xFFF5EEFF)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF8B1538).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '${cycle.cycleDay}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF8B1538)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${cycle.cycleDay} · ${cycle.phaseLabel} Phase',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 3),
                Text(
                  cycle.daysUntilNextPeriod > 0
                      ? 'Next period in ${cycle.daysUntilNextPeriod} days'
                      : 'Period may be due now',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF8B1538)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
        ),
      ],
    );
  }

  Widget _dateCard(String label, DateTime? date, bool isStart) {
    return GestureDetector(
      onTap: () => _pickDate(isStart: isStart),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[500]),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    date != null ? _formatDate(date) : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: date != null ? const Color(0xFF1A1A1A) : Colors.grey[400],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.edit_calendar_rounded, size: 16, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
