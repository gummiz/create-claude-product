# create-claude-product

A one-command bootstrapper for the Claude Code product template. It scaffolds a new project and
then runs a guided interview that fills the product docs, picks and records a stack, and seeds the
first spec — leaving you with a ready-to-implement first feature.

This is the **tool**. The template it stamps out lives in [`template/`](template/). The original
[`claude-code-template`](../claude-code-template) repo is kept frozen as a manual `cp -R` fallback.

## Prerequisites

- `git`
- [Claude Code](https://claude.com/claude-code) CLI on your PATH (optional — without it the tool
  still scaffolds the project and prints the command to start the interview yourself).

## Getting started

**Step 1 — Get the tool (once).** Clone this repo anywhere you like:

```bash
git clone git@github.com:gummiz/create-claude-product.git
cd create-claude-product
```

**Step 2 — Make `new-project` runnable from anywhere (once).**

```bash
./install.sh          # symlinks `new-project` into ~/.local/bin
```

`install.sh` tells you if that directory isn't on your PATH yet and prints the one line to add.
Prefer not to install? Skip this step and call the launcher by its full path instead — e.g.
`~/create-claude-product/bin/new-project my-app`.

**Step 3 — Create a project.** From the directory where you want the new project to live:

```bash
new-project my-app                # creates ./my-app here, then launches the interview
new-project my-app --dir ~/Code   # create it under ~/Code instead
new-project my-app --no-launch    # scaffold only; don't launch Claude
```

The new project is created as a sibling folder in your current directory (like `git clone`), **not**
inside the tool repo. `new-project` copies `template/` into it, runs `git init` with a pristine
commit, makes scripts/hooks executable, seeds local settings, injects the transient interview skill,
writes the `.bootstrap/state.json` sentinel, and launches Claude into the bootstrap interview — which
fills the docs, records a stack, and seeds your first spec, then removes its own bootstrap machinery.

## How it works

| Piece | Role |
|---|---|
| `install.sh` | Symlinks `new-project` onto your PATH so it runs from any directory. |
| `bin/new-project` | Deterministic launcher: copy `template/` → child, git init, inject the interview skill, launch Claude. Resolves its own location through symlinks, so the PATH install works. |
| `template/` | The payload — a copy of the Claude Code product template. Only its contents reach a generated project. |
| `.claude/skills/project-bootstrap/` | The interview skill, injected transiently into each new project and removed when bootstrap completes. |
| `tests/` | Launcher smoke test. |

## Design

- Standalone tool, separate from the template, so the manual path is never lost.
- `template/` is an explicit allowlist payload — only what's in it can reach a child (fails closed).
- The interview is phased and resumable; every phase boundary is a clean, valid exit point.

Full rationale: [`docs/superpowers/specs/2026-06-21-new-project-bootstrapper-design.md`](docs/superpowers/specs/2026-06-21-new-project-bootstrapper-design.md).
