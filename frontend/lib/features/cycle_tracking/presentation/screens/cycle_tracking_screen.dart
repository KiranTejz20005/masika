import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/providers/cycle_provider.dart';
import 'cycle_log_screen.dart';

/// Period Calendar: pixel-perfect per reference — deep reddish-maroon accent, reddish-pink fertile, light gray inactive.
const _maroon = Color(0xFF8B002B);
const _periodDot = Color(0xFF8B002B);
const _fertileDot = Color(0xFFFFC0CB);
const _bg = Color(0xFFF5F5F5);
const _cardBg = Color(0xFFFFFFFF);
const _textDark = Color(0xFF333333);
const _textMuted = Color(0xFF6B6B6B);
const _inactiveGray = Color(0xFFBDBDBD);

class CycleTrackingScreen extends ConsumerStatefulWidget {
  const CycleTrackingScreen({super.key});

  @override
  ConsumerState<CycleTrackingScreen> createState() =>
      _CycleTrackingScreenState();
}

class _CycleTrackingScreenState extends ConsumerState<CycleTrackingScreen> {
  DateTime _displayMonth;
  DateTime? _selectedDate;
  int _selectedSymptomIndex = 2; // Cramps selected by default

  _CycleTrackingScreenState()
      : _displayMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  bool _isPeriodDay(DateTime day) {
    final logs = ref.read(cycleLogsProvider);
    for (final log in logs) {
      final start = DateTime(log.startDate.year, log.startDate.month, log.startDate.day);
      final end = DateTime(log.endDate.year, log.endDate.month, log.endDate.day);
      final d = DateTime(day.year, day.month, day.day);
      if ((d.isAfter(start) || d.isAtSameMomentAs(start)) &&
          (d.isBefore(end) || d.isAtSameMomentAs(end))) {
        return true;
      }
    }
    return false;
  }

  bool _isFertileDay(DateTime day) {
    final logs = ref.read(cycleLogsProvider);
    if (logs.isEmpty) return false;
    final sorted = List.from(logs)..sort((a, b) => b.startDate.compareTo(a.startDate));
    final lastStart = sorted.first.startDate;
    final cycleLength = sorted.first.cycleLengthDays;
    final ovulationDay = (cycleLength * 0.5).round();
    final fertileStart = lastStart.add(Duration(days: ovulationDay - 5));
    final fertileEnd = lastStart.add(Duration(days: ovulationDay + 1));
    final d = DateTime(day.year, day.month, day.day);
    final fStart = DateTime(fertileStart.year, fertileStart.month, fertileStart.day);
    final fEnd = DateTime(fertileEnd.year, fertileEnd.month, fertileEnd.day);
    return (d.isAfter(fStart) || d.isAtSameMomentAs(fStart)) &&
        (d.isBefore(fEnd) || d.isAtSameMomentAs(fEnd));
  }

  /// Demo period/fertile for displayed month when no logs (match reference October 2023).
  Set<int> _getDemoPeriodDays() {
    if (_displayMonth.month == 10 && _displayMonth.year == 2023) {
      return {1, 2, 3, 4, 5, 8, 9, 10, 30, 31};
    }
    return {};
  }

  Set<int> _getDemoFertileDays() {
    if (_displayMonth.month == 10 && _displayMonth.year == 2023) {
      return {13, 14, 16, 17, 18, 19, 20, 21};
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final cycleData = ref.watch(cycleDataProvider);
    final logs = ref.watch(cycleLogsProvider);
    final hasData = logs.isNotEmpty;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _inactiveGray.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.chevron_left_rounded, color: _maroon, size: 24),
          ),
          onPressed: () =>
              ref.read(navIndexProvider.notifier).state = 0,
        ),
        title: Text(
          'Period Calendar',
          style: AppTypography.screenTitle.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: _inactiveGray, size: 24),
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _displayMonth = DateTime(now.year, now.month);
                _selectedDate = now;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMonthNav(),
            const SizedBox(height: 16),
            _buildCalendarCard(hasData),
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 20),
            _buildCurrentCycleCard(cycleData),
            const SizedBox(height: 24),
            _buildDailySymptoms(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthNav() {
    final monthYear =
        '${_monthName(_displayMonth.month)} ${_displayMonth.year}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          monthYear,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, color: _inactiveGray),
              onPressed: () {
                setState(() {
                  _displayMonth = DateTime(
                    _displayMonth.year,
                    _displayMonth.month - 1,
                  );
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, color: _inactiveGray),
              onPressed: () {
                setState(() {
                  _displayMonth = DateTime(
                    _displayMonth.year,
                    _displayMonth.month + 1,
                  );
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  String _monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month - 1];
  }

  Widget _buildCalendarCard(bool hasLogs) {
    final demoPeriod = _getDemoPeriodDays();
    final demoFertile = _getDemoFertileDays();
    final first = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final last = DateTime(_displayMonth.year, _displayMonth.month + 1, 0);
    final daysInMonth = last.day;
    final firstWeekday = first.weekday % 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => SizedBox(
                      width: 36,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textMuted,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final dayWidth = (constraints.maxWidth - 0) / 7;
              final rows = <Widget>[];
              var day = 1;
              var rowCells = <Widget>[];
              for (var i = 0; i < firstWeekday; i++) {
                rowCells.add(SizedBox(width: dayWidth, height: 40));
              }
              while (day <= daysInMonth) {
                final d = day;
                final date = DateTime(
                    _displayMonth.year, _displayMonth.month, d);
                final isPeriod = hasLogs
                    ? _isPeriodDay(date)
                    : demoPeriod.contains(d);
                final isFertile = hasLogs
                    ? _isFertileDay(date)
                    : demoFertile.contains(d);
                final isSelected = _selectedDate != null &&
                    _selectedDate!.year == date.year &&
                    _selectedDate!.month == date.month &&
                    _selectedDate!.day == date.day;

                rowCells.add(
                  SizedBox(
                    width: dayWidth,
                    height: 44,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedDate = date),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: _maroon,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$d',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? _maroon
                                    : _textDark,
                              ),
                            ),
                          ),
                          if (isPeriod || isFertile)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isPeriod)
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: const BoxDecoration(
                                        color: _periodDot,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  if (isPeriod && isFertile)
                                    const SizedBox(width: 2),
                                  if (isFertile)
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: const BoxDecoration(
                                        color: _fertileDot,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
                day++;
                if (rowCells.length == 7) {
                  rows.add(Row(children: rowCells));
                  rowCells = [];
                }
              }
              if (rowCells.isNotEmpty) {
                while (rowCells.length < 7) {
                  rowCells.add(SizedBox(width: dayWidth, height: 44));
                }
                rows.add(Row(children: rowCells));
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: rows,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _periodDot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'PERIOD',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _fertileDot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'FERTILE WINDOW',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentCycleCard(CycleData cycleData) {
    final cycleDay = cycleData.cycleDay;
    final cycleLength = cycleData.cycleLength;
    final isFertile = cycleData.phase == 'ovulation' ||
        cycleData.phase == 'follicular' && cycleDay >= 10;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _maroon,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _maroon.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Cycle',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Day $cycleDay',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ $cycleLength days',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                if (isFertile) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'High chance of pregnancy',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySymptoms() {
    const labels = ['Happy', 'Medium', 'Cramps', 'Add'];
    const icons = [
      Icons.sentiment_very_satisfied_rounded,
      Icons.water_drop_rounded,
      Icons.bolt_rounded,
      Icons.add_rounded,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daily Symptoms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CycleLogScreen()),
              ),
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _maroon,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (i) {
            final label = labels[i];
            final icon = icons[i];
            final isAdd = i == 3;
            final isSelected = i == _selectedSymptomIndex && !isAdd;
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (isAdd) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CycleLogScreen()),
                      );
                    } else {
                      setState(() => _selectedSymptomIndex = i);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isAdd ? Colors.transparent : _cardBg,
                      shape: BoxShape.circle,
                      border: isAdd
                          ? Border.all(
                              color: _inactiveGray,
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignInside,
                            )
                          : null,
                      boxShadow: isAdd
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: isAdd
                        ? const Icon(Icons.add, color: _textMuted, size: 28)
                        : Icon(
                            icon,
                            size: 26,
                            color: isSelected ? _maroon : _textMuted,
                          ),
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    height: 3,
                    width: 40,
                    decoration: BoxDecoration(
                      color: _fertileDot,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isAdd ? _textMuted : _textDark,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
