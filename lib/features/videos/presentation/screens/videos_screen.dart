import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/models/video.dart';
import '../../../../shared/models/reward_point.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/widgets/app_card.dart';

class VideosScreen extends ConsumerStatefulWidget {
  const VideosScreen({super.key});

  @override
  ConsumerState<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends ConsumerState<VideosScreen> {
  String _category = 'all';

  List<Video> _videos(AppLocalizations t) => [
        Video(
          id: 'v1',
          title: t.t('video_title_hygiene'),
          category: 'hygiene',
          languageCode: 'en',
          url: 'https://example.com/video1',
        ),
        Video(
          id: 'v2',
          title: t.t('video_title_nutrition'),
          category: 'nutrition',
          languageCode: 'hi',
          url: 'https://example.com/video2',
        ),
        Video(
          id: 'v3',
          title: t.t('video_title_cycle'),
          category: 'cycle',
          languageCode: 'te',
          url: 'https://example.com/video3',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider)?.languageCode ?? 'en';
    String categoryLabel(String value) {
      switch (value) {
        case 'hygiene':
          return t.t('category_hygiene');
        case 'nutrition':
          return t.t('category_nutrition');
        case 'cycle':
          return t.t('category_cycle_education');
        case 'all':
        default:
          return t.t('category_all');
      }
    }

    final filtered = _videos(t)
        .where((video) =>
            (_category == 'all' || video.category == _category) &&
            video.languageCode == locale)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(t.t('videos'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(labelText: t.t('category')),
              items: [
                DropdownMenuItem(value: 'all', child: Text(t.t('category_all'))),
                DropdownMenuItem(
                    value: 'hygiene', child: Text(t.t('category_hygiene'))),
                DropdownMenuItem(
                    value: 'nutrition', child: Text(t.t('category_nutrition'))),
                DropdownMenuItem(
                    value: 'cycle',
                    child: Text(t.t('category_cycle_education'))),
              ],
              onChanged: (value) =>
                  setState(() => _category = value ?? 'all'),
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty) Text(t.t('no_videos')),
            for (final video in filtered)
              AppCard(
                child: ListTile(
                  title: Text(video.title),
                  subtitle: Text(categoryLabel(video.category)),
                  trailing: const Icon(Icons.play_circle_outline),
                  onTap: () {
                    ref.read(rewardsProvider.notifier).addPoints(
                          RewardPoint(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            points: 3,
                            reason: 'points_video',
                            createdAt: DateTime.now(),
                          ),
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.t('points_added'))),
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
