import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/app_providers.dart';

const _bg = Color(0xFFF8F7F5);
const _maroon = Color(0xFF8B002B);

/// Sample booking dates for demo (year, month, day).
final _bookingDates = <DateTime>{
  DateTime(2026, 2, 9),
  DateTime(2026, 2, 10),
  DateTime(2026, 2, 12),
  DateTime(2026, 2, 15),
  DateTime(2026, 2, 18),
  DateTime(2026, 2, 22),
  DateTime(2026, 2, 25),
};

/// Sample bookings for selected day (time, patient, reason).
List<({String time, String patient, String reason})> _bookingsFor(DateTime day) {
  final key = DateTime(day.year, day.month, day.day);
  if (key == DateTime(2026, 2, 9)) {
    return [
      (time: '10:30 AM', patient: 'Elena Rodriguez', reason: 'Persistent Pelvic Pain'),
      (time: '11:15 AM', patient: 'Maya Thompson', reason: 'Cycle Irregularity'),
    ];
  }
  if (key == DateTime(2026, 2, 10)) {
    return [(time: '9:00 AM', patient: 'Priya Sharma', reason: 'Follow-up')];
  }
  if (key == DateTime(2026, 2, 12)) {
    return [(time: '2:00 PM', patient: 'Sophia Williams', reason: 'Consultation')];
  }
  return [];
}

class DoctorCalendarScreen extends ConsumerStatefulWidget {
  const DoctorCalendarScreen({super.key});

  @override
  ConsumerState<DoctorCalendarScreen> createState() => _DoctorCalendarScreenState();
}

class _DoctorCalendarScreenState extends ConsumerState<DoctorCalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _selectedDay = DateTime.now();
  }

  bool _hasBooking(DateTime d) {
    return _bookingDates.contains(DateTime(d.year, d.month, d.day));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _maroon, size: 20),
          onPressed: () => ref.read(doctorNavIndexProvider.notifier).state = 0,
        ),
        title: Text(
          'Calendar',
          style: AppTypography.screenTitle.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMonthNav(),
              const SizedBox(height: 16),
              _buildWeekdayHeaders(),
              const SizedBox(height: 8),
              _buildCalendarGrid(),
              if (_selectedDay != null) ...[
                const SizedBox(height: 24),
                _buildBookingsSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthNav() {
    final monthName = _monthName(_focusedMonth);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            });
          },
          color: _maroon,
        ),
        Text(
          monthName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, size: 28),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            });
          },
          color: _maroon,
        ),
      ],
    );
  }

  String _monthName(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  Widget _buildWeekdayHeaders() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: List.generate(7, (i) {
        return Expanded(
          child: Center(
            child: Text(
              days[i],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCalendarGrid() {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final first = DateTime(year, month, 1);
    final last = DateTime(year, month + 1, 0);
    final firstWeekday = first.weekday; // 1 = Mon, 7 = Sun
    final daysInMonth = last.day;
    final leadingEmpty = firstWeekday - 1;
    final totalCells = leadingEmpty + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final index = row * 7 + col;
              if (index < leadingEmpty) {
                return const Expanded(child: SizedBox(height: 44));
              }
              final day = index - leadingEmpty + 1;
              if (day > daysInMonth) {
                return const Expanded(child: SizedBox(height: 44));
              }
              final date = DateTime(year, month, day);
              final isSelected = _selectedDay != null &&
                  _selectedDay!.year == year &&
                  _selectedDay!.month == month &&
                  _selectedDay!.day == day;
              final hasBooking = _hasBooking(date);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _selectedDay = date),
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? _maroon : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1A1A1A),
                              ),
                            ),
                            if (hasBooking)
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : _maroon,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildBookingsSection() {
    final bookings = _bookingsFor(_selectedDay!);
    if (bookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'No bookings on ${_selectedDay!.day} ${_monthName(_focusedMonth).split(' ')[0]}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bookings — ${_selectedDay!.day} ${_monthName(_focusedMonth).split(' ')[0]}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B6B6B),
          ),
        ),
        const SizedBox(height: 12),
        ...bookings.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _maroon.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        b.time,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _maroon,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.patient,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            b.reason,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
