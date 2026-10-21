import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';

/// Rounded card with a title, used to frame every chart.
class ChartCard extends StatelessWidget {
  /// Creates a card with [title] and optional [trailing] widget.
  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailingWidget = trailing;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadow,
            blurRadius: AppEffects.shadowBlur,
            offset: const Offset(0, AppEffects.shadowOffsetY / 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wrap lets a wide trailing control (e.g. a segmented toggle)
          // drop below the title on narrow phones instead of overflowing.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              ?trailingWidget,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

/// Helpers shared by the charts.
abstract final class ChartStyle {
  static final NumberFormat _axis = NumberFormat.compact(locale: 'en');

  /// Head-room above the tallest bar/point.
  static const double headroom = 1.2;

  /// Max Y used when every value is zero, so the chart still renders.
  static const double emptyMaxY = 1;

  /// Number of horizontal grid lines.
  static const int gridLines = 4;

  /// Compact axis label such as `1.2K`.
  static String axisLabel(double value) => _axis.format(value);

  /// Y-axis maximum for [values].
  static double maxY(Iterable<double> values) {
    final max = values.fold<double>(0, (m, v) => v > m ? v : m);
    return max <= 0 ? emptyMaxY : max * headroom;
  }

  /// Small axis text style.
  static TextStyle? axisStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall;
}
