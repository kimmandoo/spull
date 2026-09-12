# Work checkpoint

- Active task: Completed the cross-platform CI recheck and README refresh.
- Next action: No follow-up action; wait for the next requested task.
- Changed files: `.github/workflows/release.yml`, `README.md`,
  `CHANGELOG.md`, and this checkpoint.
- CI behavior: Manual workflow runs execute the same verify, build, package,
  and upload steps as release-tag runs for Linux, macOS, and Windows without
  creating a GitHub Release.
- Documentation behavior: README documents the universal unsigned macOS
  launcher, manual CI steps, package artifact names, and release behavior.
- Release state: `release-v1.2.7` remains the latest published release;
  commit `f6638c1` contains this CI/documentation update.
- Verification:
  - Workflow YAML parsed and launcher syntax passed `zsh -n`.
  - `git diff --check` passed.
  - `dart run tool/verify.dart` passed formatting, analysis, and all widget
    tests.
  - Local `flutter build macos --release` and macOS runtime verification
    passed.
  - Manual GitHub Actions run `34686772522` passed Linux, macOS, and Windows
    verification, release builds, packaging, and artifact uploads.
  - Manual CI uploaded complete and packaged artifacts for all three targets.
- Blockers: None.
