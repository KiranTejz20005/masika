import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../shared/models/order.dart';
import '../../../../shared/models/reward_point.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../orders/presentation/screens/orders_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  late final PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _checkout(double total) {
    final t = AppLocalizations.of(context);
    _paymentService.openCheckout(
      amountPaise: (total * 100).round(),
      name: 'Masika',
      description: t.t('payment_desc'),
      email: 'user@masika.app',
      contact: '9999999999',
      onSuccess: (_) {
        final cart = ref.read(cartProvider);
        final order = Order(
          id: const Uuid().v4(),
          total: total,
          items: cart.map((item) => item.product.name).toList(),
          status: 'order_paid',
          createdAt: DateTime.now(),
        );
        ref.read(ordersProvider.notifier).add(order);
        ref.read(rewardsProvider.notifier).addPoints(
              RewardPoint(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                points: 20,
                reason: 'points_purchase',
                createdAt: DateTime.now(),
              ),
            );
        ref.read(cartProvider.notifier).clear();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OrdersScreen()),
          );
        }
      },
      onError: (message) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: const Color(0xFF8B1538),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cart = ref.watch(cartProvider);
    final subtotal = cart.fold<double>(0, (s, i) => s + i.total);
    const delivery = 49.0;
    final total = cart.isEmpty ? 0.0 : subtotal + delivery;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F9),
      appBar: AppBar(
        title: Text(t.t('cart')),
        backgroundColor: const Color(0xFFFAF8F9),
        elevation: 0,
        foregroundColor: const Color(0xFF1A1A1A),
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(t.t('cart_empty'), style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Cart items
                for (int i = 0; i < cart.length; i++) ...[
                  _cartItem(cart[i].product.name, cart[i].quantity, cart[i].total, cart[i].product.imageUrl, () {
                    ref.read(cartProvider.notifier).remove(cart[i].product);
                  }),
                  if (i < cart.length - 1) const SizedBox(height: 10),
                ],
                const SizedBox(height: 24),

                // Bill summary
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bill Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      _billRow('Subtotal', '₹${subtotal.toStringAsFixed(0)}'),
                      _billRow('Delivery', '₹${delivery.toStringAsFixed(0)}'),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1),
                      ),
                      _billRow('Total', '₹${total.toStringAsFixed(0)}', isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Checkout button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _checkout(total),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B1538),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      '${t.t('checkout')} · ₹${total.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }

  Widget _cartItem(String name, int qty, double total, String imageUrl, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3F4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) =>
                        const Icon(Icons.spa_rounded, color: Color(0xFF8B1538), size: 22),
                  )
                : const Icon(Icons.spa_rounded, color: Color(0xFF8B1538), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Qty: $qty  ·  ₹${total.toStringAsFixed(0)}', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4EE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Color(0xFF8B1538), size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _billRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? const Color(0xFF1A1A1A) : Colors.grey[600],
          )),
          Text(value, style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? const Color(0xFF8B1538) : const Color(0xFF1A1A1A),
          )),
        ],
      ),
    );
  }
}
