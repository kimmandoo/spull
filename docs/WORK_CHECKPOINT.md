# Work checkpoint

- Active task: Published release `v1.2.8` from commit
  `a363ee887ef24c3e60323b272b34d267ab618b99`.
- Next action: Monitor GitHub Actions run #57 and investigate only if the
  release workflow fails.
- Release commit: `release(v1.2.8): publish desktop artifacts`.
- Release tag: `release-v1.2.8`, pushed to `origin`.
- Release verification:
  - `tool/publish_release.ps1 -Version 1.2.8` passed its formatter, analyzer,
    and 10 widget tests before creating the release commit.
  - The release commit and tag were pushed successfully to `origin/main` and
    `origin/release-v1.2.8`.
  - GitHub Actions run #57 was queued for the tag push:
    `https://github.com/kimmandoo/spull/actions/runs/34749110219`.
- Included product fixes: malformed native yt-dlp output is decoded with
  `Utf8Decoder(allowMalformed: true)`, and the advanced-settings ripple is
  clipped to its rounded card.
- Blockers: The remote release workflow is queued; no local blockers.
