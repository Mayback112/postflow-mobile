# Repository Guidelines

## Project Structure & Module Organization

This is a Flutter app named `postflow`. Application code lives in `lib/`: `main.dart` wires the app, `routes/route.dart` owns route generation, `screen/` contains feature screens, and `components/` contains reusable UI pieces. Tests live in `test/`, currently with a widget smoke test. Visual assets are under `asset/` and are declared in `pubspec.yaml`; custom Poppins fonts are under `fonts/Poppins/`. Platform directories (`android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`) are generated Flutter targets and should only be changed for platform-specific configuration.

## Build, Test, and Development Commands

- `flutter pub get`: install Dart and Flutter dependencies from `pubspec.yaml`.
- `flutter run`: launch the app on the selected emulator, simulator, browser, or device.
- `flutter test`: run widget and unit tests in `test/`.
- `flutter analyze`: run static analysis using `flutter_lints`.
- `dart format lib test`: format Dart source and tests.
- `flutter build apk` or `flutter build web`: create release artifacts for Android or web.

## Coding Style & Naming Conventions

Use standard Dart formatting with two-space indentation. Keep analyzer warnings clean before opening a pull request. File names should be lowercase with underscores when needed, such as `onboarding_page.dart`; classes and widgets use `UpperCamelCase`, such as `Onboarding1Page`. Prefer `const` constructors where possible, keep route names centralized in `lib/routes/route.dart`, and update `pubspec.yaml` whenever adding new asset or font directories.

## Testing Guidelines

Use `flutter_test` for widget tests. Place tests in `test/` and name files with the `_test.dart` suffix. Prefer descriptive test names, for example `testWidgets('shows the onboarding screen', ...)`. Add or update tests when changing navigation, screen rendering, or reusable components. Run `flutter test` and `flutter analyze` before submitting changes.

## Commit & Pull Request Guidelines

Git history is not available in this workspace, so no project-specific commit pattern can be inferred. Use short imperative commit messages, for example `Add onboarding route` or `Fix signup layout overflow`. Pull requests should include a concise summary, testing performed, linked issue or task when available, and screenshots or screen recordings for UI changes. Call out any platform-specific changes under `android/`, `ios/`, or other generated target folders.

## Agent-Specific Instructions

Keep generated edits scoped and avoid unrelated formatting churn. Do not modify platform folders unless the task requires native configuration. When adding assets, verify both the filesystem path and the `pubspec.yaml` asset declaration.
