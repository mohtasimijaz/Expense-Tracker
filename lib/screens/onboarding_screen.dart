import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../providers/settings_provider.dart';
import '../utils/app_routes.dart';
import '../widgets/common/finance_background.dart';
import '../widgets/onboarding_controls.dart';
import '../widgets/onboarding_page.dart';
import 'main_shell.dart';

/// Three-page introduction shown on first launch only.
class OnboardingScreen extends StatefulWidget {
  /// Creates the onboarding flow.
  const OnboardingScreen({super.key});

  /// Page contents, in order.
  static const List<OnboardingContent> pages = [
    OnboardingContent(
      icon: Icons.receipt_long_rounded,
      title: AppStrings.onboardingTitle1,
      body: AppStrings.onboardingBody1,
      satellites: [
        Icons.restaurant_rounded,
        Icons.directions_car_rounded,
        Icons.shopping_bag_rounded,
      ],
    ),
    OnboardingContent(
      icon: Icons.insights_rounded,
      title: AppStrings.onboardingTitle2,
      body: AppStrings.onboardingBody2,
      satellites: [
        Icons.pie_chart_rounded,
        Icons.bar_chart_rounded,
        Icons.trending_up_rounded,
      ],
    ),
    OnboardingContent(
      icon: Icons.savings_rounded,
      title: AppStrings.onboardingTitle3,
      body: AppStrings.onboardingBody3,
      satellites: [
        Icons.notifications_active_rounded,
        Icons.flag_rounded,
        Icons.verified_rounded,
      ],
    ),
  ];

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final ValueNotifier<int> _page = ValueNotifier(0);

  bool get _isLast => _page.value == OnboardingScreen.pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    _page.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<SettingsProvider>().completeOnboarding();
    if (!mounted) return;
    await Navigator.of(
      context,
    ).pushReplacement(AppRoutes.fade<void>(const MainShell()));
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: FinanceBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: _page,
                builder: (context, page, _) => Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: AnimatedOpacity(
                        opacity: _isLast ? 0 : 1,
                        duration: AppDurations.fast,
                        child: TextButton(
                          onPressed: _isLast ? null : _finish,
                          child: const Text(AppStrings.onboardingSkip),
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _controller,
                        onPageChanged: (i) => _page.value = i,
                        children: [
                          for (final content in OnboardingScreen.pages)
                            OnboardingPage(content: content),
                        ],
                      ),
                    ),
                    PageDots(
                      count: OnboardingScreen.pages.length,
                      current: page,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: FilledButton(
                        onPressed: _next,
                        child: AnimatedSwitcher(
                          duration: AppDurations.fast,
                          child: Text(
                            _isLast
                                ? AppStrings.onboardingStart
                                : AppStrings.onboardingNext,
                            key: ValueKey(_isLast),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: PrivacyFooter(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
