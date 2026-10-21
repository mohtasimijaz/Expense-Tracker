import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_routes.dart';
import '../widgets/common/finance_background.dart';
import '../widgets/common/status_views.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

/// Animated splash shown while expenses load from the database.
class SplashScreen extends StatefulWidget {
  /// Creates the splash screen.
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Loading notifies listeners, which is not allowed while the first
    // frame is still being built — so start right after it.
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  /// Loads data (at least [AppDurations.splashMinimum] so the animation is
  /// seen) and then routes to onboarding or the main shell.
  Future<void> _start() async {
    final expenses = context.read<ExpenseProvider>();
    final settings = context.read<SettingsProvider>();
    await Future.wait([
      if (expenses.status == LoadStatus.initial) expenses.loadExpenses(),
      Future<void>.delayed(AppDurations.splashMinimum),
    ]);
    if (!mounted) return;
    final Widget next = settings.settings.onboardingComplete
        ? const MainShell()
        : const OnboardingScreen();
    await Navigator.of(context).pushReplacement(AppRoutes.fade<void>(next));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animate = AppMotion.enabled(context);
    final duration = animate ? AppDurations.slow : Duration.zero;
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: FinanceBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo()
                  .animate()
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    curve: Curves.easeOutBack,
                    duration: duration,
                  )
                  .fadeIn(duration: duration),
              const SizedBox(height: AppSpacing.lg),
              Text(AppStrings.appName, style: theme.textTheme.headlineSmall)
                  .animate(delay: animate ? AppDurations.medium : Duration.zero)
                  .fadeIn(duration: duration)
                  .slideY(begin: animate ? 0.3 : 0, end: 0),
              const SizedBox(height: AppSpacing.xs),
              Text(
                    AppStrings.appTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  )
                  .animate(delay: animate ? AppDurations.slow : Duration.zero)
                  .fadeIn(duration: duration),
              const SizedBox(height: AppSpacing.xl),
              const LoadingView(message: null),
            ],
          ),
        ),
      ),
    );
  }
}
