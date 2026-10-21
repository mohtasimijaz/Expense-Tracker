# Expense Tracker

[![Live demo](https://img.shields.io/badge/Live%20demo-Open%20app-4F46E5?style=for-the-badge&logo=flutter&logoColor=white)]( https://mohtasimijaz.github.io/Expense-Tracker/)
[![Download APK](https://img.shields.io/badge/Android-Download%20APK-15803D?style=for-the-badge&logo=android&logoColor=white)](https://github.com/mohtasimijaz/Expense-Tracker/releases/latest)

**Try it live in your browser:** https://mohtasimijaz.github.io/Expense-Tracker/


A Flutter expense tracker with offline storage, budgets, statistics and
light/dark themes, prepared for Google Play and the App Store.

- **Package / bundle ID:** `com.mohtasimijaz.expensetracker`
- **Version:** 1.0.0 (build 1)
- **Flutter:** 3.38.x (Dart 3.10)
- **Minimum OS:** Android 7.0 (API 24), iOS 15.0 — see *Known limitations*

---

## Features

**Data**
- Permanent local storage with Hive. Every add, edit, delete, undo and
  "delete all" is written immediately and survives app restarts.
- Undo for single deletes (snackbar) and for "Delete all expenses".
- All database work goes through one queue, so concurrent operations never
  interleave. Failures roll back the in-memory list and show a message.

**Expenses**
- Full-screen add and edit form: amount, title, 7 categories, date picker
  (no future dates) and an optional note. Every field is validated.
- Swipe left to delete. Tap a card to edit.
- Search by title, filter by category and date range, and sort (newest,
  oldest, highest, lowest, category).
- Pull to refresh, and lazy loading (30 items per page) for large lists.

**Budget**
- Optional monthly budget with an animated progress bar that turns amber at
  your warning threshold and red when exceeded.
- In-app budget alerts when an expense pushes you past the threshold (50–100%,
  default 80%) or over the budget. They can be turned off in Settings.

**Statistics**
- Today, this week, this month and daily-average totals.
- This month compared with last month, with the percentage change.
- 7-day bar chart, 6-month trend line, and a category donut chart (this
  month or all time) with breakdown bars.

**Quick add (new)**
- The + button opens a sheet with large rolling digits, a built-in number
  pad and one row of category bubbles. Save in about 3 seconds; the title
  defaults to the category name.
- "More details" opens the full form with the amount and category carried over.
- Works with a hardware keyboard too: digits, Backspace, Enter.

**Feedback when saving and deleting (new)**
- Green tick "Expense saved/updated" after every add or edit.
- Red bin animation "Expense deleted" after every delete (swipe, press-and-hold
  menu, or the edit screen), then a bar with **UNDO** and **✕**. UNDO restores
  the expense with a green tick "Expense restored"; ✕ cancels the undo and
  makes the delete final. A thin line shows the 5 seconds left to undo.
- Press and hold any expense for Edit and Delete options.

**Living balance card (new)**
- The gradient shifts with the budget: indigo when on track, deep amber in the
  warning zone, red–rose when over, and slowly rotates.
- This month's total rolls like an odometer when it changes.
- A ring shows the share of the budget used.
- The card tilts with the phone's motion (mouse on web/desktop) with a moving
  light reflection.

**Timeline list (new)**
- When sorted by date, expenses are grouped by day under sticky headers
  ("Today · 3 · Rs 2,450") with a mini bar comparing day totals.
- A one-time tip explains swipe-to-delete and press-and-hold.

**Habits and celebrations (new)**
- Light vibrations on taps, saves, deletes and budget alerts, which can be
  turned off in Settings → Haptic feedback.
- 🔥 streak chip for consecutive days with logged expenses; confetti and a
  message at 3, 7, 14, 30, 60, 100, 180 and 365 days (once per streak).
- Confetti when last month finished within budget (shown once, on opening).

**Insights and monthly recap (new)**
- Swipeable insight cards: budget pace, category change vs the same days last
  month, weekend vs weekday spending, top category, no-spend days and the
  biggest expense.
- A story-style monthly recap (from the last insight card, or the ✨ button on
  Statistics) with auto-advancing slides; tap to move, hold to pause, and
  share any slide as an image.

**Settings**
- About 155 world currencies with search. The default currency comes from the
  phone's region (Pakistan → PKR, India → INR, Germany → EUR, and so on).
- Theme: System, Light or Dark.
- Budget, alert switch and threshold, delete all data, privacy policy, and
  app version.

**Look and feel**
- Indigo/violet palette with separate light and dark colour sets whose text
  contrast meets WCAG AA. Semantic colours: green for less spending, amber
  for warnings, red for overspending.
- Plus Jakarta Sans via Google Fonts, with tabular figures for amounts.
- Gradient balance card, frosted-glass navigation bar and budget panel,
  subtle finance-themed background.
- Animations: page transitions, Hero transitions (add button → form, card
  icon → edit form, app logo), staggered list entry, swipe removal, press
  feedback on cards and chips, count-up numbers, Lottie animations for the
  empty state, success and loading, and an animated splash and onboarding.
- Respects the system "reduce motion" setting.
- Responsive: content is capped at 720px wide on tablets and in landscape,
  and statistics tiles switch to 4 columns on wide screens.

---

## Project structure

```
lib/
├── main.dart                  start-up: Firebase → settings + database → runApp
├── app.dart                   providers, themes, MaterialApp
├── constants/                 colours, theme, spacing, strings, categories, currencies
├── models/                    Expense (+ generated Hive adapter), settings, budget, stats
├── services/                  database (Hive), settings, statistics, Firebase monitoring
├── providers/                 ExpenseProvider, SettingsProvider, form controller
├── screens/                   splash, onboarding, shell, home, add/edit, stats, settings…
├── utils/                     formatters, validation, page routes
└── widgets/                   reusable UI, grouped by screen (home/, stats/, add/, settings/)
assets/
├── icon/                      app icon source images
└── lottie/                    empty / success / loading animations
test/                          115 automated tests (see TEST_REPORT.md)
```

**Why Hive instead of sqflite:** expenses are simple records that are always
loaded in full. Hive needs no SQL schema or migrations, is faster for this
access pattern, works on Android, iOS and web, and is pure Dart with no
native SQLite dependency, which keeps the app smaller.

---

## Setup

```bash
flutter pub get
```

```bash
flutter run
```

Regenerate the Hive adapter after changing `lib/models/expense.dart`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run the analyzer and all tests:

```bash
flutter analyze
```

```bash
flutter test
```

Regenerate app icons after changing `assets/icon/`:

```bash
dart run flutter_launcher_icons
```

### Connect Firebase (Crashlytics + Analytics)

The code is already in place (`lib/services/monitoring_service.dart`). Until
Firebase is connected the app runs normally with monitoring turned off.

1. Create a project at <https://console.firebase.google.com>.
2. Install the CLI once:
   ```bash
   dart pub global activate flutterfire_cli
   ```
3. From this folder, run:
   ```bash
   flutterfire configure
   ```
   It adds `google-services.json` and `GoogleService-Info.plist`, and the
   Gradle plugins for Crashlytics.
4. In the Firebase console, enable Crashlytics and Analytics.

Crashlytics only collects data in release builds.

### Release signing (Android)

1. Create an upload key. Choose your own passwords and keep them safe:
   ```bash
   keytool -genkey -v -keystore C:/Users/YOUR_USER/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Copy `android/key.properties.example` to `android/key.properties` and fill
   in your values. Both files are git-ignored.
3. Build the bundle for Play Console:
   ```bash
   flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
   ```

Without `key.properties`, release builds fall back to debug signing, which
Play Console rejects.

### iOS (needs a Mac with Xcode)

```bash
flutter build ipa --release --obfuscate --split-debug-info=build/symbols
```

Set your Apple team under *Runner → Signing & Capabilities* in Xcode. The
deployment target is already 15.0.

---

## Known limitations

- **Android 5.0 and iOS 12 cannot be supported.** Flutter 3.38's minimum is
  Android 7.0 (API 24), and Firebase iOS SDK 12 requires iOS 15.
- **Android:** the release APK builds and runs on a Samsung Galaxy S22 Ultra
  (Android 16). Build it with Java 17–24: Android Studio's bundled Java 25 is
  too new for Gradle 8.14, so point Flutter at another JDK, e.g.
  `flutter config --jdk-dir="C:\Program Files\Java\jdk-23"`. The Kotlin
  plugin is 2.3.0 because Firebase's Android libraries are built with Kotlin 2.4.
- **iOS has not been built,** because that needs a Mac with Xcode.
- **Budget alerts are in-app** (a dialog after saving), not system push
  notifications. Push reminders would need `flutter_local_notifications`
  and the notification permission.
- **Fonts are downloaded at runtime** by `google_fonts` and cached. On a
  first launch without internet the system font is used. To bundle them,
  add the Plus Jakarta Sans `.ttf` files under `assets/google_fonts/` and set
  `GoogleFonts.config.allowRuntimeFetching = false`.
- **PKR, JPY, KRW and similar currencies show no decimals.** This follows the
  standard CLDR currency data used by `intl`.
- **The `hive` package (2.2.3) is no longer actively developed.** It works
  well, but `hive_ce` is a maintained drop-in fork worth moving to later.
- **Analytics and Crashlytics do nothing** until Firebase is connected (see
  above), and they never run on web or desktop.
- **Not yet checked on a real phone:** motion tilt, vibrations and the
  native share sheet. On web and desktop the card tilts with the mouse
  instead, and vibration does nothing.
- **The month-end celebration compares last month with the current budget,**
  because past budgets are not stored.
- **After installing an update on web,** browsers can briefly keep the old
  version cached. A hard refresh (Ctrl+Shift+R) loads the new one.
- **Text is English-only.** Every string is in `lib/constants/app_strings.dart`,
  ready to move to ARB files for translation.
