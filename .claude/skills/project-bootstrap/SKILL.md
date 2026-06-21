---
name: project-bootstrap
description: Use when a freshly scaffolded project contains a .bootstrap/state.json sentinel — runs the phased new-project interview (product docs → architecture + stack → first spec), resumable across sessions, and removes itself when complete. Injected transiently by the new-project launcher; not for hand-invocation in established repos.
---

# Project Bootstrap Interview

Runs inside a freshly scaffolded child project to take it from empty `TODO` docs to a
ready-to-implement first feature. Phased, checkpointed, resumable via `.bootstrap/state.json`.

## On entry

1. Read `.bootstrap/state.json`. If absent, this skill does not apply — stop.
2. Resume at the recorded `phase`. Never re-run a completed phase.
3. Reuse the project's own skills where noted; do not duplicate their logic here.
4. **Open warmly before the first question.** Greet by project name and restate the plan in one
   line — e.g. "Setting up *<name>*. I'll ask a few questions across three short phases (product →
   stack → first spec), committing as we go. Stop whenever you like. First up:" — then ask Phase 1's
   first question. On a resume (phase > 1), instead say one line about where we're picking up.
   Keep it to a sentence; the launcher already showed the overview.

## How to ask

- **Use the `AskUserQuestion` tool for any question with a small set of discrete options** —
  target user, stack choice, scaffold depth, the first feature, yes/no forks. It renders a
  selectable list, which is far nicer than plain text and keeps answers structured. Mark the
  recommended option and let the user pick "Other" for anything bespoke.
- **Use plain text** only for genuinely open-ended questions (the one-line pitch, naming a concept).
- One question (or one `AskUserQuestion` batch) at a time. Don't stack unrelated asks.

## Phase 1 · Product  (writes docs/product/*)

Ask one question at a time — purpose, target user, the problem and today's alternatives,
hard constraints, must-nots, and key domain terms. Fill `docs/product/vision.md`,
`docs/product/constraints.md`, and `docs/product/glossary.md`, deleting the prompt comments as you
go. Add an entry to `docs/product/decisions.md` only if a genuine, expensive-to-reverse decision
was made. Then:

```
git add docs/product && git commit -m "docs: product vision, constraints, glossary"
```

Set `state.json` phase to 2. **Clean exit point** — a project that stops here is still valid.

## Phase 2 · Architecture + stack  (writes docs/architecture/*, scaffolds runnable structure)

Propose 2–3 stack options with trade-offs and a recommendation. On the user's choice:
- Record an ADR in `docs/product/decisions.md`.
- Fill `docs/architecture/{overview,system-map,interfaces,quality-attributes}.md`.
- Scaffold the **minimal runnable** structure for that stack so `./scripts/verify.sh` is green.
  Offer a fuller starter (e.g. Vite/Next/FastAPI hello-world) as a choice — do not force it.
- Add stack-specific entries to `.gitignore` (e.g. `node_modules/`, `dist/`, `.venv/`).

Run `./scripts/verify.sh` and report the **real** output — never weaken checks to make it pass.
Commit, then set phase to 3. **Clean exit point.**

## Phase 3 · First spec  (seeds docs/specs/<feature>/)

Ask what the first feature is. Copy `template/new-spec/` to `docs/specs/<feature>/` and run the
spec interview, reusing the project's `spec-writing` skill. Commit
`docs: seed <feature> spec`.

## On completion (after Phase 3)

Remove the bootstrap machinery so the child becomes a normal repo:

```
rm -rf .bootstrap .claude/skills/project-bootstrap
git add -A && git commit -m "chore: remove bootstrap machinery"
```

## Checklist

- [ ] Resumes from the recorded phase; never restarts a completed phase
- [ ] Each phase commits before advancing and is a valid stopping point
- [ ] Phase 2 leaves `./scripts/verify.sh` green, with real output reported
- [ ] On completion, `.bootstrap/` and this skill are removed
