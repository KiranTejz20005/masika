import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/app_card.dart';

class RewardsRedeemScreen extends StatelessWidget {
  const RewardsRedeemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('redeem_points'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(child: Text(t.t('redeem_discounts'))),
            AppCard(child: Text(t.t('redeem_reports'))),
          ],
        ),
      ),
    );
  }
}
