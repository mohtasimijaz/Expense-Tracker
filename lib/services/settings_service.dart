import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/currency_data.dart';
import '../models/app_settings.dart';

/// Loads and saves [AppSettings] using shared_preferences.
class SettingsService {
  /// Creates the service. [regionCode] is the device's country code (e.g.
  /// `PK`), used to pick a default currency on first launch.
  SettingsService({String? regionCode}) : _regionCode = regionCode;

  static const String _keyThemeMode = 'settings.themeMode';
  static const String _keyCurrency = 'settings.currencyCode';
  static const String _keyBudget = 'settings.monthlyBudget';
  static const String _keyAlerts = 'settings.budgetAlerts';
  static const String _keyThreshold = 'settings.alertThreshold';
  static const String _keyOnboarding = 'settings.onboardingComplete';

  final String? _regionCode;
  SharedPreferences? _prefs;

  /// Default settings for this device.
  AppSettings get defaults =>
      AppSettings.defaults(CurrencyData.forCountry(_regionCode).code);

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Reads saved settings. Missing or invalid values fall back to [defaults];
  /// if storage is unavailable the defaults are returned.
  Future<AppSettings> load() async {
    final fallback = defaults;
    try {
      final prefs = await _instance;
      final themeIndex = prefs.getInt(_keyThemeMode);
      final currency = CurrencyData.tryByCode(prefs.getString(_keyCurrency));
      final budget = prefs.getDouble(_keyBudget);
      final threshold = prefs.getInt(_keyThreshold);
      return AppSettings(
        themeMode:
            themeIndex != null &&
                themeIndex >= 0 &&
                themeIndex < ThemeMode.values.length
            ? ThemeMode.values[themeIndex]
            : fallback.themeMode,
        currencyCode: currency?.code ?? fallback.currencyCode,
        monthlyBudget: budget != null && budget >= 0 && budget.isFinite
            ? budget
            : fallback.monthlyBudget,
        budgetAlertsEnabled:
            prefs.getBool(_keyAlerts) ?? fallback.budgetAlertsEnabled,
        alertThresholdPercent:
            threshold != null &&
                threshold >= AppSettings.minThresholdPercent &&
                threshold <= AppSettings.maxThresholdPercent
            ? threshold
            : fallback.alertThresholdPercent,
        onboardingComplete:
            prefs.getBool(_keyOnboarding) ?? fallback.onboardingComplete,
      );
    } catch (_) {
      return fallback;
    }
  }

  /// Persists [settings]. Returns `false` if storage failed.
  Future<bool> save(AppSettings settings) async {
    try {
      final prefs = await _instance;
      final results = await Future.wait([
        prefs.setInt(_keyThemeMode, settings.themeMode.index),
        prefs.setString(_keyCurrency, settings.currencyCode),
        prefs.setDouble(_keyBudget, settings.monthlyBudget),
        prefs.setBool(_keyAlerts, settings.budgetAlertsEnabled),
        prefs.setInt(_keyThreshold, settings.alertThresholdPercent),
        prefs.setBool(_keyOnboarding, settings.onboardingComplete),
      ]);
      return results.every((ok) => ok);
    } catch (_) {
      return false;
    }
  }
}
