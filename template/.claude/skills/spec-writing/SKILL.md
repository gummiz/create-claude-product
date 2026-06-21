---
name: spec-writing
description: Use when starting any non-trivial feature or change, before planning or coding — turns a fuzzy request into a clear, testable spec in docs/specs/<name>/.
---

# Spec Writing

Use this when a request is bigger than a one-line fix. A good spec lets a reviewer judge "done"
without asking you anything.

## Inputs
- The request / problem, the relevant `docs/product/` (vision, constraints), and `docs/architecture/` context.

## Steps
1. Scaffold: `mkdir -p docs/specs/<name> && cp template/new-spec/* docs/specs/<name>/`.
2. Fill `spec.md`:
   - **Problem** — the real pain, not the proposed solution.
   - **Goal** — restate intent + the constraint envelope (differs from the raw ask).
   - **Scope** and **Non-goals** — name the tempting-but-excluded version explicitly.
   - **Acceptance criteria** — each one *checkable*: a command, a test, or an observable behavior.
   - **Risks** — real ones, each with a mitigation.
3. Sanity check against `docs/product/constraints.md`. If it conflicts, resolve before planning.

## Outputs
- A complete `spec.md` (and started `acceptance.md`) that the `implementer` and `reviewer` can act on cold.

## Constraints / quality bar
- Acceptance criteria must be verifiable, not prose ("p95 < 200ms", not "fast").
- Always include at least one non-goal. Scope without non-goals drifts.
- Don't design the implementation here — that's `plan.md`. Capture *what* and *why*, not *how*.
- Keep it to a page. If it needs more, it's probably several specs.
