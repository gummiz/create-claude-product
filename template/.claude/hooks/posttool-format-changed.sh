#!/usr/bin/env bash
# PostToolUse hook (matcher: Write|Edit) — format the file that was just changed.
#
# Detects a formatter by file extension and runs it on the single changed file only.
# Always exits 0: formatting is best-effort and must never block or fail a turn.
# No-ops silently if no suitable formatter is installed (stack-tolerant).
#
# TODO: add the formatters your project uses. Keep it to FAST, single-file formatting.

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

case "$path" in
  *.js|*.jsx|*.ts|*.tsx|*.json|*.css|*.scss|*.md|*.html|*.yaml|*.yml)
    if have prettier; then prettier --write "$path" >/dev/null 2>&1 || true; fi
    ;;
  *.py)
    if have ruff; then ruff format "$path" >/dev/null 2>&1 || true
    elif have black; then black -q "$path" >/dev/null 2>&1 || true; fi
    ;;
  *.go)
    if have gofmt; then gofmt -w "$path" >/dev/null 2>&1 || true; fi
    ;;
  *.rs)
    if have rustfmt; then rustfmt "$path" >/dev/null 2>&1 || true; fi
    ;;
  *.sh)
    if have shfmt; then shfmt -w "$path" >/dev/null 2>&1 || true; fi
    ;;
  # TODO: add cases for your stack.
esac

exit 0
