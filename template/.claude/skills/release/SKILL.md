---
name: release
description: Use when preparing to ship a change to users — runs the release checklist, confirms readiness, and ships with a known rollback.
---

# Release

Use this at the end of the delivery loop, when a change is built, verified, and reviewed. Pairs with
`docs/workflows/release.md` (the full checklist) and the `qa` agent (the readiness pass).

## Inputs
- A reviewed, verified change; the spec's `acceptance.md`; project deploy + rollback commands (`system-map.md`).

## Steps
1. **Final verify:** `./scripts/verify.sh` on the exact commit to ship. Capture output.
2. **Readiness pass:** run the `qa` agent against `docs/workflows/release.md`. Resolve any No-Go.
3. **Housekeeping:** changelog/version bump, notable decisions logged, flags/config set for the target env, no debug/secrets in diff.
4. **Migrations:** confirm reversible or rollback tested. Know the rollback command *before* shipping.
5. **Ship:** tag/version, deploy, then immediately watch errors/latency/the key metric.
6. **Confirm live:** smoke-check the key flow. Close the spec.

## Outputs
- A shipped change, a captured verification record, and a written rollback path.

## Constraints
- Never ship on red or unverified checks. "Should pass" is not readiness.
- Prefer small, frequent releases over big-bang ones — smaller blast radius.
- If a signal goes bad post-deploy: roll back first, diagnose second.
