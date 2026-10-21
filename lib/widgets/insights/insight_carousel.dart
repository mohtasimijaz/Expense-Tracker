import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../models/insight_models.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../screens/recap_screen.dart';
import '../../utils/app_haptics.dart';
import '../../utils/app_routes.dart';
import '../../utils/formatters.dart';
import '../common/pressable_scale.dart';
import 'insight_presentation.dart';

/// Swipeable row of insight cards on Home. Hidden when there is nothing
/// to say yet.
class InsightCarousel extends StatefulWidget {
  /// Creates the carousel.
  const InsightCarousel({super.key});

  @override
  State<InsightCarousel> createState() => _InsightCarouselState();
}

class _InsightCarouselState extends State<InsightCarousel> {
  static const double _height = 128;
  static const double _viewport = 0.9;

  final PageController _pages = PageController(viewportFraction: _viewport);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _open(Insight insight) {
    if (insight.kind != InsightKind.monthRecap) return;
    AppHaptics.play(context, HapticKind.light);
    Navigator.of(context).push(
      AppRoutes.fadeSlide<void>(
        RecapScreen(month: insight.month ?? DateTime.now()),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.select<SettingsProvider, double>(
      (s) => s.settings.monthlyBudget,
    );
    final insights = context.watch<ExpenseProvider>().insights.insights(
      budget: budget,
    );
    if (insights.isEmpty) return const SizedBox.shrink();
    final formatter = context.select<SettingsProvider, CurrencyFormatter>(
      (s) => s.formatter,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Text(
            AppStrings.insightsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: _height,
          child: PageView.builder(
            controller: _pages,
            padEnds: false,
            itemCount: insights.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: InsightCard(
                insight: insights[i],
                presentation: InsightPresentation.of(insights[i], formatter),
                onTap: insights[i].kind == InsightKind.monthRecap
                    ? () => _open(insights[i])
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One insight: tinted by tone (green good, red warning, brand for the
/// recap), with an icon, title and message.
class InsightCard extends StatelessWidget {
  /// Creates a card.
  const InsightCard({
    super.key,
    required this.insight,
    required this.presentation,
    this.onTap,
  });

  final Insight insight;
  final InsightPresentation presentation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final isRecap = insight.kind == InsightKind.monthRecap;
    final accent = switch (insight.tone) {
      InsightTone.positive => palette.success,
      InsightTone.negative => palette.danger,
      InsightTone.neutral => theme.colorScheme.primary,
    };
    final onCard = isRecap ? AppColors.white : null;
    return PressableScale(
      onTap: onTap,
      semanticLabel: '${presentation.title}. ${presentation.message}',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: isRecap ? palette.brandGradient : null,
          color: isRecap ? null : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: accent.withValues(alpha: AppEffects.glassBorderOpacity),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (onCard ?? accent).withValues(
                  alpha: AppEffects.tintOpacity * (isRecap ? 1.5 : 1),
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(presentation.icon, color: onCard ?? accent),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    presentation.title,
                    style: theme.textTheme.titleSmall?.copyWith(color: onCard),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    presentation.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onCard ?? palette.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isRecap)
              const Icon(Icons.chevron_right_rounded, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
