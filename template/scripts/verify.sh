#!/usr/bin/env bash
# verify.sh — single entry point for verification. Orchestrates lint + test + build for
# whatever stack is present, and DEGRADES GRACEFULLY when a step is unavailable.
#
# Contract:
#   - exit 0 if every step that ran succeeded (a skipped step is not a failure).
#   - exit 1 if any step that ran failed.
#   - prints a clear per-step summary at the end.
#
# Detection is best-effort and stack-agnostic. TODO: replace the auto-detection with your
# project's real commands once the stack is known — explicit is better than clever.

set -uo pipefail

PASS=0; FAIL=0; SKIP=0
declare -a SUMMARY

have() { command -v "$1" >/dev/null 2>&1; }

run_step() {
  # run_step "name" command args...
  local name="$1"; shift
  echo "==> $name: $*"
  if "$@"; then
    SUMMARY+=("PASS  $name"); PASS=$((PASS+1))
  else
    SUMMARY+=("FAIL  $name"); FAIL=$((FAIL+1))
  fi
}

skip() { SUMMARY+=("SKIP  $1"); SKIP=$((SKIP+1)); echo "==> SKIP $1 ($2)"; }

# ---- Node / JS / TS -------------------------------------------------------
if [ -f package.json ]; then
  pm="npm"; have pnpm && [ -f pnpm-lock.yaml ] && pm="pnpm"; have yarn && [ -f yarn.lock ] && pm="yarn"
  has_script() { node -e "process.exit(((require('./package.json').scripts)||{})['$1']?0:1)" 2>/dev/null; }
  has_script lint  && run_step "js lint"  $pm run lint  || skip "js lint"  "no lint script"
  has_script test  && run_step "js test"  $pm test      || skip "js test"  "no test script"
  has_script build && run_step "js build" $pm run build || skip "js build" "no build script"
else
  skip "node" "no package.json"
fi

# ---- Python ---------------------------------------------------------------
if [ -f pyproject.toml ] || [ -f setup.cfg ] || [ -f requirements.txt ]; then
  if have ruff;  then run_step "py lint" ruff check .; else skip "py lint" "ruff not installed"; fi
  if have pytest; then run_step "py test" pytest -q;     else skip "py test" "pytest not installed"; fi
else
  skip "python" "no python project markers"
fi

# ---- Go -------------------------------------------------------------------
if [ -f go.mod ] && have go; then
  run_step "go vet"   go vet ./...
  run_step "go test"  go test ./...
  run_step "go build" go build ./...
else
  skip "go" "no go.mod or go not installed"
fi

# ---- Rust -----------------------------------------------------------------
if [ -f Cargo.toml ] && have cargo; then
  run_step "rust test"  cargo test --quiet
  run_step "rust build" cargo build --quiet
else
  skip "rust" "no Cargo.toml or cargo not installed"
fi

# ---- Shell scripts (this template's own scripts/hooks) --------------------
if have bash; then
  run_step "shell syntax" bash -c 'for f in scripts/*.sh .claude/hooks/*.sh; do [ -e "$f" ] && bash -n "$f" || true; done'
fi

# TODO: add your project's custom steps here (e.g. typecheck, integration tests, schema checks).

echo
echo "------ verify summary ------"
printf '%s\n' "${SUMMARY[@]:-(no steps ran)}"
echo "PASS=$PASS FAIL=$FAIL SKIP=$SKIP"

[ "$FAIL" -eq 0 ] || exit 1

if [ "$PASS" -eq 0 ]; then
  echo "NOTE: nothing ran — wire this script to your stack (see TODOs)." >&2
fi
exit 0
