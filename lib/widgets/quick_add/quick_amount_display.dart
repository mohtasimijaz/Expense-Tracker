import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../../utils/formatters.dart';
import '../common/rolling_text.dart';

/// The big amount at the top of the quick-add sheet: currency symbol plus
/// odometer digits, and "Today" underneath.
class QuickAmountDisplay extends StatelessWidget {
  /// Creates the display for the typed [raw] amount.
  const QuickAmountDisplay({super.key, required this.raw});

  static const double _amountSize = 48;

  final String raw;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = context.select<SettingsProvider, CurrencyFormatter>(
      (s) => s.formatter,
    );
    final empty = raw.isEmpty;
    final style = theme.textTheme.displaySmall?.copyWith(
      fontSize: _amountSize,
      fontFeatures: AppTypography.tabularFigures,
      color: empty ? context.palette.textSecondary : null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  formatter.symbol,
                  style: style?.copyWith(color: theme.colorScheme.primary),
                ),
                const SizedBox(width: AppSpacing.xs),
                RollingText(formatter.typing(raw), style: style),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_rounded,
                size: AppSizes.iconSm,
                color: context.palette.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(AppStrings.today, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
