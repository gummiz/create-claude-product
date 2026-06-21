# Release Workflow

Shipping a change to users. Deterministic checklist + a fresh-eyes readiness pass. See the `release` skill
for stack-specific commands. Keep releases small and frequent — small releases are safe releases.

## Pre-release checklist
- [ ] Target scope is complete and matches the spec's acceptance criteria.
- [ ] `./scripts/verify.sh` passes from a clean state; output captured.
- [ ] Fresh-context review done (`reviewer` agent) against `acceptance.md`.
- [ ] No debug code, secrets, or commented-out blocks left in the diff.
- [ ] Migrations (if any) are reversible or have a tested rollback. Data changes reviewed.
- [ ] Changelog / version updated. Notable decisions in `docs/product/decisions.md`.
- [ ] Feature flags / config for the target environment set correctly.

## Release-readiness (use the `qa` agent)
- Confirms verification ran and passed (doesn't take "should pass" for an answer).
- Confirms rollback path exists and is understood.
- Confirms observability: you can tell if this breaks in production.
- Confirms blast radius is acceptable for the chosen execution mode.

## Ship
1. Final `./scripts/verify.sh` on the exact commit being released.
2. Tag / version per project convention.
3. Deploy (project-specific — document the command in `system-map.md` and the `release` skill).
4. Watch the relevant signals immediately after (errors, latency, key metric).

## Rollback
- Know the command/procedure **before** you ship. Write it in the spec's `notes.md`.
- If a signal goes bad, roll back first, diagnose second. Don't debug in production under fire.

## Post-release
- [ ] Verify the change live (smoke check the key flow).
- [ ] Close the spec; move `docs/specs/<name>/` notes anywhere durable knowledge belongs.
- [ ] Record anything that should change the process next time.
