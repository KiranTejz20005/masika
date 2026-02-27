import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/appointment.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../backend/repositories/doctor_repository.dart';
import '../../domain/specialist_model.dart';
import 'my_bookings_screen.dart';
import 'specialist_chat_screen.dart';

// ═══════════════════════════════════════════════════════════════
//  Masika Specialists — Pixel-perfect: app bar, search,
//  Top Recommended (horizontal), Nearby Specialists (list), booking & chat
//  Now fetches registered doctors from Supabase
// ═══════════════════════════════════════════════════════════════

const _maroon = Color(0xFF8D2D3B);
const _bg = Color(0xFFF8F7F5);
const _cardBg = Color(0xFFFFFFFF);
const _titleColor = Color(0xFF1A1A1A);
const _subtitleGray = Color(0xFF6B6B6B);
const _seeAllColor = Color(0xFF8D2D3B);
const _premiumCardBg = Color(0xFF8D2D3B);
const _secondaryCardBg = Color(0xFF5C4D7A);
const _statusGreen = Color(0xFF4CAF50);
const _starOrange = Color(0xFFFF9800);

/// ConsultationScreen = Masika Specialists (Doctor tab). Fetches registered doctors from Supabase.
class ConsultationScreen extends ConsumerStatefulWidget {
  const ConsultationScreen({super.key});

  @override
  ConsumerState<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends ConsumerState<ConsultationScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  String? _filterSpecialty;
  String? _filterAvailability;

  List<Specialist> _allDoctors = [];
  List<Specialist> _topRecommended = [];
  List<Specialist> _filteredNearby = [];
  bool _isLoading = true;

  static const _specialties = [
    'All',
    'Diagnostic Radiology',
    'Holistic Wellness',
    'Lab Specialist',
    'Fertility & Diagnostics',
    'Hormonal Health',
    'Obstetrics & Gynecology',
    'Endocrinology',
    'General Practice',
  ];
  static const _availabilityOptions = ['All', 'TODAY', 'TOMORROW', 'This week'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
        _applyFilter();
      });
    });
    _loadRegisteredDoctors();
  }

  Future<void> _loadRegisteredDoctors() async {
    try {
      final doctors = await DoctorRepository().getAllDoctors();
      final specialists = doctors.map((d) {
        return Specialist(
          id: d.id,
          name: 'Dr. ${d.name}',
          specialty: d.specialty.isNotEmpty ? d.specialty : 'General Practice',
          availabilityLabel: 'Available',
          rating: d.rating > 0 ? d.rating : 4.8,
          imageUrl: d.profileImageUrl,
          isPremium: false,
          isOnline: true,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _allDoctors = specialists;
          // First 2 with highest rating or first 2 as top recommended
          if (specialists.length > 2) {
            final sorted = List<Specialist>.from(specialists)
              ..sort((a, b) => b.rating.compareTo(a.rating));
            _topRecommended = sorted.take(2).map((s) {
              // Make first one premium
              final idx = sorted.indexOf(s);
              return Specialist(
                id: s.id,
                name: s.name,
                specialty: s.specialty,
                availabilityLabel: s.availabilityLabel,
                rating: s.rating,
                imageUrl: s.imageUrl,
                isPremium: idx == 0,
                isOnline: s.isOnline,
              );
            }).toList();
          } else {
            _topRecommended = specialists;
          }
          _filteredNearby = List<Specialist>.from(specialists);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    var list = List<Specialist>.from(_allDoctors);
    if (_query.isNotEmpty) {
      list = list
          .where((Specialist s) =>
              s.name.toLowerCase().contains(_query) ||
              s.specialty.toLowerCase().contains(_query))
          .toList();
    }
    if (_filterSpecialty != null && _filterSpecialty != 'All') {
      list = list.where((s) => s.specialty == _filterSpecialty).toList();
    }
    if (_filterAvailability != null && _filterAvailability != 'All') {
      final key = _filterAvailability!.toUpperCase();
      list = list
          .where((s) => s.availabilityLabel.toUpperCase().contains(key))
          .toList();
    }
    _filteredNearby = list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: CircularProgressIndicator(color: _maroon),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(child: _buildSearchBar(context)),
            SliverToBoxAdapter(child: _buildTopRecommendedSection(context)),
            SliverToBoxAdapter(child: _buildNearbySectionHeader(context)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                100 + MediaQuery.paddingOf(context).bottom,
              ),
              sliver: _filteredNearby.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Center(
                          child: Text(
                            'No specialists match your search',
                            style: TextStyle(
                              fontSize: 14,
                              color: _subtitleGray,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _NearbySpecialistCard(
                              specialist: _filteredNearby[index],
                              onBook: () => _openBooking(context, _filteredNearby[index]),
                              onChat: () => _openChat(context, _filteredNearby[index]),
                            ),
                          );
                        },
                        childCount: _filteredNearby.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                ref.read(navIndexProvider.notifier).state = 0;
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: _subtitleGray,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Masika Specialists',
                style: AppTypography.screenTitle.copyWith(
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () => _showFilterSheet(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.tune_rounded,
                  size: 22,
                  color: _subtitleGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 24, color: _subtitleGray.withValues(alpha: 0.8)),
            const SizedBox(width: 14),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                decoration: const InputDecoration(
                  hintText: 'Search specialist, symptom...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                ),
                style: const TextStyle(fontSize: 16, color: _titleColor),
                onSubmitted: (_) => _applyFilter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRecommendedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Recommended',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _titleColor,
                ),
              ),
              GestureDetector(
                onTap: () => _openSeeAllRecommended(context),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _seeAllColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _topRecommended.length,
            itemBuilder: (context, index) {
              final s = _topRecommended[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _PremiumSpecialistCard(
                  specialist: s,
                  width: 280,
                  onBookPriority: () => _openBooking(context, s),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNearbySectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: const Text(
        'Nearby Specialists',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _titleColor,
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _titleColor,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.medical_services_outlined, color: _maroon),
                title: const Text('Specialty'),
                subtitle: Text(
                  _filterSpecialty ?? 'All',
                  style: const TextStyle(fontSize: 12, color: _subtitleGray),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSpecialtyPicker(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.schedule_rounded, color: _maroon),
                title: const Text('Availability'),
                subtitle: Text(
                  _filterAvailability ?? 'All',
                  style: const TextStyle(fontSize: 12, color: _subtitleGray),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAvailabilityPicker(context);
                },
              ),
              if (_filterSpecialty != null || _filterAvailability != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filterSpecialty = null;
                      _filterAvailability = null;
                      _applyFilter();
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Clear filters', style: TextStyle(color: _maroon, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showSpecialtyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const Text(
              'Select specialty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _titleColor),
            ),
            const SizedBox(height: 12),
            ..._specialties.map((s) => ListTile(
              title: Text(s),
              selected: _filterSpecialty == s || (_filterSpecialty == null && s == 'All'),
              onTap: () {
                setState(() {
                  _filterSpecialty = s == 'All' ? null : s;
                  _applyFilter();
                });
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showAvailabilityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const Text(
              'Select availability',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _titleColor),
            ),
            const SizedBox(height: 12),
            ..._availabilityOptions.map((a) => ListTile(
              title: Text(a),
              selected: _filterAvailability == a || (_filterAvailability == null && a == 'All'),
              onTap: () {
                setState(() {
                  _filterAvailability = a == 'All' ? null : a;
                  _applyFilter();
                });
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _openSeeAllRecommended(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SeeAllRecommendedScreen(
          specialists: _topRecommended,
          onBook: (s) => _openBooking(context, s, fromSeeAll: true),
        ),
      ),
    );
  }

  void _openBooking(BuildContext context, Specialist specialist, {bool fromSeeAll = false}) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SpecialistBookingScreen(
          specialist: specialist,
          fromSeeAll: fromSeeAll,
        ),
      ),
    );
  }

  void _openChat(BuildContext context, Specialist specialist) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpecialistChatScreen(specialist: specialist),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Premium (Top Recommended) card — dark maroon, badge, Book Priority
// ═══════════════════════════════════════════════════════════════

class _PremiumSpecialistCard extends StatelessWidget {
  const _PremiumSpecialistCard({
    required this.specialist,
    required this.onBookPriority,
    this.width,
  });

  final Specialist specialist;
  final VoidCallback onBookPriority;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final isPremium = specialist.isPremium;
    final bg = isPremium ? _premiumCardBg : _secondaryCardBg;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 100, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        isPremium ? 'PREMIUM CARE' : 'RECOMMENDED',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _maroon,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  specialist.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  specialist.specialty,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      onTap: onBookPriority,
                      borderRadius: BorderRadius.circular(24),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            'Book Priority',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _maroon,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 100,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(28)),
              child: Image.network(
                specialist.imageUrl,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.white.withValues(alpha: 0.1),
                  child: const Center(
                    child: Icon(Icons.person_rounded, size: 48, color: Colors.white54),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Nearby specialist card — avatar + green dot, name, specialty,
//  availability, rating, Book Consultation + Chat
// ═══════════════════════════════════════════════════════════════

class _NearbySpecialistCard extends StatelessWidget {
  const _NearbySpecialistCard({
    required this.specialist,
    required this.onBook,
    this.onChat,
  });

  final Specialist specialist;
  final VoidCallback onBook;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipOval(
                    child: Image.network(
                      specialist.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 56,
                        height: 56,
                        color: const Color(0xFFF5F3F4),
                        child: const Icon(Icons.person_rounded, size: 28, color: _maroon),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: specialist.isOnline ? _statusGreen : const Color(0xFFBDBDBD),
                        shape: BoxShape.circle,
                        border: Border.all(color: _cardBg, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specialist.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _titleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      specialist.specialty,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _subtitleGray,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 14, color: _subtitleGray.withValues(alpha: 0.9)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            specialist.availabilityLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: _subtitleGray.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 18, color: _starOrange),
                  const SizedBox(width: 4),
                  Text(
                    '${specialist.rating}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Material(
              color: _maroon,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: onBook,
                borderRadius: BorderRadius.circular(24),
                child: const Center(
                  child: Text(
                    'Book Consultation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  See all (Top Recommended) full screen
// ═══════════════════════════════════════════════════════════════

class _SeeAllRecommendedScreen extends StatelessWidget {
  const _SeeAllRecommendedScreen({
    required this.specialists,
    required this.onBook,
  });

  final List<Specialist> specialists;
  final void Function(Specialist) onBook;

  @override
  Widget build(BuildContext context) {
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
          'Top Recommended',
          style: AppTypography.screenTitle.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: specialists.length,
        itemBuilder: (context, index) {
          final s = specialists[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _PremiumSpecialistCard(
              specialist: s,
              onBookPriority: () => onBook(s),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Booking screen — slot selection and confirmation
// ═══════════════════════════════════════════════════════════════

class _SpecialistBookingScreen extends ConsumerStatefulWidget {
  const _SpecialistBookingScreen({
    required this.specialist,
    this.fromSeeAll = false,
  });

  final Specialist specialist;
  final bool fromSeeAll;

  @override
  ConsumerState<_SpecialistBookingScreen> createState() => _SpecialistBookingScreenState();
}

class _SpecialistBookingScreenState extends ConsumerState<_SpecialistBookingScreen> {
  String? _selectedSlot;
  bool _booked = false;

  static const _slots = [
    '10:00 AM',
    '11:30 AM',
    '02:00 PM',
    '04:30 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final s = widget.specialist;
    final fromSeeAll = widget.fromSeeAll;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _maroon, size: 20),
          onPressed: () {
            if (fromSeeAll) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          s.name,
          style: AppTypography.screenTitle.copyWith(color: AppColors.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
                borderRadius: BorderRadius.circular(24),
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
                  ClipOval(
                    child: Image.network(
                      s.imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 72,
                        height: 72,
                        color: const Color(0xFFF5F3F4),
                        child: const Icon(Icons.person_rounded, size: 36, color: _maroon),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.specialty,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _maroon,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: _starOrange),
                            const SizedBox(width: 4),
                            Text(
                              '${s.rating}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _titleColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!_booked) ...[
              const Text(
                'Select time slot',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _titleColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _slots.map((slot) {
                  final selected = _selectedSlot == slot;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedSlot = slot);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? _maroon : const Color(0xFFF5F3F4),
                        borderRadius: BorderRadius.circular(24),
                        border: selected ? null : Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : _titleColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedSlot == null
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          final slot = _selectedSlot!;
                          ref.read(appointmentsProvider.notifier).add(
                                Appointment(
                                  id: '${DateTime.now().millisecondsSinceEpoch}_${s.id}',
                                  doctorId: s.id,
                                  doctorName: s.name,
                                  doctorSpecialty: s.specialty,
                                  timeSlot: slot,
                                  notes: '',
                                  bookedAt: DateTime.now(),
                                  doctorImageUrl: s.imageUrl,
                                  doctorRating: s.rating,
                                ),
                              );
                          setState(() => _booked = true);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _maroon,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    _selectedSlot == null
                        ? 'Select a time slot'
                        : 'Confirm booking · $_selectedSlot',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
            if (_booked) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF81C784)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 56, color: Color(0xFF2E7D32)),
                    const SizedBox(height: 16),
                    const Text(
                      'Consultation booked',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your consultation with ${s.name} is confirmed for $_selectedSlot.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: _subtitleGray,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 54,
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          final navigator = Navigator.of(context);
                          if (fromSeeAll) {
                            navigator.pop();
                            navigator.pop();
                          } else {
                            navigator.pop();
                          }
                          navigator.push(
                            MaterialPageRoute(
                              builder: (_) => const MyBookingsScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2E7D32),
                          side: const BorderSide(color: Color(0xFF81C784)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'View Bookings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
