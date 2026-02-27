import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../backend/services/database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/app_providers.dart';
import 'upload_video_screen.dart';

const _maroon = Color(0xFF6C102C);
const _bg = Color(0xFFF8F7F5);
const _cardBg = Color(0xFFFFFFFF);
const _sectionGray = Color(0xFF9E9E9E);

class DoctorVideoScreen extends ConsumerStatefulWidget {
  const DoctorVideoScreen({super.key});

  @override
  ConsumerState<DoctorVideoScreen> createState() => _DoctorVideoScreenState();
}

class _DoctorVideoScreenState extends ConsumerState<DoctorVideoScreen> {
  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final doctor = ref.read(doctorProfileProvider);
    if (doctor == null || doctor.id.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final videos = await DatabaseService().getDoctorVideos(doctor.id);
      if (mounted) {
        setState(() {
          _videos = videos;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteVideo(String videoId) async {
    try {
      await DatabaseService().deleteDoctorVideo(videoId);
      _loadVideos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video deleted'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _showVideoOptions(Map<String, dynamic> video) {
    final videoId = video['id']?.toString() ?? '';
    showModalBottomSheet(
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
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete Video'),
                onTap: () {
                  Navigator.pop(ctx);
                  if (videoId.isNotEmpty) _deleteVideo(videoId);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
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
          'Patient Education',
          style: AppTypography.screenTitle.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'YOUR VIDEOS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _sectionGray,
                      letterSpacing: 0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UploadVideoScreen(),
                        ),
                      );
                      // Refresh list after returning from upload
                      _loadVideos();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _maroon,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Upload Video',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _maroon))
                  : _videos.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.video_library_rounded, size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'No videos yet',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Upload educational videos for your patients.',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: _videos.length,
                          separatorBuilder: (_, _a) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final v = _videos[index];
                            return _EducationListCard(
                              title: v['title'] as String? ?? 'Untitled',
                              views: v['category'] as String? ?? '',
                              thumbnailUrl: v['thumbnailUrl'] as String? ?? '',
                              onMoreTap: () => _showVideoOptions(v),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EducationListCard extends StatelessWidget {
  const _EducationListCard({
    required this.title,
    required this.views,
    required this.thumbnailUrl,
    required this.onMoreTap,
  });

  final String title;
  final String views;
  final String thumbnailUrl;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 88,
            child: thumbnailUrl.isNotEmpty
                ? Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE0E0E0),
                      child: const Icon(Icons.video_library_rounded, size: 40),
                    ),
                  )
                : Container(
                    color: const Color(0xFFE0E0E0),
                    child: const Icon(Icons.video_library_rounded, size: 40, color: _maroon),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _maroon,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (views.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      views,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            color: const Color(0xFF6B6B6B),
            onPressed: onMoreTap,
          ),
        ],
      ),
    );
  }
}
