#!/bin/zsh
set -euo pipefail

script_directory="$(cd -- "$(dirname -- "$0")" && pwd)"
app_path="$script_directory/spull.app"

if [[ ! -d "$app_path" ]]; then
  print -u2 "Spull.app was not found beside this launcher."
  exit 1
fi

# GitHub downloads carry a quarantine attribute. Remove it only from this app,
# then launch the unsigned local-distribution bundle.
/usr/bin/xattr -dr com.apple.quarantine "$app_path" 2>/dev/null || true
/usr/bin/open "$app_path"
