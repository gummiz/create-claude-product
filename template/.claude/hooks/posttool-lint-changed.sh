#!/usr/bin/env bash
# PostToolUse hook (matcher: Write|Edit) — lint the just-changed file.
#
# Runs a fast, single-file lint and prints findings to the transcript. Note: on exit 0,
# a PostToolUse hook's stderr shows in the session/transcript but is NOT fed back into
# the model's context — only exit 2 does that. We stay non-blocking on purpose: lint
# noise shouldn't halt every edit, and stop-verify.sh is the real gate before a turn ends.
# Flip to exit 2 if you want lint to actively block AND be surfaced to the model.
# No-ops if no linter is installed (stack-tolerant).
#
# TODO: wire the linters your project uses. Keep them fast and scoped to one file.

set -uo pipefail

input="$(cat 2>/dev/null || true)"

if command -v jq >/dev/null 2>&1; then
  path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
else
  path="$(printf '%s' "$input" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]+"' | head -n1 | sed -E 's/.*:"([^"]+)"/\1/' || true)"
fi

[ -z "${path:-}" ] && exit 0
[ -f "$path" ] || exit 0

have() { command -v "$1" >/dev/null 2>&1; }
out=""

case "$path" in
  *.js|*.jsx|*.ts|*.tsx)
    if have eslint; then out="$(eslint "$path" 2>&1 || true)"; fi
    ;;
  *.py)
    if have ruff; then out="$(ruff check "$path" 2>&1 || true)"
    elif have flake8; then out="$(flake8 "$path" 2>&1 || true)"; fi
    ;;
  *.go)
    if have go; then out="$(go vet "$path" 2>&1 || true)"; fi
    ;;
  *.rs)
    if have cargo; then out="$(cargo clippy --quiet 2>&1 || true)"; fi
    ;;
  *.sh)
    if have shellcheck; then out="$(shellcheck "$path" 2>&1 || true)"; fi
    ;;
  # TODO: add cases for your stack.
esac

if [ -n "${out//[[:space:]]/}" ]; then
  echo "Lint findings for $path:" >&2
  printf '%s\n' "$out" >&2
fi

exit 0
