#!/usr/bin/env bash
# test-changed.sh — run a fast, scoped test pass during the implement→verify loop.
#
# Truly scoping tests to changed files is stack-specific, so by default this runs the
# project's standard test command (which is usually fast enough in-loop) and leaves
# hooks for you to narrow it. Degrades gracefully if no runner is found.
#
# Usage: ./scripts/test-changed.sh [base-ref]
# TODO: replace the bodies below with your runner's "related tests" mode, e.g.:
#   jest --onlyChanged ; vitest related <files> ; pytest <impacted paths> ; go test <pkgs>

set -uo pipefail

BASE="${1:-}"
have() { command -v "$1" >/dev/null 2>&1; }

# ---- Node / JS / TS -------------------------------------------------------
if [ -f package.json ]; then
  pm="npm"; have pnpm && [ -f pnpm-lock.yaml ] && pm="pnpm"; have yarn && [ -f yarn.lock ] && pm="yarn"
  if node -e "process.exit(((require('./package.json').scripts)||{})['test']?0:1)" 2>/dev/null; then
    # TODO: prefer a changed-only mode, e.g. `npx jest --onlyChanged` or `npx vitest related`.
    echo "test-changed: running project test script ($pm test)"; exec $pm test
  fi
fi

# ---- Python ---------------------------------------------------------------
if have pytest && { [ -f pyproject.toml ] || [ -f setup.cfg ] || ls tests >/dev/null 2>&1; }; then
  echo "test-changed: running pytest"; exec pytest -q
fi

# ---- Go -------------------------------------------------------------------
if [ -f go.mod ] && have go; then
  echo "test-changed: running go test ./..."; exec go test ./...
fi

# ---- Rust -----------------------------------------------------------------
if [ -f Cargo.toml ] && have cargo; then
  echo "test-changed: running cargo test"; exec cargo test --quiet
fi

echo "test-changed: no recognized test runner — adapt this script to your stack (see TODOs)."
exit 0
