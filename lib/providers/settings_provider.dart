import 'package:flutter/material.dart';

import '../constants/currency_data.dart';
import '../models/app_currency.dart';
import '../models/app_settings.dart';
import '../services/monitoring_service.dart';
import '../services/settings_service.dart';
import '../utils/formatters.dart';

/// Holds user preferences (theme, currency, budget, alerts, onboarding).
///
/// Every change is applied immediately for a snappy UI and rolled back if
/// it cannot be persisted.
class SettingsProvider extends ChangeNotifier {
  /// Creates the provider.
  SettingsProvider(
    this._service, {
    MonitoringService monitoring = const NoopMonitoringService(),
  }) : _monitoring = monitoring,
       _settings = _service.defaults;

  final SettingsService _service;
  final MonitoringService _monitoring;
  AppSettings _settings;
  CurrencyFormatter? _formatter;
  bool _loaded = false;

  /// Current settings.
  AppSettings get settings => _settings;

  /// Whether saved settings have been read.
  bool get isLoaded => _loaded;

  ThemeMode get themeMode => _settings.themeMode;

  /// The selected currency.
  AppCurrency get currency =>
      CurrencyData.tryByCode(_settings.currencyCode) ?? CurrencyData.fallback;

  /// Formatter for the selected currency (cached until it changes).
  CurrencyFormatter get formatter {
    final cached = _formatter;
    if (cached != null && cached.currency == currency) return cached;
    return _formatter = CurrencyFormatter(currency);
  }

  /// Reads saved settings from storage.
  Future<void> load() async {
    _settings = await _service.load();
    _loaded = true;
    notifyListeners();
  }

  /// Switches between system, light and dark themes.
  Future<bool> setThemeMode(ThemeMode mode) async {
    final ok = await _update(_settings.copyWith(themeMode: mode));
    if (ok) {
      await _monitoring.logEvent(AnalyticsEvents.themeChanged, {
        AnalyticsEvents.paramValue: mode.name,
      });
    }
    return ok;
  }

  /// Selects the currency with ISO [code]. Unknown codes are rejected.
  Future<bool> setCurrency(String code) async {
    final currency = CurrencyData.tryByCode(code);
    if (currency == null) return false;
    final ok = await _update(_settings.copyWith(currencyCode: currency.code));
    if (ok) {
      await _monitoring.logEvent(AnalyticsEvents.currencyChanged, {
        AnalyticsEvents.paramValue: currency.code,
      });
    }
    return ok;
  }

  /// Sets the monthly budget; `0` removes it. Negative values are rejected.
  Future<bool> setMonthlyBudget(double amount) async {
    if (amount.isNaN || amount.isInfinite || amount < 0) return false;
    final ok = await _update(_settings.copyWith(monthlyBudget: amount));
    if (ok) await _monitoring.logEvent(AnalyticsEvents.budgetSet);
    return ok;
  }

  /// Turns in-app budget alerts on or off.
  Future<bool> setBudgetAlertsEnabled(bool enabled) =>
      _update(_settings.copyWith(budgetAlertsEnabled: enabled));

  /// Sets the warning threshold, clamped to the allowed range.
  Future<bool> setAlertThreshold(int percent) => _update(
    _settings.copyWith(
      alertThresholdPercent: percent.clamp(
        AppSettings.minThresholdPercent,
        AppSettings.maxThresholdPercent,
      ),
    ),
  );

  /// Marks onboarding as done so it is not shown again.
  Future<bool> completeOnboarding() async {
    final ok = await _update(_settings.copyWith(onboardingComplete: true));
    if (ok) await _monitoring.logEvent(AnalyticsEvents.onboardingCompleted);
    return ok;
  }

  /// Turns vibration feedback on or off.
  Future<bool> setHapticsEnabled(bool enabled) =>
      _update(_settings.copyWith(hapticsEnabled: enabled));

  /// Hides the "swipe to delete / hold for options" tip for good.
  Future<bool> dismissGestureHint() =>
      _update(_settings.copyWith(gestureHintDismissed: true));

  /// Remembers that the under-budget celebration for [monthKey] was shown.
  Future<bool> markMonthCelebrated(String monthKey) =>
      _update(_settings.copyWith(celebratedMonthKey: monthKey));

  /// Remembers that [length] days of the streak starting [start] was
  /// celebrated.
  Future<bool> markStreakCelebrated(DateTime start, int length) => _update(
    _settings.copyWith(
      celebratedStreakStart: start,
      celebratedStreakLength: length,
    ),
  );

  Future<bool> _update(AppSettings next) async {
    final previous = _settings;
    _settings = next;
    notifyListeners();
    final saved = await _service.save(next);
    if (!saved) {
      _settings = previous;
      notifyListeners();
    }
    return saved;
  }
}
