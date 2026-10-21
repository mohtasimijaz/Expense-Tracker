# Store submission checklist

✅ = done in the project · ⬜ = you need to do it (needs your accounts, devices
or decisions)

## Both stores

- ✅ App name "Expense Tracker", version 1.0.0 (build 1)
- ✅ App icons for every required size (Android adaptive, iOS, web)
- ✅ In-app privacy policy screen (Settings → Privacy policy, and linked from
  onboarding)
- ✅ Only the INTERNET permission is requested
- ✅ Crashlytics and Analytics code ready (turns on after `flutterfire configure`)
- ⬜ Run `flutterfire configure` and enable Crashlytics and Analytics in the
  Firebase console
- ⬜ **Host the privacy policy at a public URL.** Both stores require a link
  in the listing, not only in the app. The text is in
  `lib/constants/app_strings.dart` (`privacySections`). Add a contact email.
- ⬜ Test on at least one real Android phone and one iPhone
- ⬜ Screenshots: phone (and tablet if you support it) in light and dark mode
- ⬜ Store description, short description, keywords and category (Finance)
- ⬜ Content rating questionnaires

## Google Play

- ✅ Package name `com.mohtasimijaz.expensetracker` (permanent once published)
- ✅ Minimum SDK 24 (Android 7.0), target SDK from Flutter (current Play requirement)
- ✅ Release signing reads `android/key.properties`
  (template: `android/key.properties.example`)
- ✅ Code and resource shrinking enabled for release
- ✅ Native launch screen matches the in-app splash (light and dark)
- ⬜ Accept the Android SDK licences:
  ```bash
  flutter doctor --android-licenses
  ```
- ⬜ Create the upload keystore and `android/key.properties` (README → *Release signing*)
- ⬜ Build the bundle:
  ```bash
  flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
  ```
- ⬜ Upload `build/symbols` to Crashlytics so crash reports are readable
- ⬜ Play Console → **Data safety**: no data shared; crash logs and app
  interactions collected via Firebase (if enabled); data not linked to identity;
  users can delete their data in the app
- ⬜ Play Console → enrol in Play App Signing
- ⬜ Internal testing track → closed testing (new personal accounts need 12
  testers for 14 days) → production

## Apple App Store (needs a Mac with Xcode)

- ✅ Bundle ID `com.mohtasimijaz.expensetracker`
- ✅ Deployment target iOS 15.0 (required by Firebase)
- ✅ Display name "Expense Tracker"
- ✅ App icon without transparency (`remove_alpha_ios`)
- ⬜ Apple Developer account, App ID and App Store Connect record
- ⬜ Xcode → Runner → Signing & Capabilities: choose your team
- ⬜ Run `pod install` (Flutter generates the Podfile on the first iOS build;
  check it says `platform :ios, '15.0'`)
- ⬜ Build:
  ```bash
  flutter build ipa --release --obfuscate --split-debug-info=build/symbols
  ```
- ⬜ App Store Connect → **App Privacy**: crash data and product interaction
  (if Firebase is enabled), not linked to the user, not used for tracking
- ⬜ Export compliance: the app uses no custom encryption, only standard HTTPS
- ⬜ TestFlight testing, then submit for review
