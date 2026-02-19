import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/primary_button.dart';
import 'rewards_redeem_screen.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final points = ref.watch(rewardsProvider);
    final total = points.fold<int>(0, (sum, item) => sum + item.points);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('rewards'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.t('total_points')),
                  const SizedBox(height: 8),
                  Text('$total', style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.t('points_history')),
                  const SizedBox(height: 8),
                  if (points.isEmpty) Text(t.t('points_empty')),
                  for (final point in points)
                    Text('${t.t(point.reason)} +${point.points}'),
                ],
              ),
            ),
            PrimaryButton(
              label: t.t('redeem_points'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RewardsRedeemScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
