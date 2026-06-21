#!/usr/bin/env bash
# Stop hook — runs when Claude is about to end its turn.
#
# Delegates to scripts/verify.sh if present, so a turn doesn't end on a broken state.
# Behavior is intentionally conservative:
#   - If verify.sh is missing or not executable -> no-op, exit 0.
#   - If verify.sh passes -> exit 0.
#   - If verify.sh fails -> print the tail of its output and exit 0 (SURFACE, don't trap).
#
# Why surface instead of block: a Stop hook that exits non-zero forces Claude to keep
# going, which can loop. Surfacing the failure lets the model/user decide. Flip to
# `exit 2` ONLY if you deliberately want the model forced to fix before stopping.
#
# TODO: set BLOCK_ON_FAIL=1 if you want failing verification to force another iteration.

set -uo pipefail
BLOCK_ON_FAIL="${BLOCK_ON_FAIL:-0}"

# Drain stdin (hook payload) so we don't leave a broken pipe.
cat >/dev/null 2>&1 || true

if [ ! -x ./scripts/verify.sh ]; then
  # Not set up (or not executable) -> nothing to enforce.
  exit 0
fi

out="$(./scripts/verify.sh 2>&1)"
status=$?

if [ "$status" -ne 0 ]; then
  echo "stop-verify: ./scripts/verify.sh FAILED (exit $status). Tail of output:" >&2
  printf '%s\n' "$out" | tail -n 30 >&2
  if [ "$BLOCK_ON_FAIL" = "1" ]; then
    exit 2
  fi
fi

exit 0
