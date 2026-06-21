#!/usr/bin/env bash
# PostToolUse hook (matcher: Write|Edit) — lint the just-changed file and surface issues.
#
# Runs a fast, single-file lint. Lint findings are SURFACED to Claude (printed) but do
# NOT hard-fail the turn — we exit 0 so the model can read and decide. Make it blocking
# only if your team really wants that (exit 2), but prefer surfacing over blocking here.
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
