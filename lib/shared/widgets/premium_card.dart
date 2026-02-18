import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_shadows.dart';

enum CardType { elevated, flat, gradient }

/// Premium card component with consistent styling
class PremiumCard extends StatelessWidget {
  final Widget child;
  final CardType type;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double? borderRadius;

  const PremiumCard({
    super.key,
    required this.child,
    this.type = CardType.elevated,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.onTap,
    this.borderRadius,
  });

  const PremiumCard.flat({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.borderRadius,
  })  : type = CardType.flat,
        gradient = null;

  const PremiumCard.gradient({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
  })  : type = CardType.gradient,
        color = null;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.cardPadding);
    final effectiveMargin = margin ?? EdgeInsets.zero;
    final effectiveBorderRadius = borderRadius ?? AppSpacing.lg;

    Widget card = Container(
      margin: effectiveMargin,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        boxShadow: type == CardType.elevated ? AppShadows.cardShadow : null,
      ),
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: card,
        ),
      );
    }

    return card;
  }
}
