import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/responsive_config.dart';
import 'in_app_video_screen.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../auth/presentation/screens/profile_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

// Pixel-perfect reference: Hey Sarah, search, For You tabs, video cards with maroon badge + white title overlay, FAB
const _maroon = Color(0xFF8D2D3B);
const _bg = Color(0xFFFAF8F9);
const _cardGray = Color(0xFF4B4B4B);

class _VideoItem {
  final String id;
  final String thumb;
  final String tag;
  final String duration;
  final String title;
  final String description;
  final String category;
  final String url;

  const _VideoItem({
    required this.id,
    required this.thumb,
    required this.tag,
    required this.duration,
    required this.title,
    required this.description,
    required this.category,
    required this.url,
  });
}

/// YouTube videos embedded on home screen (Diagnostics, Hormonal Health, etc.)
List<_VideoItem> _buildDummyVideos() {
  const videos = [
    (id: '5u6Y6ZP2_Wg', title: 'AI Diagnostics: Myths vs Reality', category: 'Diagnostics', tag: 'INSIGHTS',
     description: 'Separating fact from fiction when it comes to AI in healthcare diagnostics. Learn what AI can and cannot do today, and how to interpret results with confidence.'),
    (id: 'cfROFgkV43E', title: 'Understanding your lab results', category: 'Diagnostics', tag: 'INSIGHTS',
     description: 'A clear guide to reading your blood work and lab reports. We break down common markers, ranges, and what they mean for your health.'),
    (id: 'WoeuyW74V0k', title: 'Cycle phases explained', category: 'Hormonal Health', tag: 'HORMONAL',
     description: 'Your menstrual cycle in plain language: follicular, ovulation, luteal, and menstruation. Know what to expect in each phase.'),
    (id: 'GUVL7jtxTDg', title: 'Hormones and mood', category: 'Hormonal Health', tag: 'HORMONAL',
     description: 'How hormones influence mood and energy throughout your cycle. Practical tips to support emotional balance.'),
    (id: 'q-6MgBDqK9E', title: 'Nutrition for balance', category: 'Hormonal Health', tag: 'HORMONAL',
     description: 'Foods and eating habits that support hormonal health. Simple, sustainable nutrition tips for everyday life.'),
    (id: 'cjbgZwgdY7Q', title: 'Period care essentials', category: 'Period Health', tag: 'PERIOD',
     description: 'Everything you need for a safer, more comfortable period: products, hygiene, and when to see a doctor.'),
    (id: 'kmWbOC8Fbb0', title: 'Wellness & self-care tips', category: 'Wellness', tag: 'WELLNESS',
     description: 'Small daily habits that add up: rest, movement, and mindfulness for long-term wellness.'),
  ];
  const durations = ['5:20 mins', '8:24 mins', '12:45 mins', '6:10 mins', '10:00 mins', '7:35 mins', '9:00 mins'];
  return [
    for (var i = 0; i < videos.length; i++)
      _VideoItem(
        id: videos[i].id,
        thumb: 'https://img.youtube.com/vi/${videos[i].id}/mqdefault.jpg',
        tag: videos[i].tag,
        duration: durations[i],
        title: videos[i].title,
        description: videos[i].description,
        category: videos[i].category,
        url: 'https://www.youtube.com/watch?v=${videos[i].id}',
      ),
  ];
}

final _allVideos = _buildDummyVideos();

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _categoryIndex = 0;
  static const _categories = ['For You', 'Diagnostics', 'Hormonal Health'];

  List<_VideoItem> _filteredVideos() {
    switch (_categoryIndex) {
      case 0:
        return _allVideos;
      case 1:
        return _allVideos.where((v) => v.category == 'Diagnostics' || v.category == 'Hormonal Health').toList();
      case 2:
        return _allVideos.where((v) => v.category == 'Hormonal Health').toList();
      default:
        return _allVideos;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final name = profile?.name.isNotEmpty == true
        ? profile!.name.split(' ').first
        : 'there';
    final hp = ResponsiveConfig.horizontalPadding(context);
    final navTotalHeight = ResponsiveConfig.bottomBarHeight(context);
    final listBottom = navTotalHeight + 20;
    final videos = _filteredVideos();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, name, hp)),
            SliverToBoxAdapter(child: _buildSearchBar(context, hp)),
            SliverToBoxAdapter(child: _buildCategoryPills(context, hp)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hp, 8, hp, listBottom),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index.isOdd) return const SizedBox(height: 20);
                    final video = videos[index ~/ 2];
                    return _buildVideoCard(
                      context,
                      thumb: video.thumb,
                      tag: video.tag,
                      duration: video.duration,
                      title: video.title,
                      description: video.description,
                      videoId: video.id,
                    );
                  },
                  childCount: videos.isEmpty ? 0 : videos.length * 2 - 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, double hp) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 20, hp, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hey $name...',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _maroon,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'let\'s start our day with fresh Masika videos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _cardGray.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.notifications_outlined, color: _maroon, size: 26),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.person_outline_rounded, color: _maroon, size: 26),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, double hp) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: _cardGray.withValues(alpha: 0.6), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Search health topics, videos...',
                      style: TextStyle(
                        fontSize: 14,
                        color: _cardGray.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: _maroon,
            shape: const CircleBorder(),
            elevation: 2,
            shadowColor: _maroon.withValues(alpha: 0.3),
            child: InkWell(
              onTap: () => _showVideoFilterSheet(context),
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.tune_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVideoFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Show videos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _cardGray,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                _categories.length,
                (i) => ListTile(
                  leading: Icon(
                    i == 0 ? Icons.explore_rounded : (i == 1 ? Icons.monitor_heart_rounded : Icons.favorite_rounded),
                    color: _maroon,
                  ),
                  title: Text(_categories[i]),
                  selected: _categoryIndex == i,
                  onTap: () {
                    setState(() => _categoryIndex = i);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPills(BuildContext context, double hp) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        clipBehavior: Clip.none,
        child: Row(
          children: [
            const SizedBox(width: 8),
            ...List.generate(
              _categories.length,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _categoryIndex = i),
                    borderRadius: BorderRadius.circular(28),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      decoration: BoxDecoration(
                        color: _categoryIndex == i ? _maroon : const Color(0xFFF5EFEB),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: Text(
                          _categories[i],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _categoryIndex == i ? Colors.white : _maroon,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(
    BuildContext context, {
    required String thumb,
    required String tag,
    required String duration,
    required String title,
    required String description,
    required String videoId,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => InAppVideoScreen(
                videoId: videoId,
                title: title,
                description: description,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            thumb,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 220,
              color: const Color(0xFFF3F3F3),
              child: const Icon(Icons.play_circle_outline_rounded, size: 56, color: _maroon),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded, color: _maroon, size: 28),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            right: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$tag · $duration',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Color(0x80000000), offset: Offset(0, 1), blurRadius: 4),
                      Shadow(color: Color(0x40000000), offset: Offset(0, 0), blurRadius: 2),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.more_vert_rounded, color: _cardGray, size: 22),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

}

