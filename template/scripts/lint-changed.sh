#!/usr/bin/env bash
# lint-changed.sh — lint ONLY the files changed vs the base, for a fast in-loop check.
# Degrades gracefully: no git, no changes, or no linter installed -> exits 0 quietly.
#
# Usage: ./scripts/lint-changed.sh [base-ref]   (default base: origin/HEAD or HEAD)
# TODO: map each extension to the linter your project actually uses.

set -uo pipefail

BASE="${1:-}"
have() { command -v "$1" >/dev/null 2>&1; }

if ! have git || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "lint-changed: not a git repo — nothing to scope. Run scripts/verify.sh instead."; exit 0
fi

# Determine a sensible base if none given.
if [ -z "$BASE" ]; then
  BASE="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || true)"
  [ -z "$BASE" ] && BASE="HEAD"
fi

# Changed + staged + unstaged files (existing only).
mapfile -t FILES < <( { git diff --name-only "$BASE" 2>/dev/null; git diff --name-only; git diff --name-only --cached; } \
  | sort -u | while read -r f; do [ -f "$f" ] && echo "$f"; done )

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "lint-changed: no changed files."; exit 0
fi

rc=0
for f in "${FILES[@]}"; do
  case "$f" in
    *.js|*.jsx|*.ts|*.tsx) have eslint && { eslint "$f" || rc=1; } ;;
    *.py)                  if have ruff; then ruff check "$f" || rc=1; elif have flake8; then flake8 "$f" || rc=1; fi ;;
    *.go)                  have go && { go vet "$f" || rc=1; } ;;
    *.rs)                  have cargo && { cargo clippy --quiet || rc=1; } ;;
    *.sh)                  have shellcheck && { shellcheck "$f" || rc=1; }; bash -n "$f" || rc=1 ;;
    # TODO: add cases for your stack.
    *) : ;;
  esac
done

[ "$rc" -eq 0 ] && echo "lint-changed: OK (${#FILES[@]} file(s))."
exit "$rc"
