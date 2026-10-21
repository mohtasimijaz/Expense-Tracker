import 'package:expense_tracker/models/app_settings.dart';
import 'package:expense_tracker/providers/settings_provider.dart';
import 'package:expense_tracker/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<SettingsProvider> create({String? region}) async {
    final provider = SettingsProvider(SettingsService(regionCode: region));
    await provider.load();
    return provider;
  }

  test('defaults follow the device region', () async {
    expect((await create(region: 'PK')).currency.code, 'PKR');
    expect((await create(region: 'in')).currency.code, 'INR');
    expect((await create(region: 'DE')).currency.code, 'EUR');
    expect((await create(region: 'ZZ')).currency.code, 'USD');
    expect((await create()).currency.code, 'USD');
  });

  test('first launch defaults', () async {
    final s = (await create()).settings;
    expect(s.themeMode, ThemeMode.system);
    expect(s.monthlyBudget, 0);
    expect(s.hasBudget, isFalse);
    expect(s.budgetAlertsEnabled, isTrue);
    expect(s.alertThresholdPercent, AppSettings.defaultThresholdPercent);
    expect(s.onboardingComplete, isFalse);
  });

  test('dark mode toggle persists across restarts', () async {
    final provider = await create();
    expect(await provider.setThemeMode(ThemeMode.dark), isTrue);
    expect(provider.themeMode, ThemeMode.dark);
    expect((await create()).themeMode, ThemeMode.dark);

    await provider.setThemeMode(ThemeMode.light);
    expect((await create()).themeMode, ThemeMode.light);
  });

  test('currency, budget, alerts and onboarding persist', () async {
    final provider = await create(region: 'PK');
    expect(await provider.setCurrency('jpy'), isTrue);
    expect(await provider.setMonthlyBudget(50000), isTrue);
    expect(await provider.setBudgetAlertsEnabled(false), isTrue);
    expect(await provider.setAlertThreshold(90), isTrue);
    expect(await provider.completeOnboarding(), isTrue);

    final reloaded = (await create(region: 'PK')).settings;
    expect(reloaded.currencyCode, 'JPY');
    expect(reloaded.monthlyBudget, 50000);
    expect(reloaded.budgetAlertsEnabled, isFalse);
    expect(reloaded.alertThresholdPercent, 90);
    expect(reloaded.onboardingComplete, isTrue);
  });

  test('invalid values are rejected or clamped', () async {
    final provider = await create();
    expect(await provider.setCurrency('NOPE'), isFalse);
    expect(await provider.setMonthlyBudget(-5), isFalse);
    expect(await provider.setMonthlyBudget(double.nan), isFalse);
    await provider.setAlertThreshold(10);
    expect(
      provider.settings.alertThresholdPercent,
      AppSettings.minThresholdPercent,
    );
    await provider.setAlertThreshold(500);
    expect(
      provider.settings.alertThresholdPercent,
      AppSettings.maxThresholdPercent,
    );
  });

  test('corrupted stored values fall back to defaults', () async {
    SharedPreferences.setMockInitialValues({
      'settings.themeMode': 99,
      'settings.currencyCode': 'XXX',
      'settings.monthlyBudget': -1.0,
      'settings.alertThreshold': 5,
    });
    final s = (await create(region: 'PK')).settings;
    expect(s.themeMode, ThemeMode.system);
    expect(s.currencyCode, 'PKR');
    expect(s.monthlyBudget, 0);
    expect(s.alertThresholdPercent, AppSettings.defaultThresholdPercent);
  });

  test('formatter uses the selected currency', () async {
    final provider = await create(region: 'US');
    expect(provider.formatter.format(1234.5), r'$1,234.50');
    await provider.setCurrency('JPY');
    expect(provider.formatter.format(1234), contains('1,234'));
    expect(provider.formatter.format(1234), isNot(contains('.')));
  });
}
