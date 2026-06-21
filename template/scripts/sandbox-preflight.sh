#!/usr/bin/env bash
# sandbox-preflight.sh — print the checklist/reminders before escalating to a higher-risk
# execution mode (see docs/workflows/sandbox-policy.md). This script INFORMS; it does not
# enforce. It detects whether you appear to be inside isolation and reminds you what to check.
#
# Always exits 0 — it's a reminder, not a gate. TODO: add project-specific checks (e.g. confirm
# pointing at a staging DB, confirm test credentials, confirm egress allowlist).

set -uo pipefail

echo "=== Sandbox preflight (advisory) ==="

# Best-effort isolation detection.
isolation="unknown"
if [ -f /.dockerenv ] || grep -qaE '(docker|containerd|kubepods)' /proc/1/cgroup 2>/dev/null; then
  isolation="container"
elif [ -n "${VM:-}${VAGRANT:-}" ]; then
  isolation="vm (env hint)"
fi
echo "Detected isolation : $isolation"
echo "Working directory  : $(pwd)"
echo "Git branch         : $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'n/a')"
echo

echo "Before HIGH-RISK work, confirm ALL of the following:"
cat <<'CHECKLIST'
  [ ] Running inside full-process isolation (container/VM) — NOT just the bash sandbox.
      (Bash sandboxing does not contain hooks or MCP servers.)
  [ ] Environment is disposable / snapshotted, so you can discard and rebuild.
  [ ] Secrets are scoped to test/throwaway values — no production credentials reachable.
  [ ] Network egress is allowlisted; no unintended outbound calls.
  [ ] Deny list in .claude/settings.json reviewed for the irreversible actions this task could trigger.
  [ ] You know the rollback/recovery procedure for anything this task can change.
CHECKLIST
echo

if [ "$isolation" = "unknown" ]; then
  echo "WARNING: could not confirm you are inside isolation. For high-risk work, escalate to a container/VM." >&2
fi

# TODO: add hard project checks here and `exit 1` if you want this to actually block.
exit 0
