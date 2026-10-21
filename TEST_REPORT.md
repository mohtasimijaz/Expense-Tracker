# Test report

**Date:** 21 October 2026
**Result:** `flutter analyze` reports no issues, and `flutter test` passes
**77 / 77** tests with 0 failures and no exceptions logged during tests.

## How each file was checked

| Check | How |
|---|---|
| Syntax and imports | `flutter analyze` (flutter_lints 6) over the whole project. Every file compiles and has no unused or missing imports. |
| Logic | Unit tests for services, providers, models and utilities. |
| Integration | Widget tests that pump the full app (real providers, themes and navigation) with an in-memory database, plus database tests on a real Hive store. |
| Edge cases | Empty database, 100 and 250 records, 999,999,999 amounts, special characters (quotes, emoji, Urdu, SQL-like text), invalid input, simulated database failures, corrupted settings, year boundaries, and narrow, wide and landscape screens. |
| End to end | Release web build used in a browser: onboarding, splash, add with custom date, success animation, budget panel, statistics, dark theme, and reloading the page to confirm data persists. |

Widget tests run with Flutter's test font, which is wider than real fonts, so
they are a stricter check for text overflow than a real phone.

## Requested scenarios

| Scenario | Result | Covered by |
|---|---|---|
| Add 100 expenses, all saved to database | ✅ | `database_service_test`: "100 expenses are saved and survive an app restart" |
| Delete removes from database | ✅ | `database_service_test`, `expense_provider_test`, `widget_test` (swipe) |
| Undo restores in database | ✅ | `database_service_test`, `expense_provider_test`, `widget_test` (swipe → UNDO) |
| Close and reopen keeps all expenses | ✅ | `database_service_test` (closes and reopens Hive); browser reloads |
| All filters work | ✅ | `expense_provider_test` (category, search, date range, 5 sorts, combined, clear); `widget_test` |
| Statistics with various data sets | ✅ | `statistics_calculator_test` (empty, week/month split, year boundary, large); `widget_test` (40 items, empty) |
| Dark mode toggle | ✅ | `widget_test` (theme switches); `settings_provider_test` (persists across restart) |
| Empty database | ✅ | `database_service_test`, `expense_provider_test`, `widget_test` (empty states) |
| Large amounts (999,999,999) | ✅ | `database_service_test` (exact storage up to 999,999,999,999.99), `statistics_calculator_test`, `widget_test` (no overflow) |
| Special characters in title | ✅ | `database_service_test` (6 tricky titles and notes), `widget_test` (typed into the form), browser |
| Concurrent operations | ✅ | `database_service_test`: 200 parallel adds, then mixed parallel deletes and adds |
| Database failure handling | ✅ | `expense_provider_test`: load, add and delete failures roll back and report errors |

## Test files

| File | Tests |
|---|---|
| `test/services/database_service_test.dart` | 13 |
| `test/providers/expense_provider_test.dart` | 17 |
| `test/services/statistics_calculator_test.dart` | 8 |
| `test/providers/settings_provider_test.dart` | 7 |
| `test/models/models_test.dart` | 13 |
| `test/project_test.dart` | 6 |
| `test/widget_test.dart` | 13 |
| **Total** | **77** |

## Per-file results

Every file below has final status **✅ Ready**. "Issues found" lists only
problems the checks actually caught. Files with "—" passed on the first run.

### Core

| File | Covered by | Issues found → fix applied |
|---|---|---|
| `main.dart` | analyze, browser | — |
| `app.dart` | analyze, all widget tests | — |

### Constants

| File | Covered by | Issues found → fix applied |
|---|---|---|
| `constants/app_colors.dart` | analyze, widget tests (light and dark) | — |
| `constants/app_dimens.dart` | analyze | — |
| `constants/app_info.dart` | `project_test` (version matches pubspec) | — |
| `constants/app_strings.dart` | analyze, widget tests | The search hint was cut off on narrow phones → shortened to "Search" |
| `constants/app_theme.dart` | analyze, widget tests | — |
| `constants/category_data.dart` | `models_test` | — |
| `constants/currency_data.dart` | `models_test` (unique codes, symbols, one currency per country, search) | — |

### Models

| File | Covered by | Issues found → fix applied |
|---|---|---|
| `models/expense.dart` (+ generated `expense.g.dart`) | `models_test`, `database_service_test` | — |
| `models/app_currency.dart` | `models_test` | — |
| `models/app_settings.dart` | `settings_provider_test` | — |
| `models/budget_status.dart` | `models_test`, `expense_provider_test` | — |
| `models/expense_sort.dart` | `expense_provider_test` | — |
| `models/statistics_models.dart` | `statistics_calculator_test`, `models_test` | — |

### Services

| File | Covered by | Issues found → fix applied |
|---|---|---|
| `services/expense_repository.dart` | analyze, provider tests | — |
| `services/database_service.dart` | `database_service_test` (13) | — |
| `services/settings_service.dart` | `settings_provider_test` | — |
| `services/statistics_calculator.dart` | `statistics_calculator_test` | — |
| `services/monitoring_service.dart` | analyze, all tests (no-op path) | Unnecessary `dart:ui` import → removed |

### Providers

| File | Covered by | Issues found → fix applied |
|---|---|---|
| `providers/expense_provider.dart` | `expense_provider_test` (17), widget tests | — |
| `providers/settings_provider.dart` | `settings_provider_test` (7) | — |
| `providers/expense_form_controller.dart` | `widget_test` (add and edit) | — |

### Utils

| File | Covered by | Issues found → fix applied |
|---|---|---|
| `utils/formatters.dart` | `models_test`, `settings_provider_test` | — |
| `utils/expense_validator.dart` | `project_test` | — |
| `utils/app_routes.dart` | widget tests (navigation) | — |

### Screens

| File | Covered by | Issues found → fix applied |
|---|---|---|
| `screens/splash_screen.dart` | `widget_test` (splash) | **Bug:** loading started in `initState` and notified listeners during the first build (debug assertion on every launch) → loading now starts right after the first frame |
| `screens/onboarding_screen.dart` | `widget_test`, browser | Over 200 lines → page dots and privacy footer moved to `onboarding_controls.dart`; unused variable removed |
| `screens/main_shell.dart` | widget tests, browser | Now hosts the shared background (see the app-bar fix below) |
| `screens/home_screen.dart` | widget tests, browser | **Bug:** white strip behind the transparent app bar → background moved to `main_shell.dart`; `Colors.transparent` replaced with the theme constant |
| `screens/add_expense_screen.dart` | `widget_test` (add, validate, edit), browser | Over 200 lines → form body moved to `widgets/add/expense_form_view.dart` |
| `screens/statistics_screen.dart` | `widget_test` (data and empty), browser | Same white-strip bug → fixed via `main_shell.dart`; `Colors.transparent` replaced |
| `screens/settings_screen.dart` | `widget_test` (dark mode) | Over 200 lines → sections moved to `settings_sections.dart`; same white-strip fix |
| `screens/currency_picker_screen.dart` | analyze | — |
| `screens/privacy_policy_screen.dart` | analyze, browser link | — |

### Widgets

| File | Covered by | Issues found → fix applied |
|---|---|---|
| `widgets/expense_card.dart` | widget tests, browser | Amount sat mid-row on wide screens and titles were cut early on narrow ones → amount now takes only the width it needs (max 45%) |
| `widgets/category_badge.dart` | widget tests | **Overflow** when space was tight → label shrinks with an ellipsis |
| `widgets/summary_card.dart` | widget tests, browser | Labels truncated ("Transa…") on narrow phones → labels scale down to fit |
| `widgets/category_breakdown_tile.dart` | `widget_test` (statistics) | Large amounts could overflow → amount scales down to fit |
| `widgets/animated_counter.dart` | widget tests | — |
| `widgets/empty_state_widget.dart` | `widget_test` (empty states) | With "reduce motion" on, the fade would have stayed invisible → uses a zero-length fade instead |
| `widgets/onboarding_page.dart` | `widget_test` (onboarding) | — |
| `widgets/onboarding_controls.dart` | `widget_test` (onboarding) | New file from the split above |
| `widgets/common/app_feedback.dart` | widget tests | Added `showSnackOn` for the swipe-delete fix below |
| `widgets/common/finance_background.dart` | widget tests, browser | — |
| `widgets/common/glass_container.dart` | widget tests | — |
| `widgets/common/pressable_scale.dart` | widget tests | — |
| `widgets/common/status_views.dart` | widget tests (splash and loading) | — |
| `widgets/home/balance_header.dart` | widget tests, browser | **Overflow:** "Spent this month · October 2026" at phone width → text can shrink; repeated date removed |
| `widgets/home/budget_progress.dart` | browser | Text truncated ("3% used of R…") → two-line layout: amount left and % on top, "spent of budget" below |
| `widgets/home/summary_row.dart` | widget tests | — |
| `widgets/home/search_sort_bar.dart` | `widget_test` (search) | — |
| `widgets/home/category_filter_bar.dart` | `widget_test` (category filter) | — |
| `widgets/home/expense_list_header.dart` | widget tests | — |
| `widgets/home/expense_sliver_list.dart` | `widget_test` (swipe and undo) | **Bug:** the Undo snackbar would never show, because the swiped item's context was gone after the database write → the messenger is captured before the write |
| `widgets/add/category_selector.dart` | `widget_test` (add) | — |
| `widgets/add/expense_form_fields.dart` | `widget_test` (add and validate) | — |
| `widgets/add/expense_form_view.dart` | `widget_test` (add and edit) | New file from the split above |
| `widgets/settings/budget_dialog.dart` | browser | — |
| `widgets/settings/settings_group.dart` | `widget_test` (settings) | — |
| `widgets/settings/settings_sections.dart` | `widget_test` (dark mode) | New file from the split above |
| `widgets/stats/chart_card.dart` | `widget_test` (statistics) | The period toggle could overflow on narrow phones → header wraps |
| `widgets/stats/stat_cards.dart` | `widget_test` (statistics) | Over 200 lines → comparison card moved to `month_comparison_card.dart` |
| `widgets/stats/month_comparison_card.dart` | `widget_test` (statistics) | New file from the split above |
| `widgets/stats/weekly_bar_chart.dart` | `widget_test` (statistics) | — |
| `widgets/stats/monthly_trend_chart.dart` | `widget_test` (statistics), browser | — |
| `widgets/stats/category_pie_chart.dart` | `widget_test` (statistics) | — |

## Test-only corrections

These were mistakes in the tests, not in the app:
- Some tests typed `1250.5` as a PKR amount. CLDR currency data gives PKR
  0 decimal places, so the app correctly rejected the decimals → the tests
  now use whole rupees.
- A test expected the large amount to appear once. It appears twice (the
  card and this month's header), which is correct → the assertion now
  expects two.

## Not verified

- **Android or iOS device builds.** Android SDK licences are not accepted on
  this PC, and iOS needs a Mac. Platform configuration was edited but not
  compiled.
- **Firebase Crashlytics and Analytics.** Not testable until a Firebase
  project is connected.
- **Release app size and console output on a real device.** The release web
  build showed no console warnings.
