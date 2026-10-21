import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/constants/app_theme.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/settings_provider.dart';
import 'package:expense_tracker/screens/main_shell.dart';
import 'package:expense_tracker/services/settings_service.dart';
import 'package:expense_tracker/widgets/home/tilt_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

/// Phone-sized test surface (logical 400×860).
const Size phoneSize = Size(400, 860);

/// Everything a widget test needs to inspect after pumping the app.
class TestApp {
  TestApp(this.repository, this.settings);

  final InMemoryExpenseRepository repository;
  final SettingsProvider settings;
}

/// Pumps the full app with an in-memory database.
///
/// When [home] is null the main shell is shown with expenses already
/// loaded (skipping splash/onboarding).
Future<TestApp> pumpApp(
  WidgetTester tester, {
  List<Expense> initial = const [],
  Widget? home,
  Map<String, Object> prefs = const {'settings.onboardingComplete': true},
  Size size = phoneSize,
}) async {
  AppTypography.useGoogleFonts = false;
  TiltCard.sensorsEnabled = false;
  SharedPreferences.setMockInitialValues(prefs);
  tester.view.physicalSize = size * tester.view.devicePixelRatio;
  addTearDown(tester.view.resetPhysicalSize);

  final repository = InMemoryExpenseRepository(initial);
  final settings = SettingsProvider(SettingsService(regionCode: 'PK'));
  await settings.load();

  await tester.pumpWidget(
    ExpenseTrackerApp(
      repository: repository,
      settings: settings,
      home: home ?? const MainShell(),
    ),
  );
  if (home == null) {
    final context = tester.element(find.byType(MainShell));
    await context.read<ExpenseProvider>().loadExpenses();
  }
  await settle(tester);
  return TestApp(repository, settings);
}

/// Advances time enough for entrance animations to finish. (Lottie loops
/// forever, so `pumpAndSettle` cannot be used.)
Future<void> settle(
  WidgetTester tester, [
  Duration total = const Duration(seconds: 2),
]) async {
  const step = Duration(milliseconds: 100);
  for (var elapsed = Duration.zero; elapsed < total; elapsed += step) {
    await tester.pump(step);
  }
}

/// Scrolls the home list until [finder] is built and visible.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 60,
  );
  await tester.pump(const Duration(milliseconds: 300));
}

/// Scrolls the home list to the very end (like a user would before
/// swiping the last item, so it is clear of the nav bar and + button).
Future<void> scrollToEnd(WidgetTester tester) async {
  await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
  await settle(tester, const Duration(milliseconds: 1500));
}
