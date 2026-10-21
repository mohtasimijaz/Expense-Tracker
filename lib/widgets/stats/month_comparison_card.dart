import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_theme.dart';
import '../../models/statistics_models.dart';
import '../animated_counter.dart';

/// This month vs last month with a coloured percentage change.
/// Spending more is shown in red, spending less in green.
class MonthComparisonCard extends StatelessWidget {
  /// Creates the card.
  const MonthComparisonCard({
    super.key,
    required this.comparison,
    required this.format,
  });

  final MonthComparison comparison;
  final String Function(double value) format;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final change = comparison.changePercent;
    final (Color color, IconData icon, String text) = switch (change) {
      null => (
        palette.textSecondary,
        Icons.remove_rounded,
        AppStrings.statsNoPreviousMonth,
      ),
      final c when c > 0 => (
        palette.danger,
        Icons.trending_up_rounded,
        '${c.abs().toStringAsFixed(1)}% ${AppStrings.statsMoreThanLastMonth}',
      ),
      final c when c < 0 => (
        palette.success,
        Icons.trending_down_rounded,
        '${c.abs().toStringAsFixed(1)}% ${AppStrings.statsLessThanLastMonth}',
      ),
      _ => (
        palette.textSecondary,
        Icons.trending_flat_rounded,
        AppStrings.statsSameAsLastMonth,
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _Amount(
                label: AppStrings.statsThisMonth,
                value: comparison.current,
                format: format,
              ),
            ),
            Expanded(
              child: _Amount(
                label: AppStrings.statsLastMonth,
                value: comparison.previous,
                format: format,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: AppEffects.tintOpacity),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: AppSizes.iconMd),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({
    required this.label,
    required this.value,
    required this.format,
  });

  final String label;
  final double value;
  final String Function(double value) format;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: AnimatedCounter(
            value: value,
            format: format,
            style: theme.textTheme.titleLarge?.copyWith(
              fontFeatures: AppTypography.tabularFigures,
            ),
          ),
        ),
      ],
    );
  }
}
