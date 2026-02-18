import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/widgets/app_card.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final orders = ref.watch(ordersProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('orders'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (orders.isEmpty) AppCard(child: Text(t.t('orders_empty'))),
            for (final order in orders)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${t.t('order_id')}: ${order.id}'),
                    Text('${t.t('status')}: ${t.t(order.status)}'),
                    Text('${t.t('total')}: ₹${order.total.toStringAsFixed(0)}'),
                    Text(order.items.join(', ')),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
