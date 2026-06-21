#!/usr/bin/env bash
set -euo pipefail

# install.sh — put `new-project` on your PATH so you can run it from anywhere.
#
# Usage:   ./install.sh            # links into ~/.local/bin
#          PREFIX=/usr/local/bin ./install.sh   # custom target dir

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_SRC="$REPO/bin/new-project"
TARGET_DIR="${PREFIX:-$HOME/.local/bin}"

chmod +x "$BIN_SRC"
mkdir -p "$TARGET_DIR"
ln -sf "$BIN_SRC" "$TARGET_DIR/new-project"
echo "Linked: $TARGET_DIR/new-project -> $BIN_SRC"

case ":$PATH:" in
  *":$TARGET_DIR:"*)
    echo
    echo "Ready. From any directory, run:"
    echo "    new-project my-app"
    ;;
  *)
    echo
    echo "NOTE: $TARGET_DIR is not on your PATH yet. Add this line to ~/.zshrc:"
    echo "    export PATH=\"$TARGET_DIR:\$PATH\""
    echo "then restart your shell (or run: source ~/.zshrc)."
    echo
    echo "Until then you can run it directly:"
    echo "    $BIN_SRC my-app"
    ;;
esac
