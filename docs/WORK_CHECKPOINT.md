# Work checkpoint

- Active task: Fix the macOS launcher failure reported for the v1.2.6
  unsigned release.
- Next action: Commit the launcher fix, publish release v1.2.7, and watch
  the GitHub Actions release run to completion.
- Changed files: `tool/Run-Spull.command`, `README.md`, `CHANGELOG.md`, and
  this checkpoint.
- Runtime behavior: The launcher now searches its extracted release folder
  case-insensitively for `spull.app`, so folder-name casing and one extra
  extraction directory do not prevent startup. It still removes only the
  app's `com.apple.quarantine` attribute.
- Release state: `release-v1.2.6` remains the latest published release;
  `release-v1.2.7` is pending commit and CI publication.
- Verification:
  - Published v1.2.6 archive layout confirmed the launcher and app are
    packaged together.
  - Patched launcher syntax passed `zsh -n`.
  - Patched launcher found and launched the quarantined extracted app.
- Blockers: None.
