import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../utils/app_routes.dart';
import '../widgets/common/finance_background.dart';
import '../widgets/common/glass_container.dart';
import 'add_expense_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

/// Root layout after onboarding: Home, Statistics and Settings tabs with a
/// frosted-glass navigation bar and the "add expense" button.
class MainShell extends StatefulWidget {
  /// Creates the shell.
  const MainShell({super.key});

  /// Tab index of Settings (the add button is hidden there).
  static const int settingsTab = 2;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final ValueNotifier<int> _tab = ValueNotifier(0);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _openAdd() {
    Navigator.of(context).push(
      AppRoutes.fadeSlide<void>(
        const AddExpenseScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _tab,
      // One shared background behind all tabs, including their app bars.
      builder: (context, tab, _) => FinanceBackground(
        child: PopScope(
          canPop: tab == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _tab.value = 0;
          },
          child: Scaffold(
            extendBody: true,
            backgroundColor: AppColors.transparent,
            body: IndexedStack(
              index: tab,
              children: [
                HomeScreen(onAdd: _openAdd),
                const StatisticsScreen(),
                const SettingsScreen(),
              ],
            ),
            floatingActionButton: AnimatedScale(
              scale: tab == MainShell.settingsTab ? 0 : 1,
              duration: AppDurations.medium,
              curve: Curves.easeOutBack,
              child: FloatingActionButton.extended(
                heroTag: AddExpenseScreen.addHeroTag,
                onPressed: tab == MainShell.settingsTab ? null : _openAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text(AppStrings.addFirstExpense),
              ),
            ),
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: GlassContainer(
                padding: EdgeInsets.zero,
                opacity: context.isDarkMode ? AppEffects.glassOpacity : 0.7,
                child: NavigationBar(
                  selectedIndex: tab,
                  onDestinationSelected: (i) => _tab.value = i,
                  height: AppSizes.buttonHeight + AppSpacing.md,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: AppStrings.navHome,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.insights_outlined),
                      selectedIcon: Icon(Icons.insights_rounded),
                      label: AppStrings.navStatistics,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings_rounded),
                      label: AppStrings.navSettings,
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
