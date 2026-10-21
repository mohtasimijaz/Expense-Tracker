import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../constants/category_data.dart';

/// Small pill showing a category's icon and name.
class CategoryBadge extends StatelessWidget {
  /// Creates a badge for [categoryId].
  const CategoryBadge({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final category = CategoryData.byId(categoryId);
    final theme = Theme.of(context);
    final color = category.colorFor(theme.brightness);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs / 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppEffects.tintOpacity),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: AppSizes.iconXs, color: color),
          const SizedBox(width: AppSpacing.xxs),
          Flexible(
            child: Text(
              category.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular tinted icon for a category. Pass [heroTag] to animate it
/// between the list and the edit screen.
class CategoryIcon extends StatelessWidget {
  /// Creates a category icon of diameter [size].
  const CategoryIcon({
    super.key,
    required this.categoryId,
    this.size = AppSizes.avatar,
    this.heroTag,
  });

  final String categoryId;
  final double size;
  final Object? heroTag;

  static const double _iconScale = 0.5;

  @override
  Widget build(BuildContext context) {
    final category = CategoryData.byId(categoryId);
    final color = category.colorFor(Theme.of(context).brightness);
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppEffects.tintOpacity),
        borderRadius: BorderRadius.circular(size / 2.6),
      ),
      child: Icon(category.icon, color: color, size: size * _iconScale),
    );
    final tag = heroTag;
    return tag == null ? circle : Hero(tag: tag, child: circle);
  }
}
