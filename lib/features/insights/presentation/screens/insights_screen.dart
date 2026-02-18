import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/providers/cycle_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycle = ref.watch(cycleDataProvider);

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
                    Text(
                      'Insights',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Summary card — uses real cycle data
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEEDDFB), Color(0xFFF3E8FF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF8B1538), size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cycle.hasData
                                  ? 'Day ${cycle.cycleDay} · ${cycle.phaseLabel}'
                                  : 'Your Weekly Summary',
                              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cycle.hasData
                                  ? 'Insights based on your ${cycle.phaseLabel.toLowerCase()} phase'
                                  : 'Log your period to get personalized insights',
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Dynamic cards based on cycle phase
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  _getInsightCards(cycle),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getInsightCards(CycleData cycle) {
    final cards = _getCardsForPhase(cycle.phase);
    final widgets = <Widget>[];
    for (int i = 0; i < cards.length; i++) {
      final c = cards[i];
      widgets.add(_ExpandableInsightCard(
        icon: c['icon'] as IconData,
        bgColor: c['bgColor'] as Color,
        iconColor: c['iconColor'] as Color,
        title: c['title'] as String,
        preview: c['preview'] as String,
        body: c['body'] as String,
      ));
      if (i < cards.length - 1) widgets.add(const SizedBox(height: 14));
    }
    return widgets;
  }

  List<Map<String, dynamic>> _getCardsForPhase(String phase) {
    switch (phase) {
      case 'menstrual':
        return [
          {
            'icon': Icons.favorite_rounded,
            'bgColor': const Color(0xFFFFE4EE),
            'iconColor': const Color(0xFF8B1538),
            'title': 'Why rest matters during menstruation',
            'preview': 'Your hormone levels are at their lowest right now...',
            'body': 'During menstruation, both estrogen and progesterone drop to their lowest levels. This hormonal shift can cause fatigue, cramps, and mood changes.\n\nThis is your body\'s natural reset phase. Key tips:\n\n• Rest is not laziness — it\'s recovery\n• Gentle movement can help reduce cramps\n• Heat therapy provides natural pain relief\n• Your body is burning extra calories\n• Iron supplementation may help combat fatigue',
          },
          {
            'icon': Icons.restaurant_rounded,
            'bgColor': const Color(0xFFD4E8D4),
            'iconColor': const Color(0xFF2E7D32),
            'title': 'Iron-rich foods for your period',
            'preview': 'Replenish lost iron with these nutrient-dense foods...',
            'body': 'You lose iron through menstrual blood, which can lead to fatigue and low energy. Focus on iron-rich foods:\n\nAnimal sources (heme iron — better absorbed):\n• Red meat, liver, chicken\n• Shellfish, sardines\n\nPlant sources (non-heme iron):\n• Spinach, lentils, chickpeas\n• Fortified cereals, tofu\n• Pumpkin seeds, quinoa\n\nTip: Pair with vitamin C foods (citrus, bell peppers) to boost iron absorption by up to 6x.',
          },
          {
            'icon': Icons.self_improvement_rounded,
            'bgColor': const Color(0xFFE8D4F8),
            'iconColor': const Color(0xFF7B1FA2),
            'title': 'Gentle exercises for cramp relief',
            'preview': 'Low-intensity movement can actually reduce period pain...',
            'body': 'While rest is important, gentle movement releases endorphins that naturally reduce pain.\n\nRecommended activities:\n• Child\'s pose and cat-cow stretches\n• Light walking (15-20 minutes)\n• Restorative yoga\n• Deep breathing exercises\n• Gentle swimming\n\nAvoid:\n• High-intensity workouts\n• Heavy lifting\n• Inversions (headstands)\n• Anything that increases discomfort',
          },
          {
            'icon': Icons.bedtime_rounded,
            'bgColor': const Color(0xFFFFF4CC),
            'iconColor': const Color(0xFFFF9800),
            'title': 'Sleep and your menstrual phase',
            'preview': 'Prostaglandins and hormone changes can disrupt sleep...',
            'body': 'During menstruation, prostaglandins (which cause cramps) and low progesterone can disrupt your sleep quality.\n\nSleep tips for your period:\n• Keep room temperature cool (18-20°C)\n• Use a heating pad before bed\n• Try magnesium supplement before sleep\n• Herbal teas like chamomile help\n• Sleep in fetal position for comfort\n• Aim for 8+ hours during this phase',
          },
        ];
      case 'ovulation':
        return [
          {
            'icon': Icons.bolt_rounded,
            'bgColor': const Color(0xFFFFE4CC),
            'iconColor': const Color(0xFFFF9800),
            'title': 'Peak energy during ovulation',
            'preview': 'Estrogen peaks and testosterone surges bring maximum energy...',
            'body': 'During ovulation, estrogen reaches its peak and testosterone surges briefly. This creates your most energetic and confident phase.\n\nWhat you may notice:\n• Higher energy and motivation\n• Increased confidence and sociability\n• Better verbal and communication skills\n• Higher pain tolerance\n• Glowing skin (thanks to estrogen)\n• Increased libido',
          },
          {
            'icon': Icons.fitness_center_rounded,
            'bgColor': const Color(0xFFFFF4CC),
            'iconColor': const Color(0xFFFF9800),
            'title': 'Maximize your workout performance',
            'preview': 'Your body is primed for peak performance right now...',
            'body': 'Ovulation is your power window for fitness. Your body recovers faster and builds muscle more efficiently.\n\nOptimal workout plan:\n• HIIT sessions (push your limits!)\n• Heavy strength training\n• Sprint intervals\n• Group fitness classes\n• Competitive sports\n\nYour body can handle more intensity now. Take advantage of this 2-3 day window for your most challenging workouts.',
          },
          {
            'icon': Icons.restaurant_rounded,
            'bgColor': const Color(0xFFD4E8D4),
            'iconColor': const Color(0xFF2E7D32),
            'title': 'Nutrition for ovulation phase',
            'preview': 'Support your body with anti-inflammatory foods...',
            'body': 'During ovulation, focus on supporting your liver to process the estrogen surge:\n\nPriority foods:\n• Cruciferous vegetables (broccoli, kale, cauliflower)\n• Lean proteins for muscle recovery\n• Anti-inflammatory berries and turmeric\n• Zinc-rich foods (pumpkin seeds, oysters)\n• Fiber-rich whole grains\n\nStay hydrated — you may feel warmer as your basal body temperature rises slightly.',
          },
          {
            'icon': Icons.science_rounded,
            'bgColor': const Color(0xFFE8D4F8),
            'iconColor': const Color(0xFF8B1538),
            'title': 'Understanding your fertile window',
            'preview': 'Ovulation is when the egg is released from the ovary...',
            'body': 'Ovulation typically occurs around day 14 of a 28-day cycle (but varies). The egg survives 12-24 hours after release.\n\nKey hormones:\n• LH (Luteinizing Hormone) surges → triggers egg release\n• Estrogen peaks → cervical mucus becomes clear and stretchy\n• Testosterone briefly surges → increased energy and libido\n\nFertile window: ~5 days before ovulation to 1 day after.\n\nSigns of ovulation:\n• Clear, stretchy cervical mucus\n• Slight rise in basal body temperature\n• Mild pelvic pain (mittelschmerz)',
          },
        ];
      case 'luteal':
        return [
          {
            'icon': Icons.psychology_rounded,
            'bgColor': const Color(0xFFE8D4F8),
            'iconColor': const Color(0xFF8B1538),
            'title': 'Understanding PMS and your luteal phase',
            'preview': 'Progesterone rises while estrogen drops, causing changes...',
            'body': 'The luteal phase (after ovulation, before your period) is when progesterone rises and estrogen drops. This shift can cause PMS symptoms.\n\nCommon experiences:\n• Mood swings and irritability\n• Food cravings (especially carbs/sugar)\n• Breast tenderness\n• Bloating and water retention\n• Lower energy levels\n• Difficulty concentrating\n\nRemember: These are normal hormonal responses, not character flaws.',
          },
          {
            'icon': Icons.restaurant_rounded,
            'bgColor': const Color(0xFFD4E8D4),
            'iconColor': const Color(0xFF2E7D32),
            'title': 'Combat cravings with smart nutrition',
            'preview': 'Your body craves carbs for a reason — serotonin production...',
            'body': 'Carb cravings during the luteal phase are your body\'s way of boosting serotonin production (progesterone lowers serotonin).\n\nSmart alternatives:\n• Sweet potato instead of candy\n• Dark chocolate (70%+) instead of milk chocolate\n• Oatmeal with berries instead of pastries\n• Trail mix instead of chips\n\nKey nutrients to focus on:\n• Magnesium (reduces cramps, anxiety)\n• Vitamin B6 (supports mood)\n• Calcium (reduces PMS symptoms)\n• Omega-3 (anti-inflammatory)',
          },
          {
            'icon': Icons.directions_walk_rounded,
            'bgColor': const Color(0xFFFFF4CC),
            'iconColor': const Color(0xFFFF9800),
            'title': 'Adjusting your workout routine',
            'preview': 'Lower intensity doesn\'t mean less effective...',
            'body': 'During the luteal phase, your body temperature is slightly elevated and recovery takes longer.\n\nRecommended activities:\n• Walking (30-45 minutes)\n• Pilates and barre\n• Moderate yoga\n• Swimming\n• Light cycling\n\nAvoid:\n• Pushing through extreme fatigue\n• Very heavy lifting\n• Hot yoga (body temp already elevated)\n\nListen to your body — some luteal days feel great, others need more rest.',
          },
          {
            'icon': Icons.bedtime_rounded,
            'bgColor': const Color(0xFFFFE4EE),
            'iconColor': const Color(0xFF8B1538),
            'title': 'Sleep quality in the luteal phase',
            'preview': 'Progesterone has a sedating effect but can disrupt sleep...',
            'body': 'Progesterone has sedating properties (you may feel sleepier) but paradoxically can disrupt deep sleep, especially in the late luteal phase.\n\nSleep optimization:\n• Go to bed 30 min earlier\n• Avoid screens 1 hour before bed\n• Try magnesium glycinate supplement\n• Keep the room extra cool\n• Weighted blankets can help anxiety\n• Limit caffeine after noon\n\nYour body needs more rest during this phase — honor that need.',
          },
        ];
      default: // follicular
        return [
          {
            'icon': Icons.face_rounded,
            'bgColor': const Color(0xFFFFE4CC),
            'iconColor': const Color(0xFFFF9800),
            'title': 'Why your skin glows in the follicular phase',
            'preview': 'Rising estrogen levels boost collagen production...',
            'body': 'During your follicular phase, estrogen levels rise, leading to increased collagen production and improved skin hydration. This is the best time for:\n\n• New skincare routines\n• Exfoliation treatments\n• Active ingredients like retinol\n• Trying new products\n\nYour skin barrier is at its strongest during this phase.',
          },
          {
            'icon': Icons.fitness_center_rounded,
            'bgColor': const Color(0xFFFFF4CC),
            'iconColor': const Color(0xFFFF9800),
            'title': 'Energy peaks and workout timing',
            'preview': 'Your follicular phase is perfect for high-intensity training...',
            'body': 'Your follicular phase is the perfect time for high-intensity workouts. Your body recovers faster and builds muscle more efficiently now.\n\nRecommended:\n• HIIT sessions (3-4x this week)\n• Strength training with progressive overload\n• Try new fitness challenges\n• Recovery yoga on rest days\n\nEnergy levels peak around days 12-14 of your cycle.',
          },
          {
            'icon': Icons.restaurant_rounded,
            'bgColor': const Color(0xFFD4E8D4),
            'iconColor': const Color(0xFF2E7D32),
            'title': 'Nutrition for your cycle phase',
            'preview': 'Focus on iron-rich foods and leafy greens...',
            'body': 'Focus on iron-rich foods during menstruation and leafy greens throughout your cycle.\n\nFollicular phase essentials:\n• Iron-rich foods (spinach, lentils, red meat)\n• Vitamin C for iron absorption\n• Fermented foods for gut health\n• Complex carbs for sustained energy\n• Omega-3 fatty acids (salmon, walnuts)\n\nStay hydrated with at least 2L of water daily.',
          },
          {
            'icon': Icons.science_rounded,
            'bgColor': const Color(0xFFE8D4F8),
            'iconColor': const Color(0xFF8B1538),
            'title': 'Understanding your hormones',
            'preview': 'Estrogen, progesterone and testosterone work together...',
            'body': 'Estrogen, progesterone, and testosterone work together throughout your cycle to regulate mood, energy, and physical performance.\n\nCurrent phase (Follicular):\n• Estrogen: Rising\n• Progesterone: Low\n• Testosterone: Gradually increasing\n\nThis hormonal profile supports:\n• Better mood and motivation\n• Higher pain tolerance\n• Improved cognitive function\n• Increased social energy',
          },
          {
            'icon': Icons.bedtime_rounded,
            'bgColor': const Color(0xFFFFE8EE),
            'iconColor': const Color(0xFF8B1538),
            'title': 'Sleep quality and your cycle',
            'preview': 'Follicular phase often brings better sleep quality...',
            'body': 'During the follicular phase, rising estrogen promotes better sleep quality and may reduce sleep disturbances.\n\nTips for optimal rest:\n• Maintain consistent sleep/wake times\n• Aim for 7-8 hours\n• Keep your bedroom cool (18-20°C)\n• Limit caffeine after 2 PM\n• Try magnesium supplementation\n\nYour body temperature is lower this phase, aiding deeper sleep.',
          },
        ];
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  Expandable Insight Card
// ═══════════════════════════════════════════════════════════════

class _ExpandableInsightCard extends StatefulWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final String title;
  final String preview;
  final String body;

  const _ExpandableInsightCard({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.title,
    required this.preview,
    required this.body,
  });

  @override
  State<_ExpandableInsightCard> createState() => _ExpandableInsightCardState();
}

class _ExpandableInsightCardState extends State<_ExpandableInsightCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
          border: _expanded
              ? Border.all(color: widget.iconColor.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                        softWrap: true,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!_expanded) ...[
                        const SizedBox(height: 3),
                        Text(
                          widget.preview,
                          style: TextStyle(fontSize: 12.5, color: Colors.grey[500]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey[400],
                    size: 22,
                  ),
                ),
              ],
            ),
            // Expandable body
            SizeTransition(
              sizeFactor: _expandAnim,
              axisAlignment: -1,
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(
                  widget.body,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.6,
                    color: Colors.grey[700],
                  ),
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
