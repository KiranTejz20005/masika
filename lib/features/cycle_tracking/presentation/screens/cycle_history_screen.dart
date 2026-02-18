import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/widgets/app_card.dart';

class CycleHistoryScreen extends ConsumerWidget {
  const CycleHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final logs = ref.watch(cycleLogsProvider);
    String moodLabel(String value) {
      switch (value) {
        case 'irritable':
          return t.t('mood_irritable');
        case 'low':
          return t.t('mood_low');
        case 'calm':
        default:
          return t.t('mood_calm');
      }
    }

    String flowLabel(String value) {
      switch (value) {
        case 'light':
          return t.t('flow_light');
        case 'heavy':
          return t.t('flow_heavy');
        case 'medium':
        default:
          return t.t('flow_medium');
      }
    }
    return Scaffold(
      appBar: AppBar(title: Text(t.t('cycle_history'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (logs.isEmpty)
              AppCard(child: Text(t.t('no_cycle_logs'))),
            for (final log in logs)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${log.startDate.toLocal().toString().split(' ').first} '
                      '- ${log.endDate.toLocal().toString().split(' ').first}',
                    ),
                    const SizedBox(height: 6),
                    Text('${t.t('mood')}: ${moodLabel(log.mood)}'),
                    Text('${t.t('flow')}: ${flowLabel(log.flow)}'),
                    Text('${t.t('symptoms')}: ${log.symptoms.join(', ')}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
