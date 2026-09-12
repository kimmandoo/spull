# Work checkpoint

- Active task: Recheck Linux, macOS, and Windows CI packaging and refresh the
  release documentation.
- Next action: Commit and push the changes, trigger `workflow_dispatch` on
  `main`, and verify all three platform jobs.
- Changed files: `.github/workflows/release.yml`, `README.md`,
  `CHANGELOG.md`, and this checkpoint.
- CI behavior: Manual workflow runs now execute the same package steps as
  release-tag runs and upload Linux, universal macOS, and Windows packages
  without creating a GitHub Release.
- Documentation behavior: README explains the manual CI path, package
  artifact names, and robust unsigned macOS launcher fallback.
- Release state: `release-v1.2.7` remains the latest published release;
  this verification change is pending commit and manual CI execution.
- Verification:
  - Workflow YAML parsed and launcher syntax passed `zsh -n`.
  - `git diff --check` passed.
  - `dart run tool/verify.dart` passed formatting, analysis, and all widget
    tests.
  - Local `flutter build macos --release` and macOS runtime verification
    passed.
- Blockers: None.
