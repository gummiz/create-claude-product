#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash) — deny known-dangerous shell commands.
#
# Protocol: Claude Code sends the tool call as JSON on stdin. We read the command,
# match it against a denylist of clearly destructive patterns, and:
#   - exit 2  -> BLOCK the command (stderr is shown to Claude)
#   - exit 0  -> ALLOW
# This is a BLOCK hook, so its job is to deny. It still fails safe: if anything is
# unparseable, it allows (exit 0) rather than wedging normal work.
#
# TODO: extend DANGEROUS_PATTERNS with commands that are catastrophic in YOUR stack
# (e.g. `terraform destroy`, `kubectl delete ns`, `dropdb`, `flyctl deploy`).

set -uo pipefail

input="$(cat 2>/dev/null || true)"

# Extract the command string. Prefer jq; fall back to the raw payload if jq is absent.
if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
else
  cmd="$input"
fi

# Nothing to inspect -> allow.
[ -z "${cmd:-}" ] && exit 0

# Each entry is an extended-regex matched case-insensitively against the command.
DANGEROUS_PATTERNS=(
  'rm[[:space:]]+(-[a-z]*[rf][a-z]*[[:space:]]+)+(/|~|\*|\.|\$HOME)'  # rm -rf on root/home/glob
  ':\(\)[[:space:]]*\{[[:space:]]*:\|:'                               # fork bomb
  'mkfs(\.|[[:space:]])'                                              # format a filesystem
  '>[[:space:]]*/dev/sd[a-z]'                                         # write to a raw disk
  'dd[[:space:]]+if=.*of=/dev/'                                       # dd onto a device
  'chmod[[:space:]]+-R[[:space:]]+777[[:space:]]+/'                   # chmod 777 root
  'git[[:space:]]+push[[:space:]]+.*--force'                          # force push (defense in depth)
  '(curl|wget)[[:space:]].*\|[[:space:]]*(sudo[[:space:]]+)?(sh|bash)' # curl|sh remote exec
  '>[[:space:]]*/etc/'                                                # clobber system config
)

for pat in "${DANGEROUS_PATTERNS[@]}"; do
  if printf '%s' "$cmd" | grep -E -i -q -- "$pat"; then
    echo "BLOCKED by pretool-block-dangerous-bash: command matched dangerous pattern: $pat" >&2
    echo "If this is genuinely intended, run it manually outside Claude Code, or adjust the hook." >&2
    exit 2
  fi
done

exit 0
