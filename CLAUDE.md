# create-claude-product — Operating Guide

This repo is the **bootstrapper tool** for the Claude Code product template. Keep this file short.

## What this repo is
- `bin/new-project` — deterministic launcher (bash). No judgment; just scaffold + hand off.
- `template/` — the payload. A copy of the product template. **Edit the template here**, going
  forward; the standalone `claude-code-template` repo is frozen.
- `.claude/skills/project-bootstrap/` — the interview skill, injected transiently into each new
  project and self-removed on completion. Tool-only; never shipped permanently to children.
- `tests/` — launcher smoke test.
- `docs/superpowers/specs/` — design specs for this tool (NOT part of `template/`, never stamped).

## Critical boundary
- Anything that should reach generated projects goes in `template/`. Anything tool-only
  (`bin/`, this `CLAUDE.md`, the README, `docs/superpowers/`, the `project-bootstrap` skill) must
  stay OUT of `template/`. The payload is an allowlist — keep it clean.

## Source of truth
- Design + contract: `docs/superpowers/specs/2026-06-21-new-project-bootstrapper-design.md`.
- Work spec-first. Plan before changing the launcher or the skill's phase contract.
