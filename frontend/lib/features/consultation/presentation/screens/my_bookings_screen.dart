import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/appointment.dart';
import '../../../../shared/providers/app_providers.dart';

const _maroon = Color(0xFF8D2D3B);
const _bg = Color(0xFFF8F7F5);
const _cardBg = Color(0xFFFFFFFF);
const _titleColor = Color(0xFF1A1A1A);
const _subtitleGray = Color(0xFF6B6B6B);
const _starOrange = Color(0xFFFF9800);

/// My Bookings: list of upcoming and past appointments. Tap to see details.
class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentsProvider);
    final upcoming = appointments.where((a) => a.isUpcoming).toList();
    final past = appointments.where((a) => a.isPast).toList();
    // Sort upcoming by date then slot, past by date descending
    upcoming.sort((a, b) => a.bookedAt.compareTo(b.bookedAt));
    past.sort((a, b) => b.bookedAt.compareTo(a.bookedAt));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _maroon, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Bookings',
          style: AppTypography.screenTitle.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (upcoming.isNotEmpty) ...[
            _sectionHeader('Upcoming'),
            const SizedBox(height: 8),
            ...upcoming.map((a) => _BookingCard(
                  appointment: a,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingDetailScreen(appointment: a),
                    ),
                  ),
                )),
            const SizedBox(height: 24),
          ],
          _sectionHeader('Past'),
          const SizedBox(height: 8),
          if (past.isEmpty && upcoming.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Text(
                  'No bookings yet. Book a consultation from Masika Specialists.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: _subtitleGray, height: 1.5),
                ),
              ),
            )
          else if (past.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'No past bookings.',
                style: TextStyle(fontSize: 14, color: _subtitleGray),
              ),
            )
          else
            ...past.map((a) => _BookingCard(
                  appointment: a,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingDetailScreen(appointment: a),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _titleColor,
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.appointment, required this.onTap});

  final Appointment appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(appointment.bookedAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: appointment.doctorImageUrl != null && appointment.doctorImageUrl!.isNotEmpty
                      ? Image.network(
                          appointment.doctorImageUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderAvatar(),
                        )
                      : _placeholderAvatar(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (appointment.doctorSpecialty.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          appointment.doctorSpecialty,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _maroon,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '${appointment.timeSlot} · $dateStr',
                        style: TextStyle(
                          fontSize: 13,
                          color: _subtitleGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _maroon, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderAvatar() {
    return Container(
      width: 56,
      height: 56,
      color: const Color(0xFFF5F3F4),
      child: const Icon(Icons.person_rounded, size: 28, color: _maroon),
    );
  }
}

/// Booking detail: doctor profile (photo, name, specialty, rating) and timing.
class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.appointment});

  final Appointment appointment;

  static Widget _placeholderAvatar() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFF5F3F4),
      child: const Icon(Icons.person_rounded, size: 40, color: _maroon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(appointment.bookedAt);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _maroon, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Booking details',
          style: AppTypography.screenTitle.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: appointment.doctorImageUrl != null && appointment.doctorImageUrl!.isNotEmpty
                        ? Image.network(
                            appointment.doctorImageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => BookingDetailScreen._placeholderAvatar(),
                          )
                        : BookingDetailScreen._placeholderAvatar(),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctorName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _titleColor,
                          ),
                        ),
                        if (appointment.doctorSpecialty.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            appointment.doctorSpecialty,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _maroon,
                            ),
                          ),
                        ],
                        if (appointment.doctorRating != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 18, color: _starOrange),
                              const SizedBox(width: 4),
                              Text(
                                '${appointment.doctorRating}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _titleColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date & time',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _subtitleGray,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    appointment.timeSlot,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _maroon,
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
}
