# Work checkpoint

- Active task: Fixed malformed UTF-8 failures while analyzing native yt-dlp output and corrected the advanced-settings ripple clipping.
- Next action: No follow-up action; wait for the next requested task.
- Changed files: `lib/services/spull_backend.dart`, `lib/home_page.dart`,
  `test/widget_test.dart`, `CHANGELOG.md`, and this checkpoint.
- UTF-8 behavior: Native yt-dlp stdout and stderr now use one shared
  `Utf8Decoder(allowMalformed: true)` for analysis and download streams, so an
  isolated non-UTF-8 byte is replaced instead of throwing `FormatException`.
  The replacement remains valid JSON and preserves the playlist response.
- UI behavior: The advanced-settings `ExpansionTile` is wrapped in a rounded,
  clipped `Material`, keeping its ink ripple inside the card boundary.
- Verification:
  - `dart run tool/verify.dart` passed formatting, analysis, and all 10 widget
    tests, including malformed-output decoding and advanced-settings expansion.
  - `flutter build windows --release` passed and produced the Windows bundle.
  - The reported URL was exercised through `SpullBackend.analyzeUrl`; it
    completed without an invalid UTF-8 exception and returned one playable
    `https://www.youtube.com/watch?v=Y1Lah0BM0KQ` entry in the current yt-dlp
    environment.
  - `git diff --check` passed.
- Blockers: None.
