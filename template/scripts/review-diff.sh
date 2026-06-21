#!/usr/bin/env bash
# review-diff.sh — summarize what changed and remind the reviewer what to inspect.
# Read-only. Gives the reviewer agent (or you) a fast orientation before a deep read.
#
# Usage: ./scripts/review-diff.sh [base-ref]   (default: upstream of current branch, else HEAD~1)
# Exits 0 always (reporting tool). TODO: tune the "hot paths" list to your repo's risk areas.

set -uo pipefail

have() { command -v "$1" >/dev/null 2>&1; }
if ! have git || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "review-diff: not a git repo."; exit 0
fi

BASE="${1:-}"
if [ -z "$BASE" ]; then
  BASE="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || true)"
  [ -z "$BASE" ] && BASE="$(git rev-parse HEAD~1 2>/dev/null || echo HEAD)"
fi

echo "=== Review diff vs: $BASE ==="
echo
echo "--- Changed files (with churn) ---"
git diff --stat "$BASE" 2>/dev/null || git diff --stat

echo
echo "--- Files by type ---"
git diff --name-only "$BASE" 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | sort -rn || true

# Flag changes that touch higher-risk areas. TODO: customize these patterns.
echo
echo "--- Heads-up: sensitive areas touched ---"
HOT='auth|login|password|secret|token|payment|billing|migration|schema|\.env|Dockerfile|deploy|crypto|permission'
git diff --name-only "$BASE" 2>/dev/null | grep -E -i "$HOT" || echo "(none matched the hot-path list)"

echo
echo "--- Reviewer checklist ---"
cat <<'CHECKLIST'
  [ ] Each acceptance criterion in the spec's acceptance.md is actually met (point to where).
  [ ] Correctness: edge cases, error handling, state, off-by-ones.
  [ ] Constraints respected (docs/product/constraints.md, quality-attributes.md).
  [ ] Scope: no unrelated changes, reformatting, or scope creep.
  [ ] Safety: no weakened tests/types/checks, no secrets, no destructive ops, inputs validated.
  [ ] Tests: meaningful, not coupled to internals, and they actually run green.
CHECKLIST

exit 0
