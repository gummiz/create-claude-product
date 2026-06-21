---
name: project-bootstrap
description: Use when a freshly scaffolded project contains a .bootstrap/state.json sentinel — runs the phased new-project interview (product docs → architecture + stack → first spec), resumable across sessions, and removes itself when complete. Injected transiently by the new-project launcher; not for hand-invocation in established repos.
---

# Project Bootstrap Interview

> STATUS: skeleton — behavior pending (see
> docs/superpowers/specs/2026-06-21-new-project-bootstrapper-design.md and the implementation plan).

Runs inside a newly scaffolded child project to take it from empty `TODO` docs to a
ready-to-implement first feature. Phased, checkpointed, and resumable via `.bootstrap/state.json`.

## On entry

1. Read `.bootstrap/state.json`. If absent, this skill does not apply — stop.
2. Resume at the recorded `phase`.

## Phases

Each phase: interview → write docs → verify/sanity-check where applicable → commit → bump
`state.json`. Every phase boundary is a **clean exit point** (committed, valid repo).

### Phase 1 · Product
Fill `docs/product/{vision,constraints,glossary}.md`; seed `docs/product/decisions.md`.
Reuse brainstorming-style one-question-at-a-time Q&A.

### Phase 2 · Architecture + stack
Propose 2–3 stacks → user picks → record an ADR in `decisions.md`; fill `docs/architecture/*`;
scaffold **minimal-but-runnable** structure so `verify.sh` is green. Offer (don't force) a fuller
starter. Reuse `repo-conventions`.

### Phase 3 · First spec
Seed `docs/specs/<feature>/` from `template/new-spec/`; run the spec interview. Reuse `spec-writing`.

## On completion (after Phase 3)

Delete `.bootstrap/` and `.claude/skills/project-bootstrap/` so the child becomes a clean,
normal repo with no bootstrap machinery left behind.

## Checklist

- [ ] Resumes from the recorded phase, never restarts completed phases
- [ ] Each phase commits before advancing
- [ ] A stop after any phase leaves a valid, usable repo
- [ ] On completion, `.bootstrap/` and this skill are removed
