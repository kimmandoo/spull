# Work checkpoint

- Active task: Add a universal unsigned macOS CI distribution.
- Next action: Commit the implementation, publish release v1.2.6, and watch
  the GitHub Actions release run to completion.
- Changed files: `.github/workflows/release.yml`,
  `macos/Runner/Configs/AppInfo.xcconfig`,
  `macos/Runner/Configs/Release.xcconfig`, `macos/ExportOptions.plist`,
  `tool/Run-Spull.command`, `README.md`, `CHANGELOG.md`, and this checkpoint.
- Runtime behavior: macOS release bundles are unsigned and include a launcher
  that removes only the app's `com.apple.quarantine` attribute before opening
  it. CI builds and verifies one universal arm64/x86_64 artifact.
- Release state: `release-v1.2.5` remains the latest published release;
  `release-v1.2.6` is pending commit and CI publication.
- Verification:
  - Repository inspection completed; local unsigned macOS build passed.
  - The unsigned app launched locally.
  - A quarantined extracted ZIP launched through `Run-Spull.command`.
- Blockers: None.
