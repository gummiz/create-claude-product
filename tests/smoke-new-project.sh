#!/usr/bin/env bash
set -uo pipefail

# Smoke test for bin/new-project. Plain bash, no framework.
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$REPO/bin/new-project"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
fail=0
assert() { if eval "$2"; then echo "ok   - $1"; else echo "FAIL - $1"; fail=1; fi; }

# --- guards ---
"$BIN" >/dev/null 2>&1
assert "usage error on no args" '[ "$?" = "2" ]'

mkdir -p "$TMP/exists"
"$BIN" exists --dir "$TMP" --no-launch >/dev/null 2>&1
assert "aborts on existing target" '[ "$?" = "1" ]'

# --- success path ---
"$BIN" demo --dir "$TMP" --no-launch >"$TMP/out.txt" 2>&1
CHILD="$TMP/demo"

assert "child created"                '[ -d "$CHILD" ]'
assert "payload CLAUDE.md copied"     '[ -f "$CHILD/CLAUDE.md" ]'
assert "payload verify.sh copied"     '[ -f "$CHILD/scripts/verify.sh" ]'
assert "verify.sh executable"         '[ -x "$CHILD/scripts/verify.sh" ]'
assert "hook executable"              '[ -x "$CHILD/.claude/hooks/stop-verify.sh" ]'

assert "git initialized"              '[ -d "$CHILD/.git" ]'
assert "exactly one commit"           '[ "$(git -C "$CHILD" rev-list --count HEAD 2>/dev/null)" = "1" ]'
assert "working tree clean"           '[ -z "$(git -C "$CHILD" status --porcelain 2>/dev/null)" ]'

assert "settings.local.json present"  '[ -f "$CHILD/.claude/settings.local.json" ]'
assert "transient skill injected"     '[ -f "$CHILD/.claude/skills/project-bootstrap/SKILL.md" ]'
assert "sentinel present"             '[ -f "$CHILD/.bootstrap/state.json" ]'
assert "sentinel phase 1"             'grep -q "\"phase\": 1" "$CHILD/.bootstrap/state.json"'
assert "sentinel name demo"           'grep -q "\"name\": \"demo\"" "$CHILD/.bootstrap/state.json"'

assert "no-launch printed resume cmd" 'grep -q "Next: cd" "$TMP/out.txt"'
assert "no tool bin leaked"           '[ ! -e "$CHILD/bin/new-project" ]'
assert "no tool docs leaked"          '[ ! -e "$CHILD/docs/superpowers" ]'
assert "bootstrap gitignored"         '[ "$(grep -c project-bootstrap "$CHILD/.gitignore")" -ge 1 ]'

# --- generated settings.json must be valid + free of malformed permission rules ---
assert "settings.json valid JSON"     'python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$CHILD/.claude/settings.json"'
assert "no WebFetch/WebSearch wildcard" '! grep -Eq "WebFetch\(\*\*\)|WebSearch\(\*\*\)" "$CHILD/.claude/settings.json"'
assert "no unmatchable curl-pipe rule"  '! grep -q "curl:\* |" "$CHILD/.claude/settings.json"'

# --- symlinked invocation from an unrelated cwd (global-install path) ---
LINKDIR="$TMP/bin"; mkdir -p "$LINKDIR"
ln -s "$BIN" "$LINKDIR/new-project"
( cd "$TMP" && "$LINKDIR/new-project" linked --dir "$TMP" --no-launch >/dev/null 2>&1 )
assert "symlinked launcher scaffolds"   '[ -f "$TMP/linked/CLAUDE.md" ]'
assert "symlinked launcher copies payload" '[ -f "$TMP/linked/scripts/verify.sh" ]'

exit $fail
