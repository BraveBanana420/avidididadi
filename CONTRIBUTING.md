# Contributing to Avidididadi

Thanks for wanting to help! Issues and pull requests in **English or Italian**
are both fine (le issue e le PR in italiano vanno benissimo).

## Before you start

- For a bug, open an issue with the **Bug report** template: app version
  (Profile → Data and connections, at the bottom), phone and Android version,
  steps to reproduce.
- For a new feature, open a **Feature request** first, so we can agree on the
  idea before you write code.
- Never attach your backup, CSV files, GPX tracks or API keys to an issue:
  they contain health and location data. Use made-up values.

## Branches

- `main`: the stable version. Releases are tagged here (`v1.2.3`).
- `staging`: where all work goes. **Open pull requests against `staging`.**
- For a larger change, use a branch like `feature/<short-name>` from `staging`.

## Development setup

You need Flutter 3.47 (stable, Dart 3.13), Java 17 and the Android SDK.

```sh
flutter pub get
git config core.hooksPath tool/git-hooks   # blocks secrets and personal data in commits
```

Before every pull request, all of these must pass (CI runs them too):

```sh
dart format lib test tool
flutter analyze        # "No issues found!"
flutter test
flutter build apk --debug
```

## Code conventions

- **Names and comments in Italian**, like the rest of the code: classes in
  `PascalCase`, functions and variables in `camelCase`, file names in Italian
  `snake_case`. Short comments explaining *why*, with `///` on public classes
  and functions.
- **Pure logic** (generators, calculations, parsing) lives in files without
  Flutter UI and gets a test in `test/<area>_test.dart`, with realistic data.
- **State**: a single `AppState` (`ChangeNotifier`); screens read it with
  `ListenableBuilder` and call its `Future` methods. No other state library.
- **Graphics**: never hard-coded colors in widgets; use
  `Theme.of(context).colorScheme`, `Pulse.di(context)` and `coloreSport()`.
  Check every visual change in the 4 themes (dark/light × red/neon):
  `flutter test tool/schermate/schermate_test.dart` draws them in
  `build/schermate/`.
- **Data files**: CSV in the app's private folder. New file names must match
  `^[a-z0-9_]+\.csv$` (otherwise they're not backed up). New columns go **at
  the end**, and old rows must stay readable.

## Texts and translations

- No hard-coded user-visible strings: add the text to `lib/l10n/app_it.arb`
  (the template) **and** `lib/l10n/app_en.arb`, then use it as
  `l10n.yourKey` (import `l10n/lingua.dart`). `flutter pub get` or
  `flutter gen-l10n` regenerates `app_localizations*.dart`; commit those too.
- Placeholders are `{p0}`, `{p1}`… with type `Object`, and must be the same in
  both languages (`test/lingua_test.dart` checks it).
- **Values saved in the CSV files stay in Italian** (sports like `Corsa`, times
  of day like `Mattina`, session types like `Lento`, intensities like
  `zona 2`): the code compares and parses them. Translate them only on screen
  with `mostra()` / `mostraTesto()` from `lib/l10n/vocabolario.dart`.
- To add a language: copy `app_en.arb` to `app_xx.arb`, translate it, add the
  code to `lingueApp` in `lib/l10n/lingua.dart` and the words to
  `vocabolario.dart`.

## Privacy and security rules

These are part of the app's promise to its users; pull requests that break
them won't be merged:

- Health Connect is read-only.
- GPS only during running, walking and cycling workouts (or another activity
  if the user chooses it); Bluetooth only with workout mode or "My sensors"
  open.
- API keys only in `flutter_secure_storage`: never in CSV, backups or logs.
- Never send name, photo or GPS routes to the assistant.
- If the data the app collects changes, update the policy in
  `lib/screens/privacy_screen.dart` and bump `versioneTermini`.

## Pull requests

- One topic per pull request, with a clear description and screenshots for
  visual changes.
- Commit messages in Italian or English, describing what changes for the
  user.
- By contributing you agree that your code is released under the
  [GPL-3.0](LICENSE).
