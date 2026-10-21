import 'package:flutter/material.dart';

/// User preferences, stored with shared_preferences.
@immutable
class AppSettings {
  /// Creates a settings snapshot.
  const AppSettings({
    required this.themeMode,
    required this.currencyCode,
    required this.monthlyBudget,
    required this.budgetAlertsEnabled,
    required this.alertThresholdPercent,
    required this.onboardingComplete,
  });

  /// Lowest selectable alert threshold.
  static const int minThresholdPercent = 50;

  /// Highest selectable alert threshold.
  static const int maxThresholdPercent = 100;

  /// Default alert threshold.
  static const int defaultThresholdPercent = 80;

  /// Defaults used on first launch. [currencyCode] comes from the device region.
  factory AppSettings.defaults(String currencyCode) => AppSettings(
    themeMode: ThemeMode.system,
    currencyCode: currencyCode,
    monthlyBudget: 0,
    budgetAlertsEnabled: true,
    alertThresholdPercent: defaultThresholdPercent,
    onboardingComplete: false,
  );

  final ThemeMode themeMode;

  /// ISO 4217 code of the selected currency.
  final String currencyCode;

  /// Monthly spending limit; `0` means no budget is set.
  final double monthlyBudget;

  /// Whether in-app budget alerts are shown.
  final bool budgetAlertsEnabled;

  /// Percentage of the budget at which a warning is shown.
  final int alertThresholdPercent;

  /// Whether the onboarding flow has been completed.
  final bool onboardingComplete;

  /// Whether a monthly budget is configured.
  bool get hasBudget => monthlyBudget > 0;

  /// Returns a copy with the given fields replaced.
  AppSettings copyWith({
    ThemeMode? themeMode,
    String? currencyCode,
    double? monthlyBudget,
    bool? budgetAlertsEnabled,
    int? alertThresholdPercent,
    bool? onboardingComplete,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      currencyCode: currencyCode ?? this.currencyCode,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      alertThresholdPercent:
          alertThresholdPercent ?? this.alertThresholdPercent,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}
