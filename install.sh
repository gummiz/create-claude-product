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

print_guide() {
  cat <<'EOF'

  +------------------------------------------------------------+
  |   new-project <name>   ->   ./<name>  +  guided setup       |
  +------------------------------------------------------------+

  How to use it:

    new-project my-app
        |
        +--  creates ./my-app in whatever folder you're in
        +--  git init + a first commit
        +--  launches the interview:  product docs -> stack -> first spec

  Tips:
    new-project my-app --dir ~/Code   # create it somewhere specific
    new-project my-app --no-launch    # just scaffold, skip the interview
EOF
}

case ":$PATH:" in
  *":$TARGET_DIR:"*)
    echo
    echo "Ready! From any directory, run:  new-project <name>"
    print_guide
    ;;
  *)
    echo
    echo "Almost there -- $TARGET_DIR is not on your PATH yet. Add this to ~/.zshrc:"
    echo "    export PATH=\"$TARGET_DIR:\$PATH\""
    echo "then restart your shell (or run: source ~/.zshrc)."
    print_guide
    echo
    echo "  (Until PATH is fixed, run it by full path: $BIN_SRC my-app)"
    ;;
esac

# gum powers the arrow-key model picker. Offer to install it when it's missing.
# Runs after linking, and never aborts the install if it fails.
if ! command -v gum >/dev/null 2>&1; then
  echo
  if command -v brew >/dev/null 2>&1; then
    do_install=1
    if [ -t 0 ]; then
      printf "  Install \`gum\` now for an arrow-key model picker? [Y/n] "
      read -r ans || ans=""
      case "$ans" in [Nn]*) do_install=0 ;; esac
    fi
    if [ "$do_install" -eq 1 ]; then
      echo "  Installing gum (brew install gum)…"
      if brew install gum; then
        echo "  gum installed — the model picker will use an arrow-key list."
      else
        echo "  gum install failed; the plain numbered picker still works. Retry: brew install gum" >&2
      fi
    else
      echo "  Skipped. Install later with: brew install gum"
    fi
  else
    echo "  For an arrow-key model picker, install gum:"
    echo "      https://github.com/charmbracelet/gum#installation"
  fi
fi
