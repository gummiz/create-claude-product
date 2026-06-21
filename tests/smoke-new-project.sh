#!/usr/bin/env bash
set -euo pipefail

# Smoke test for bin/new-project.
# STATUS: skeleton — assertions pending (see implementation plan).
#
# Planned assertions (scaffold into a temp dir and check):
#   - template/ contents copied into the child
#   - child has .git (git init ran)
#   - scripts/*.sh and .claude/hooks/*.sh are executable
#   - .claude/settings.local.json present
#   - .claude/skills/project-bootstrap/ injected (transient skill)
#   - .bootstrap/state.json present with phase=1
#   - NO tool-only files leaked into the child (bin/, tool README, tool docs/superpowers)

echo "smoke-new-project: not yet implemented (skeleton)." >&2
exit 1
