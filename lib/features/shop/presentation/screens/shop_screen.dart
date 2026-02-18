import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/product.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import 'product_detail_screen.dart';

// Product image URLs — stored directly in Product.imageUrl for use everywhere

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String _selectedCategory = 'All';

  static final _products = [
    Product(id: 'magnesium_spray', name: 'Magnesium Spray', description: 'Topical magnesium oil to ease muscle cramps, support relaxation, and improve sleep quality during your cycle.', price: 349, imageUrl: 'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=400&h=400&fit=crop', category: 'Supplements'),
    Product(id: 'cycle_balance_tea', name: 'Cycle Balance Tea', description: 'Organic herbal blend with raspberry leaf, ginger, and chamomile to support hormonal balance and reduce bloating.', price: 199, imageUrl: 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=400&h=400&fit=crop', category: 'Nutrition'),
    Product(id: 'organic_pads', name: 'Organic Cotton Pads', description: 'Ultra-soft 100% organic cotton pads. Chlorine-free, fragrance-free, hypoallergenic. Pack of 20.', price: 149, imageUrl: 'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=400&h=400&fit=crop', category: 'Hygiene'),
    Product(id: 'iron_supplement', name: 'Iron + B12 Complex', description: 'Gentle plant-based iron supplement with B12 and folic acid for energy support during menstruation.', price: 299, imageUrl: 'https://images.unsplash.com/photo-1550572017-edd951b55104?w=400&h=400&fit=crop', category: 'Supplements'),
    Product(id: 'wellness_drink', name: 'Berry Wellness Drink', description: 'Antioxidant-rich organic berry drink with added iron, vitamin C, and adaptogens for hormonal health.', price: 179, imageUrl: 'https://images.unsplash.com/photo-1622597467836-f3285f2131b8?w=400&h=400&fit=crop', category: 'Nutrition'),
    Product(id: 'heat_patch', name: 'Heat Therapy Patches', description: 'Natural self-warming patches with menthol and eucalyptus for instant period cramp relief. Pack of 5.', price: 129, imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&h=400&fit=crop', category: 'Relief'),
    Product(id: 'ashwagandha', name: 'Ashwagandha Capsules', description: 'Organic Ashwagandha for stress reduction, hormonal balance, and better sleep. 30 capsules.', price: 399, imageUrl: 'https://images.unsplash.com/photo-1611241893603-3c359704e0ee?w=400&h=400&fit=crop', category: 'Ayurveda'),
    Product(id: 'turmeric_latte', name: 'Golden Turmeric Latte', description: 'Organic turmeric with black pepper and cinnamon for anti-inflammatory support.', price: 249, imageUrl: 'https://images.unsplash.com/photo-1578020190125-f4f7c18bc9cb?w=400&h=400&fit=crop', category: 'Nutrition'),
    Product(id: 'omega3', name: 'Omega-3 Fish Oil', description: 'Omega-3 fatty acids (EPA/DHA) to reduce inflammation and support hormonal health.', price: 499, imageUrl: 'https://images.unsplash.com/photo-1577401239170-897942555fb3?w=400&h=400&fit=crop', category: 'Supplements'),
    Product(id: 'menstrual_cup', name: 'Silicone Menstrual Cup', description: 'Medical-grade silicone menstrual cup. Reusable for up to 10 years.', price: 399, imageUrl: 'https://images.unsplash.com/photo-1590002367575-476e19a0b58d?w=400&h=400&fit=crop', category: 'Hygiene'),
    Product(id: 'essential_oil', name: 'Lavender Essential Oil', description: 'Pure lavender oil for aromatherapy. Helps with cramp relief and sleep.', price: 199, imageUrl: 'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=400&h=400&fit=crop', category: 'Wellness'),
    Product(id: 'probiotic', name: 'Women\'s Probiotic', description: 'Targeted probiotic blend for gut health and immunity. 30 caps.', price: 449, imageUrl: 'https://images.unsplash.com/photo-1550572017-edd951b55104?w=400&h=400&fit=crop', category: 'Supplements'),
    Product(id: 'pain_relief_rollon', name: 'Pain Relief Roll-On', description: 'Cooling roll-on with peppermint and eucalyptus for instant cramp relief.', price: 120, imageUrl: 'https://images.unsplash.com/photo-1512207846876-bb54ef505c97?w=400&h=400&fit=crop', category: 'Relief'),
    Product(id: 'sanitary_wipes', name: 'Intimate Hygiene Wipes', description: 'pH-balanced wipes for on-the-go freshness. Pack of 25.', price: 99, imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=400&fit=crop', category: 'Hygiene'),
    Product(id: 'herbal_tea_calm', name: 'Calm Herbal Tea', description: 'Chamomile + lemongrass blend for relaxation and better sleep.', price: 159, imageUrl: 'https://images.unsplash.com/photo-1517686469429-8bdb88b9f907?w=400&h=400&fit=crop', category: 'Nutrition'),
    Product(id: 'b6_gummies', name: 'Vitamin B6 Gummies', description: 'Supports mood balance and reduces PMS symptoms. 30 gummies.', price: 249, imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=400&fit=crop', category: 'Supplements'),
    Product(id: 'neem_face_wash', name: 'Neem Face Wash', description: 'Gentle neem cleanser to reduce hormonal acne breakouts.', price: 129, imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400&h=400&fit=crop', category: 'Wellness'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cart = ref.watch(cartProvider);
    final categories = const ['All', 'Supplements', 'Nutrition', 'Hygiene', 'Ayurveda', 'Relief', 'Wellness'];
    final filtered = _selectedCategory == 'All'
        ? _products
        : _products.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F9),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header with back button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => ref.read(navIndexProvider.notifier).state = 0,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(t.t('shop'),
                          style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A1A1A))),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                      child: Stack(children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                          ),
                          child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF1A1A1A), size: 22),
                        ),
                        if (cart.isNotEmpty)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Color(0xFF8B1538), shape: BoxShape.circle),
                              child: Text('${cart.length}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),

            // Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFEEDDFB), Color(0xFFF3E8FF)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.eco_rounded, color: Color(0xFF8B1538), size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Organic & Natural', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('100% organic wellness products for every cycle phase', style: TextStyle(fontSize: 13, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),

            // Category chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  children: categories
                      .map((c) => _chip(c, _selectedCategory == c))
                      .toList(),
                ),
              ),
            ),

            // Product grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final p = filtered[index];
                    return _ShopProductCard(
                      product: p,
                      imageUrl: p.imageUrl,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
                      onAdd: () {
                        ref.read(cartProvider.notifier).add(p);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${p.name} added to cart'),
                          backgroundColor: const Color(0xFF8B1538),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 1),
                        ));
                      },
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => setState(() => _selectedCategory = label),
        selectedColor: const Color(0xFF8B1538),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : const Color(0xFF1A1A1A),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: active ? const Color(0xFF8B1538) : const Color(0xFFE0E0E0)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Product Card with Image
// ═══════════════════════════════════════════════════════════════

class _ShopProductCard extends StatelessWidget {
  final Product product;
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _ShopProductCard({
    required this.product,
    required this.imageUrl,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF5F3F4),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: const Color(0xFFF5F3F4),
                    child: Icon(Icons.spa_rounded, size: 40, color: Colors.grey[300]),
                  ),
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
                ),
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: Color(0xFF8B1538)),
                    ),
                    const SizedBox(height: 4),
                    // Name
                    Text(
                      product.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A), height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Price + Add
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF8B1538)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: onAdd,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(color: Color(0xFF8B1538), shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
