#!/usr/bin/env bash
set -euo pipefail

# uninstall.sh — remove the `new-project` symlink that install.sh created.
# Mirrors install.sh: honors PREFIX, defaults to ~/.local/bin.
# Does NOT delete this repo or any projects you generated.

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${PREFIX:-$HOME/.local/bin}"
LINK="$TARGET_DIR/new-project"

if [ -L "$LINK" ]; then
  echo "Removing symlink: $LINK -> $(readlink "$LINK")"
  rm -f "$LINK"
  echo "Done. 'new-project' is no longer on your PATH via $TARGET_DIR."
elif [ -e "$LINK" ]; then
  echo "Refusing to remove $LINK -- it's a real file, not a symlink." >&2
  echo "If you're sure, delete it manually." >&2
  exit 1
else
  echo "Nothing to remove: no new-project found at $LINK."
  echo "(If you installed with a custom PREFIX, run: PREFIX=/your/dir ./uninstall.sh)"
fi

cat <<EOF

This only removed the launcher link. Still on disk (delete manually if you want):
  - the tool repo:  $REPO
  - any projects you created with new-project
  - a PATH line you may have added to ~/.zshrc for $TARGET_DIR
EOF
