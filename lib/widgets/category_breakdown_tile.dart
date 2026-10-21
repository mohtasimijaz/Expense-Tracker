import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../constants/app_theme.dart';
import '../constants/category_data.dart';
import '../models/statistics_models.dart';
import 'category_badge.dart';

/// A category row with its total, share and an animated progress bar.
class CategoryBreakdownTile extends StatelessWidget {
  /// Creates a tile for [total], rendering amounts with [format].
  const CategoryBreakdownTile({
    super.key,
    required this.total,
    required this.format,
  });

  static const int _percentScale = 100;

  final CategoryTotal total;
  final String Function(double value) format;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = CategoryData.byId(total.categoryId);
    final color = category.colorFor(theme.brightness);
    final percent = (total.share * _percentScale).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          CategoryIcon(categoryId: category.id, size: AppSizes.avatar - 8),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.label,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          format(total.total),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontFeatures: AppTypography.tabularFigures,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: total.share),
                          duration: AppDurations.slow,
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) =>
                              LinearProgressIndicator(
                                value: value,
                                minHeight: AppSizes.progressBarHeight,
                                color: color,
                                backgroundColor: color.withValues(
                                  alpha: AppEffects.tintOpacity,
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    SizedBox(
                      width: AppSpacing.xl + AppSpacing.xs,
                      child: Text(
                        '$percent%',
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
