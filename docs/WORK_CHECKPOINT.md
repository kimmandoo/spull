# Work checkpoint

- Active task: Completed universal unsigned macOS CI distribution and release.
- Next action: No follow-up action; wait for the next requested task.
- Changed files: `.github/workflows/release.yml`,
  `macos/Runner/Configs/AppInfo.xcconfig`,
  `macos/Runner/Configs/Release.xcconfig`, `macos/ExportOptions.plist`,
  `tool/Run-Spull.command`, `README.md`, `CHANGELOG.md`, `pubspec.yaml`, and
  this checkpoint.
- Runtime behavior: macOS release bundles are unsigned and include a launcher
  that removes only the app's `com.apple.quarantine` attribute before opening
  it. CI builds and verifies one universal arm64/x86_64 artifact.
- Release state: `release-v1.2.6` points to `b86e409` and is pushed with
  `main` to `origin`; GitHub Actions run `34677785293` completed successfully
  and published the four desktop assets.
- Verification:
  - Local `flutter build macos --release` passed.
  - `dart run tool/verify_desktop_artifact.dart macos` passed.
  - The local app reported `x86_64 arm64`; `codesign --verify` failed as
    expected for the unsigned bundle.
  - The unsigned app launched locally.
  - A quarantined extracted ZIP launched through `Run-Spull.command`.
  - `dart run tool/verify.dart` passed formatting, analysis, and all widget
    tests.
  - Release CI passed Linux, macOS, Windows, packaging, and publication.
- Blockers: None.
