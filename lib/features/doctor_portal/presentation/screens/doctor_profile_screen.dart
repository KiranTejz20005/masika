import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_providers.dart';
import '../../../auth/presentation/screens/welcome_screen.dart';

/// Pixel-perfect Doctor Profile Screen
/// Features: Profile header, online toggle, stats, About Me, Specializations
class DoctorProfileScreen extends ConsumerStatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  ConsumerState<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends ConsumerState<DoctorProfileScreen> {
  bool _isOnline = true;
  final TextEditingController _aboutController = TextEditingController(
    text: 'Dr. Sarah Chen is a board-certified obstetrician and gynecologist with over 12 years of clinical experience. She specializes in high-risk pregnancies and minimally invasive gynecologic surgery, focusing on providing compassionate, patient-centered care for women at every stage of life.',
  );
  
  List<String> _specializations = [
    'Prenatal Care',
    'Family Planning',
    'Minimally Invasive Surgery',
    'Gynecology',
    'Women\'s Wellness',
  ];

  // Design colors
  static const _maroon = Color(0xFF8C1D3F);
  static const _white = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F8F8);
  static const _textGray = Color(0xFF6B6B6B);
  static const _labelGray = Color(0xFF4B4B4B);
  static const _onlineGreen = Color(0xFF4CAF50);
  static const _offlineGray = Color(0xFF9E9E9E);

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit, color: _maroon),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditProfileDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: _maroon),
                title: const Text('Change Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _showChangePhotoOptions();
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: _maroon),
                title: const Text('Add Specialization'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddSpecializationDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: _maroon),
                title: const Text('Sign Out'),
                onTap: () {
                  Navigator.pop(context);
                  _signOut();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Edit profile functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showChangePhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: _maroon),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera functionality')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: _maroon),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gallery functionality')),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSpecializationDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Specialization'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter specialization',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _specializations.add(controller.text.trim());
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add', style: TextStyle(color: _maroon)),
          ),
        ],
      ),
    );
  }

  void _removeSpecialization(String specialization) {
    setState(() {
      _specializations.remove(specialization);
    });
  }

  void _editAboutMe() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit About Me'),
        content: TextField(
          controller: _aboutController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Write about yourself...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: _maroon)),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await ref.read(doctorProfileProvider.notifier).clearProfile();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = ref.watch(doctorProfileProvider);
    final name = doctor?.name ?? 'Dr. Sarah Chen';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _maroon),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Doctor Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _labelGray,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: _labelGray),
            onPressed: _showProfileMenu,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildProfileHeader(name),
              const SizedBox(height: 24),
              _buildOnlineToggle(),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 32),
              _buildAboutMeSection(),
              const SizedBox(height: 24),
              _buildSpecializationsSection(),
              const SizedBox(height: 24),
              _buildSignOutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name) {
    return Column(
      children: [
        // Profile Picture with Online Status
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF5BA8B0),
                shape: BoxShape.circle,
                border: Border.all(color: _white, width: 3),
                image: const DecorationImage(
                  image: NetworkImage('https://randomuser.me/api/portraits/women/44.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _isOnline ? _onlineGreen : _offlineGray,
                shape: BoxShape.circle,
                border: Border.all(color: _white, width: 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Name
        Text(
          name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _labelGray,
          ),
        ),
        const SizedBox(height: 4),
        // Specialty
        const Text(
          'OB/GYN SPECIALIST',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _maroon,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _labelGray.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ONLINE STATUS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textGray,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: _isOnline,
            onChanged: (value) => setState(() => _isOnline = value),
            activeThumbColor: _maroon,
            activeTrackColor: _maroon.withValues(alpha: 0.3),
            inactiveThumbColor: _white,
            inactiveTrackColor: _offlineGray.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('1.2k+', 'PATIENTS'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('12 yrs', 'EXPERIENCE'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('4.9', 'RATING'),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _labelGray.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _maroon,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textGray,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'About Me',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _labelGray,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: _maroon, size: 20),
              onPressed: _editAboutMe,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _labelGray.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Text(
            _aboutController.text,
            style: TextStyle(
              fontSize: 14,
              color: _textGray,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecializationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Specializations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _labelGray,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: _maroon, size: 24),
              onPressed: _showAddSpecializationDialog,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _specializations.map((specialization) {
            return GestureDetector(
              onLongPress: () => _removeSpecialization(specialization),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _maroon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _maroon.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  specialization,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _maroon,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          'Long press to remove specialization',
          style: TextStyle(
            fontSize: 12,
            color: _textGray.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _signOut,
        style: OutlinedButton.styleFrom(
          foregroundColor: _maroon,
          side: const BorderSide(color: _maroon, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Sign out from Doctor Portal',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
