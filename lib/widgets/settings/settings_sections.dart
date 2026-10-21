import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../models/app_settings.dart';
import '../../providers/settings_provider.dart';
import '../../screens/currency_picker_screen.dart';
import '../../utils/app_routes.dart';
import '../common/app_feedback.dart';
import 'settings_group.dart';

/// Awaits a settings [change] and shows an error snackbar if it failed.
Future<void> applySetting(BuildContext context, Future<bool> change) async {
  final ok = await change;
  if (!ok && context.mounted) {
    AppFeedback.showSnack(context, AppStrings.errorSettings, isError: true);
  }
}

/// Currency and theme settings.
class PreferencesSection extends StatelessWidget {
  /// Creates the section.
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final currency = provider.currency;
    final theme = Theme.of(context);
    return SettingsGroup(
      title: AppStrings.sectionPreferences,
      children: [
        ListTile(
          leading: const SettingsIcon(Icons.currency_exchange_rounded),
          title: const Text(AppStrings.settingCurrency),
          subtitle: Text('${currency.name} (${currency.code})'),
          trailing: Text(currency.symbol, style: theme.textTheme.titleMedium),
          onTap: () => Navigator.of(
            context,
          ).push(AppRoutes.fadeSlide<void>(const CurrencyPickerScreen())),
        ),
        const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
        const ListTile(
          leading: SettingsIcon(Icons.palette_rounded),
          title: Text(AppStrings.settingTheme),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto_rounded),
                label: Text(AppStrings.themeSystem),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_rounded),
                label: Text(AppStrings.themeLight),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_rounded),
                label: Text(AppStrings.themeDark),
              ),
            ],
            selected: {provider.themeMode},
            onSelectionChanged: (s) =>
                applySetting(context, provider.setThemeMode(s.first)),
          ),
        ),
        const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
        SwitchListTile(
          secondary: const SettingsIcon(Icons.vibration_rounded),
          title: const Text(AppStrings.settingHaptics),
          subtitle: const Text(AppStrings.settingHapticsSubtitle),
          value: provider.settings.hapticsEnabled,
          onChanged: (v) =>
              applySetting(context, provider.setHapticsEnabled(v)),
        ),
      ],
    );
  }
}

/// Budget alert on/off switch and the warning threshold slider.
class BudgetAlertsSection extends StatelessWidget {
  /// Creates the section.
  const BudgetAlertsSection({super.key});

  static const int _thresholdStep = 5;
  static const int _steps =
      (AppSettings.maxThresholdPercent - AppSettings.minThresholdPercent) ~/
      _thresholdStep;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final settings = provider.settings;
    final enabled = settings.budgetAlertsEnabled;
    final percent = settings.alertThresholdPercent;
    return SettingsGroup(
      title: AppStrings.sectionNotifications,
      children: [
        SwitchListTile(
          secondary: SettingsIcon(
            Icons.notifications_active_rounded,
            color: context.palette.warning,
          ),
          title: const Text(AppStrings.settingBudgetAlerts),
          subtitle: const Text(AppStrings.settingBudgetAlertsSubtitle),
          value: enabled,
          onChanged: (v) =>
              applySetting(context, provider.setBudgetAlertsEnabled(v)),
        ),
        ListTile(
          enabled: enabled,
          title: Text(
            '${AppStrings.settingAlertThreshold} $percent'
            '${AppStrings.settingAlertThresholdSuffix}',
          ),
          subtitle: Slider(
            value: percent.toDouble(),
            min: AppSettings.minThresholdPercent.toDouble(),
            max: AppSettings.maxThresholdPercent.toDouble(),
            divisions: _steps,
            label: '$percent%',
            onChanged: enabled
                ? (v) => applySetting(
                    context,
                    provider.setAlertThreshold(v.round()),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
