#!/usr/bin/env bash
# PreToolUse hook (matcher: Write|Edit) — deny writes to sensitive/protected paths.
#
# Reads the target file path from the tool call JSON and blocks (exit 2) if it matches
# a protected pattern: secrets, credentials, CI/infra config, lockfiles. Fails safe:
# if the path can't be determined, it ALLOWS (exit 0) rather than blocking work.
#
# TODO: tailor PROTECTED_PATTERNS to your repo. Lockfiles are included because Claude
# should not hand-edit them — regenerate via the package manager instead. Remove that
# line if you have a workflow where editing them is expected.

set -uo pipefail

input="$(cat 2>/dev/null || true)"

if command -v jq >/dev/null 2>&1; then
  path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
else
  # Best-effort extraction without jq.
  path="$(printf '%s' "$input" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]+"' | head -n1 | sed -E 's/.*:"([^"]+)"/\1/' || true)"
fi

# Unknown path -> allow (fail safe).
[ -z "${path:-}" ] && exit 0

PROTECTED_PATTERNS=(
  '(^|/)\.env($|\.)'            # .env, .env.local, etc.
  '(^|/)secrets?/'             # secret/ or secrets/ directories
  '\.pem$'                     # private keys / certs
  '\.key$'
  '(^|/)id_rsa($|\.)'          # ssh keys
  '(^|/)\.git/'               # internal git state
  '(^|/)\.github/workflows/'  # CI definitions (TODO: relax if you edit these via Claude)
  '(^|/)(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Cargo\.lock|poetry\.lock|go\.sum)$' # lockfiles
)

for pat in "${PROTECTED_PATTERNS[@]}"; do
  if printf '%s' "$path" | grep -E -q -- "$pat"; then
    echo "BLOCKED by pretool-protect-sensitive-paths: '$path' is a protected path ($pat)." >&2
    echo "Edit it manually if intended, or adjust PROTECTED_PATTERNS in the hook." >&2
    exit 2
  fi
done

exit 0
