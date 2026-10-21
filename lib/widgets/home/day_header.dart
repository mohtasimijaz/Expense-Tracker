import 'dart:ui';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_theme.dart';
import '../../models/insight_models.dart';
import '../../utils/formatters.dart';

/// Sticky day header for the timeline: "Today · 3", a mini bar comparing
/// the day's total with the busiest visible day, and the total.
class DayHeaderDelegate extends SliverPersistentHeaderDelegate {
  /// Creates a header for [group]. [maxTotal] scales the mini bar.
  DayHeaderDelegate({
    required this.group,
    required this.maxTotal,
    required this.formatter,
    required this.background,
  });

  /// Height of every day header.
  static const double height = 48;

  final DayGroup group;
  final double maxTotal;
  final CurrencyFormatter formatter;

  /// Colour behind the header so list items scrolling under it are hidden.
  final Color background;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    // Persistent headers must fill their full extent, or the sliver reports
    // an invalid geometry when it reaches the viewport edge.
    final header = SizedBox.expand(
      child: DayHeader(group: group, maxTotal: maxTotal, formatter: formatter),
    );
    // Frosted background only while pinned over scrolling content.
    if (!overlaps) return header;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppEffects.glassBlur,
          sigmaY: AppEffects.glassBlur,
        ),
        child: ColoredBox(
          color: background.withValues(alpha: _pinnedOpacity),
          child: header,
        ),
      ),
    );
  }

  static const double _pinnedOpacity = 0.85;

  @override
  bool shouldRebuild(DayHeaderDelegate oldDelegate) =>
      oldDelegate.group.total != group.total ||
      oldDelegate.group.expenses.length != group.expenses.length ||
      oldDelegate.group.day != group.day ||
      oldDelegate.maxTotal != maxTotal ||
      oldDelegate.formatter != formatter ||
      oldDelegate.background != background;
}

/// The row inside [DayHeaderDelegate].
class DayHeader extends StatelessWidget {
  /// Creates the row.
  const DayHeader({
    super.key,
    required this.group,
    required this.maxTotal,
    required this.formatter,
  });

  static const double _barWidth = 56;

  final DayGroup group;
  final double maxTotal;
  final CurrencyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final share = maxTotal <= 0 ? 0.0 : group.total / maxTotal;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: Row(
        children: [
          Flexible(
            child: Text(
              AppDateFormat.relative(group.day),
              style: theme.textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs / 2,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(
                alpha: AppEffects.tintOpacity,
              ),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              '${group.expenses.length}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: _barWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: share),
                duration: AppDurations.slow,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: AppSizes.progressBarHeight / 2,
                  color: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: AppEffects.tintOpacity,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            formatter.format(group.total),
            style: theme.textTheme.titleSmall?.copyWith(
              color: context.palette.textSecondary,
              fontFeatures: AppTypography.tabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}
