# Project Operating Guide

Stack-agnostic template for building digital products end-to-end. Keep this file short.
Detail lives in `docs/` and `.claude/skills/` — read those on demand, not by default.

## Operating model
- Work spec-first for anything non-trivial. Source of truth flows: product → architecture → spec → code.
- Small batches. Implement, verify, then move on. Don't bundle unrelated changes.
- Prefer existing patterns over new ones. Match the surrounding code's style, naming, and structure.
- Leave the codebase consistent. Tidy only what you touch.

## Source-of-truth docs (read when relevant)
- `docs/product/` — vision, constraints, glossary, decisions (the "why" and "must-nots").
- `docs/architecture/` — overview, system-map, interfaces, quality-attributes (the "shape").
- `docs/workflows/` — delivery (the core loop), sandbox-policy, hook-policy, bugfix, refactor, release.
- `docs/specs/` — one folder per feature, scaffolded from `template/new-spec/`.

## When to plan first
- Plan before coding if the task spans multiple files, changes interfaces, or is ambiguous.
- For a feature: create a spec (`docs/specs/<name>/`) → plan → tasks → implement → verify → review.
- Trivial, localized edits (typo, one-line fix) can skip the spec. Everything else gets one.

## Verification (run before declaring done)
- `./scripts/verify.sh` — orchestrates lint + test + build for whatever stack is present; degrades gracefully.
- `./scripts/lint-changed.sh` / `./scripts/test-changed.sh` — scope checks to changed files during a loop.
- Never claim done without running verification and reporting real output. Failures are reported, not hidden.

## Boundaries (avoid unnecessary churn)
- No drive-by refactors. If a refactor is warranted, follow `docs/workflows/refactor.md` as its own task.
- No new dependencies, frameworks, or abstractions without a recorded decision in `docs/product/decisions.md`.
- No reformatting files you didn't change. No renames "for clarity" unless the task is the rename.
- Don't weaken tests, checks, or types to make something pass.

## When to use agents (`.claude/agents/`)
- `researcher` — explore docs/code/options before deciding. Read-heavy, low write scope.
- `implementer` — execute an approved spec + plan.
- `reviewer` — fresh-context diff review against acceptance criteria and risks.
- `qa` — run verification and release-readiness checks.
- Use a subagent when the work benefits from isolated context or a fresh-eyes pass. Don't spawn for trivial tasks.

## When to use skills (`.claude/skills/`)
- On-demand only. Invoke when the task matches the skill's "when to use":
  - `spec-writing`, `repo-conventions`, `testing`, `ui-implementation`, `api-design`, `release`.
- Skills carry the detailed how-to so this file and your context stay lean.

## Safety & autonomy
- Hooks enforce the non-negotiables every time (dangerous-bash block, sensitive-path guard, format/lint, stop-verify).
- Pick an execution mode per `docs/workflows/sandbox-policy.md`: local-safe, focused-autonomous, or high-risk.
- High-risk work (broad autonomy, untrusted input, network mutations) belongs in full-process isolation (container/VM),
  because bash sandboxing alone does not contain hooks or MCP.

## Local overrides
- Copy `CLAUDE.local.example.md` → `CLAUDE.local.md` for machine-specific notes (not committed).
