import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_theme.dart';
import 'animated_counter.dart';

/// Compact stat tile with an icon, an animated value and a label.
class SummaryCard extends StatelessWidget {
  /// Creates a tile. [format] renders the animated [value].
  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.format,
    required this.icon,
    required this.color,
  });

  final String label;
  final double value;
  final String Function(double value) format;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadow,
            blurRadius: AppEffects.shadowBlur / 2,
            offset: const Offset(0, AppEffects.shadowOffsetY / 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxs + 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: AppEffects.tintOpacity),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: AppSizes.iconMd),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedCounter(
              value: value,
              format: format,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
          ),
          // Scales down on narrow phones rather than truncating the label.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(label, style: theme.textTheme.bodySmall, maxLines: 1),
          ),
        ],
      ),
    );
  }
}
