import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_info.dart';
import '../constants/app_strings.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_routes.dart';
import '../widgets/common/app_feedback.dart';
import '../widgets/settings/budget_dialog.dart';
import '../widgets/settings/settings_group.dart';
import '../widgets/settings/settings_sections.dart';
import 'privacy_policy_screen.dart';

/// Preferences: currency, theme, budget, alerts, data and about.
class SettingsScreen extends StatelessWidget {
  /// Creates the screen.
  const SettingsScreen({super.key});

  Future<void> _clearAll(BuildContext context) async {
    final confirmed = await AppFeedback.confirmDestructive(
      context,
      title: AppStrings.clearDataConfirmTitle,
      message: AppStrings.clearDataConfirmMessage,
      confirmLabel: AppStrings.delete,
    );
    if (!confirmed || !context.mounted) return;
    final provider = context.read<ExpenseProvider>();
    final ok = await provider.clearAll();
    if (!context.mounted) return;
    if (!ok) {
      AppFeedback.showSnack(context, AppStrings.errorClear, isError: true);
      return;
    }
    AppFeedback.showSnack(
      context,
      AppStrings.clearDataDone,
      actionLabel: AppStrings.undo,
      onAction: provider.undoClearAll,
    );
  }

  @override
  Widget build(BuildContext context) {
    final (
      hasBudget,
      budget,
    ) = context.select<SettingsProvider, (bool, String)>(
      (s) =>
          (s.settings.hasBudget, s.formatter.format(s.settings.monthlyBudget)),
    );
    final palette = context.palette;
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSizes.fabClearance,
              ),
              children: [
                const PreferencesSection(),
                SettingsGroup(
                  title: AppStrings.sectionBudget,
                  children: [
                    ListTile(
                      leading: SettingsIcon(
                        Icons.savings_rounded,
                        color: palette.success,
                      ),
                      title: const Text(AppStrings.budgetTitle),
                      subtitle: Text(
                        hasBudget ? budget : AppStrings.budgetNotSet,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => showBudgetDialog(context),
                    ),
                  ],
                ),
                const BudgetAlertsSection(),
                SettingsGroup(
                  title: AppStrings.sectionData,
                  children: [
                    ListTile(
                      leading: SettingsIcon(
                        Icons.delete_sweep_rounded,
                        color: palette.danger,
                      ),
                      title: Text(
                        AppStrings.settingClearData,
                        style: TextStyle(color: palette.danger),
                      ),
                      subtitle: const Text(AppStrings.settingClearDataSubtitle),
                      onTap: () => _clearAll(context),
                    ),
                  ],
                ),
                SettingsGroup(
                  title: AppStrings.sectionAbout,
                  children: [
                    ListTile(
                      leading: const SettingsIcon(Icons.privacy_tip_rounded),
                      title: const Text(AppStrings.settingPrivacy),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(
                        AppRoutes.fadeSlide<void>(const PrivacyPolicyScreen()),
                      ),
                    ),
                    const Divider(
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                    ),
                    const ListTile(
                      leading: SettingsIcon(Icons.info_rounded),
                      title: Text(AppStrings.settingVersion),
                      subtitle: Text(AppStrings.appName),
                      trailing: Text(AppInfo.version),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
