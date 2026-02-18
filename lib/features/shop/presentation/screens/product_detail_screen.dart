import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/product.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../cart/presentation/screens/cart_screen.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final cart = ref.watch(cartProvider);
    final inCart = cart.any((c) => c.product.id == product.id);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F9),
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: const Color(0xFFFAF8F9),
        elevation: 0,
        foregroundColor: const Color(0xFF1A1A1A),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            icon: Badge(
              label: Text('${cart.length}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Hero image
          Container(
            height: 260,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3F4),
              borderRadius: BorderRadius.circular(24),
            ),
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF8B1538)),
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (ctx, err, stack) => Center(
                      child: Icon(Icons.spa_rounded, size: 80, color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                  )
                : Center(
                    child: Icon(Icons.spa_rounded, size: 80, color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            product.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 4),
          Text(product.category, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(height: 12),
          // Price
          Text(
            '₹${product.price.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF8B1538)),
          ),
          const SizedBox(height: 20),
          // Description
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  product.description.isNotEmpty
                      ? product.description
                      : 'Premium wellness product specially formulated for menstrual health. Made with natural ingredients to support your cycle.',
                  style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Features
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Key Benefits', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _benefit('Natural, hormone-safe ingredients'),
                _benefit('Clinically tested for menstrual wellness'),
                _benefit('No artificial preservatives'),
                _benefit('Eco-friendly packaging'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Add to cart button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                ref.read(cartProvider.notifier).add(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} added to cart'),
                    backgroundColor: const Color(0xFF8B1538),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    action: SnackBarAction(
                      label: 'View Cart',
                      textColor: Colors.white,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1538),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    inCart ? 'Add Another' : t.t('add_to_cart'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _benefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF2E7D32)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13.5, color: Colors.grey[700]))),
        ],
      ),
    );
  }
}
