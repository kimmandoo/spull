# Work checkpoint

- Active task: Completed the v1.2.7 macOS launcher fix and release.
- Next action: No follow-up action; wait for the next requested task.
- Changed files: `tool/Run-Spull.command`, `README.md`, `CHANGELOG.md`,
  `pubspec.yaml`, and this checkpoint.
- Runtime behavior: The launcher searches its extracted release folder
  case-insensitively for `spull.app`, so folder-name casing and one extra
  extraction directory do not prevent startup. It still removes only the
  app's `com.apple.quarantine` attribute.
- Release state: `release-v1.2.7` points to `b7ddd46` and is pushed with
  `main` to `origin`; GitHub Actions run `34686226889` completed successfully
  and published the four desktop assets.
- Verification:
  - Published v1.2.6 archive layout confirmed the launcher and app were
    packaged together.
  - Patched launcher syntax passed `zsh -n`.
  - Patched launcher found and launched the quarantined extracted app.
  - `dart run tool/verify.dart` passed formatting, analysis, and all widget
    tests.
  - Release CI passed Linux, macOS, Windows, packaging, and publication.
- Blockers: None.
