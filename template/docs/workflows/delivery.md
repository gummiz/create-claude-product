# Delivery Workflow (the core loop)

This is the default lifecycle for any non-trivial change. Trivial, localized fixes may skip to
"Implement → Verify". Everything else follows the full loop. The goal: small, verified, reviewable steps.

```
spec  →  plan  →  tasks  →  implement (small batches)  →  verify  →  fresh-context review  →  release
                                  ↑___________________________|  (loop per batch)
```

## 1. Spec  (`docs/specs/<name>/spec.md`)
- Scaffold: `mkdir -p docs/specs/<name> && cp template/new-spec/* docs/specs/<name>/`.
- Capture problem, goal, scope, **non-goals**, and acceptance criteria. Use the `spec-writing` skill.
- A spec is good when a reviewer can judge "done" without asking you questions.

## 2. Plan  (`plan.md`)
- Turn the spec into an approach: key files, sequence, interfaces touched, risks, rollback.
- Note where you'll deviate from existing patterns and why (usually: don't).
- Get the plan reviewed before writing code if the change is risky or large. Consider the `researcher` agent first.

## 3. Tasks  (`tasks.md`)
- Break the plan into small, independently verifiable batches. Each task should be a few files at most.
- Order so the system stays runnable between tasks. Mark dependencies.

## 4. Implement in small batches
- Take one task. Prefer existing patterns. Don't expand scope mid-task.
- Write or update tests alongside the change (see `testing` skill). For UI use `ui-implementation`; for APIs `api-design`.
- Keep the diff focused — no drive-by refactors or reformatting.

## 5. Verify (every batch)
- Run `./scripts/verify.sh` (or `./scripts/lint-changed.sh` + `./scripts/test-changed.sh` for speed in-loop).
- Fix failures before moving on. Never advance on red. Report real output, not "should pass".

## 6. Fresh-context review
- Use the `reviewer` agent (clean context) against `acceptance.md` + the diff.
- `./scripts/review-diff.sh` summarizes what changed and what to inspect.
- Check: meets acceptance criteria, respects constraints, no scope creep, no weakened checks, risks handled.

## 7. Release  (see `release.md` + `release` skill)
- Final `./scripts/verify.sh`, update changelog/version, confirm release-readiness with the `qa` agent, ship.

## Definition of done
- [ ] Meets every acceptance criterion in `acceptance.md`.
- [ ] `./scripts/verify.sh` passes; output reported.
- [ ] Diff reviewed against criteria and constraints (fresh context).
- [ ] No unrelated changes; existing patterns followed.
- [ ] Decisions worth keeping recorded in `docs/product/decisions.md`.
- [ ] `notes.md` updated with anything the next person needs.
