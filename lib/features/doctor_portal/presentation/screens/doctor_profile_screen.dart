import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_providers.dart';
import '../../../auth/presentation/screens/welcome_screen.dart';

const _maroon = Color(0xFF6C102C);
const _bg = Color(0xFFF8F7F5);

class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = ref.watch(doctorProfileProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          const SizedBox(height: 12),
          _buildAvatar(doctor?.name),
          const SizedBox(height: 16),
          Center(
            child: Text(
              doctor?.name ?? 'Doctor',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              doctor?.email ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B6B6B),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _sectionTitle('Doctor details'),
          const SizedBox(height: 12),
          _DetailsCard(
            items: [
              _DetailRow(label: 'Full name', value: doctor?.name ?? '—'),
              _DetailRow(label: 'Email', value: doctor?.email ?? '—'),
              _DetailRow(label: 'Phone', value: _empty(doctor?.phone)),
              _DetailRow(label: 'Specialty', value: _empty(doctor?.specialty)),
              _DetailRow(label: 'Registration no.', value: _empty(doctor?.registrationNumber)),
              _DetailRow(label: 'Clinic / Hospital', value: _empty(doctor?.clinic)),
              _DetailRow(label: 'Experience', value: _empty(doctor?.experience)),
              _DetailRow(label: 'Doctor ID', value: doctor?.id ?? '—'),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: () async {
                await ref.read(doctorProfileProvider.notifier).clearProfile();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _maroon,
                side: const BorderSide(color: _maroon),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Sign out from Doctor Portal'),
            ),
          ),
        ],
      ),
    );
  }

  String _empty(String? s) => (s == null || s.trim().isEmpty) ? '—' : s.trim();

  Widget _buildAvatar(String? name) {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: _maroon.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            (name != null && name.isNotEmpty) ? name[0].toUpperCase() : 'D',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: _maroon,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF6B6B6B),
        letterSpacing: 0.8,
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.items});

  final List<_DetailRow> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _DetailRowWidget(label: items[i].label, value: items[i].value),
            if (i < items.length - 1)
              Divider(height: 24, color: Colors.grey[200]),
          ],
        ],
      ),
    );
  }
}

class _DetailRow {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;
}

class _DetailRowWidget extends StatelessWidget {
  const _DetailRowWidget({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
