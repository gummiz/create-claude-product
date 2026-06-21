# create-claude-product

A one-command bootstrapper for the Claude Code product template. It scaffolds a new project and
then runs a guided interview that fills the product docs, picks and records a stack, and seeds the
first spec — leaving you with a ready-to-implement first feature.

This is the **tool**. The template it stamps out lives in [`template/`](template/). The original
[`claude-code-template`](../claude-code-template) repo is kept frozen as a manual `cp -R` fallback.

## Usage

```bash
bin/new-project my-app            # scaffold ../my-app, then launch the bootstrap interview
bin/new-project my-app --dir ~/Code
```

The launcher copies `template/` into the new directory, runs `git init` with a pristine commit,
makes scripts/hooks executable, seeds local settings, injects the transient interview skill, writes
the `.bootstrap/state.json` sentinel, and launches Claude into the bootstrap interview. Use
`--no-launch` to scaffold without launching.

## How it works

| Piece | Role |
|---|---|
| `bin/new-project` | Deterministic launcher: copy `template/` → child, git init, inject the interview skill, launch Claude. |
| `template/` | The payload — a copy of the Claude Code product template. Only its contents reach a generated project. |
| `.claude/skills/project-bootstrap/` | The interview skill, injected transiently into each new project and removed when bootstrap completes. |
| `tests/` | Launcher smoke test. |

## Design

- Standalone tool, separate from the template, so the manual path is never lost.
- `template/` is an explicit allowlist payload — only what's in it can reach a child (fails closed).
- The interview is phased and resumable; every phase boundary is a clean, valid exit point.

Full rationale: [`docs/superpowers/specs/2026-06-21-new-project-bootstrapper-design.md`](docs/superpowers/specs/2026-06-21-new-project-bootstrapper-design.md).
