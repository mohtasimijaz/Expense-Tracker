import 'package:expense_tracker/constants/app_strings.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/screens/main_shell.dart';
import 'package:expense_tracker/screens/onboarding_screen.dart';
import 'package:expense_tracker/screens/settings_screen.dart';
import 'package:expense_tracker/screens/splash_screen.dart';
import 'package:expense_tracker/screens/statistics_screen.dart';
import 'package:expense_tracker/widgets/expense_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';
import 'helpers/test_helpers.dart';

void main() {
  final today = DateTime.now();

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  testWidgets('empty database shows the empty state', (tester) async {
    await pumpApp(tester);
    expect(find.text(AppStrings.emptyTitle), findsOneWidget);
    expect(find.byType(ExpenseCard), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adding an expense saves it and shows it in the list', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);

    const title = 'Café ☕ "Chai" & <snacks>';
    await tester.enterText(field(AppStrings.fieldAmount), '1250');
    await tester.enterText(field(AppStrings.fieldTitle), title);
    await tester.tap(find.text(AppStrings.fieldCategory));
    await tester.ensureVisible(find.text('Transport'));
    await tester.tap(find.text('Transport'));
    await tester.ensureVisible(find.text(AppStrings.saveExpense));
    await tester.tap(find.text(AppStrings.saveExpense));
    await settle(tester, const Duration(seconds: 3));

    expect(app.repository.store.length, 1);
    final saved = app.repository.store.values.single;
    expect(saved.title, title);
    expect(saved.amount, 1250);
    expect(saved.category, 'Transport');
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text(title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid form shows validation errors and saves nothing', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    await tester.ensureVisible(find.text(AppStrings.saveExpense));
    await tester.tap(find.text(AppStrings.saveExpense));
    await settle(tester, const Duration(milliseconds: 500));
    expect(find.text(AppStrings.validationAmountEmpty), findsOneWidget);
    expect(find.text(AppStrings.validationTitleEmpty), findsOneWidget);

    await tester.enterText(field(AppStrings.fieldAmount), '0');
    await tester.tap(find.text(AppStrings.saveExpense));
    await settle(tester, const Duration(milliseconds: 500));
    expect(find.text(AppStrings.validationAmountZero), findsOneWidget);
    expect(app.repository.store, isEmpty);
  });

  testWidgets('swipe to delete removes from database and undo restores', (
    tester,
  ) async {
    final expense = makeExpense(id: 'swipe', title: 'Groceries', date: today);
    final app = await pumpApp(tester, initial: [expense]);
    expect(find.text('Groceries'), findsOneWidget);

    await tester.drag(find.byType(ExpenseCard), const Offset(-600, 0));
    await settle(tester, const Duration(seconds: 1));
    expect(app.repository.store, isEmpty);
    expect(find.byType(ExpenseCard), findsNothing);

    await tester.tap(find.text(AppStrings.undo));
    await settle(tester, const Duration(seconds: 1));
    expect(app.repository.store['swipe'], expense);
    expect(find.text('Groceries'), findsOneWidget);
  });

  testWidgets('tapping an expense opens edit and saves changes', (
    tester,
  ) async {
    final app = await pumpApp(
      tester,
      initial: [makeExpense(id: 'e', title: 'Old title', date: today)],
    );
    await tester.tap(find.text('Old title'));
    await settle(tester);
    expect(find.text(AppStrings.editExpenseTitle), findsOneWidget);
    await tester.enterText(field(AppStrings.fieldTitle), 'New title');
    await tester.ensureVisible(find.text(AppStrings.updateExpense));
    await tester.tap(find.text(AppStrings.updateExpense));
    await settle(tester, const Duration(seconds: 3));
    expect(app.repository.store['e']!.title, 'New title');
    expect(find.text('New title'), findsOneWidget);
  });

  testWidgets('search and category filters narrow the list', (tester) async {
    await pumpApp(
      tester,
      initial: [
        makeExpense(id: 'a', title: 'Pizza', category: 'Food', date: today),
        makeExpense(id: 'b', title: 'Taxi', category: 'Transport', date: today),
        makeExpense(id: 'c', title: 'Burger', category: 'Food', date: today),
      ],
    );
    expect(find.byType(ExpenseCard), findsNWidgets(3));

    await tester.enterText(find.byType(TextField).first, 'piz');
    await settle(tester, const Duration(milliseconds: 600));
    expect(find.byType(ExpenseCard), findsOneWidget);
    expect(find.text('Pizza'), findsOneWidget);

    await tester.tap(find.byTooltip(AppStrings.clearSearch));
    await settle(tester, const Duration(milliseconds: 600));
    await tester.tap(find.text('Transport').first);
    await settle(tester, const Duration(milliseconds: 600));
    expect(find.byType(ExpenseCard), findsOneWidget);
    expect(find.text('Taxi'), findsOneWidget);
  });

  testWidgets('very large amounts render without overflow', (tester) async {
    await pumpApp(
      tester,
      initial: [
        makeExpense(id: 'big', title: 'House', amount: 999999999, date: today),
      ],
    );
    // PKR has no minor unit in CLDR, so no decimals are shown.
    // Shown on the card and in this month's header.
    expect(find.text('Rs 999,999,999'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark mode toggle switches the theme and persists', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    await tester.tap(find.text(AppStrings.navSettings));
    await settle(tester);
    await tester.tap(find.text(AppStrings.themeDark));
    await settle(tester);
    final context = tester.element(find.byType(SettingsScreen));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(app.settings.themeMode, ThemeMode.dark);

    await tester.tap(find.text(AppStrings.themeLight));
    await settle(tester);
    expect(
      Theme.of(tester.element(find.byType(SettingsScreen))).brightness,
      Brightness.light,
    );
  });

  testWidgets('statistics screen renders charts with data', (tester) async {
    await pumpApp(
      tester,
      initial: [
        for (var i = 0; i < 40; i++)
          makeExpense(
            id: '$i',
            amount: 100.0 + i,
            category: ['Food', 'Transport', 'Health'][i % 3],
            date: today.subtract(Duration(days: i * 5)),
          ),
      ],
    );
    await tester.tap(find.text(AppStrings.navStatistics));
    await settle(tester);
    expect(find.byType(StatisticsScreen), findsOneWidget);
    expect(find.text(AppStrings.statsWeekly), findsOneWidget);
    expect(find.text(AppStrings.statsComparison), findsOneWidget);
    await tester.dragUntilVisible(
      find.text(AppStrings.statsCategories),
      find.byType(ListView).last,
      const Offset(0, -300),
    );
    await settle(tester);
    expect(find.text(AppStrings.statsCategories), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('statistics screen with empty database', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text(AppStrings.navStatistics));
    await settle(tester);
    expect(find.text(AppStrings.statsNoDataTitle), findsOneWidget);
  });

  testWidgets('landscape and tablet layouts render without overflow', (
    tester,
  ) async {
    await pumpApp(
      tester,
      size: const Size(1024, 600),
      initial: [makeExpense(id: 'l', title: 'Wide', date: today)],
    );
    expect(find.text('Wide'), findsOneWidget);
    await tester.tap(find.text(AppStrings.navStatistics));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onboarding walks through 3 pages and is remembered', (
    tester,
  ) async {
    final app = await pumpApp(
      tester,
      home: const OnboardingScreen(),
      prefs: const {},
    );
    expect(find.text(AppStrings.onboardingTitle1), findsOneWidget);
    await tester.tap(find.text(AppStrings.onboardingNext));
    await settle(tester);
    expect(find.text(AppStrings.onboardingTitle2), findsOneWidget);
    await tester.tap(find.text(AppStrings.onboardingNext));
    await settle(tester);
    expect(find.text(AppStrings.onboardingTitle3), findsOneWidget);
    await tester.tap(find.text(AppStrings.onboardingStart));
    await settle(tester);
    expect(find.byType(MainShell), findsOneWidget);
    expect(app.settings.settings.onboardingComplete, isTrue);
  });

  testWidgets('splash loads data then opens the main shell', (tester) async {
    await pumpApp(
      tester,
      home: const SplashScreen(),
      initial: [makeExpense(id: 's', title: 'From disk', date: today)],
    );
    await settle(tester, const Duration(seconds: 3));
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('From disk'), findsOneWidget);
  });
}
