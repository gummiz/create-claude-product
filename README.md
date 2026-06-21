# create-claude-product

The **Claude Code product template** — a small, opinionated, stack-agnostic starting point for
building digital products end-to-end with Claude Code — bundled with a one-command installer that
stamps it into a new project and runs a guided setup interview.

The template is the point. `new-project` is just the handy way to stamp it out and fill it in; you
can always copy [`template/`](template/) by hand instead.

## What you get — the template

The template optimizes for four things: **consistency** across projects, **low token usage**,
**strong verification**, and **safe autonomy**. It works for frontend-heavy, backend-heavy, and
mixed work, and is deliberately small — prune what you don't use.

| Piece | Where (in a generated project) | Purpose |
|---|---|---|
| **Operating guide** | `CLAUDE.md` | Short, high-signal rules always in context (kept under ~120 lines). |
| **Docs (source of truth)** | `docs/` | Product intent, architecture, and workflows — read on demand. |
| **Hooks** | `.claude/hooks/` | Deterministic guardrails that run *every time*: block dangerous bash, protect sensitive paths, format/lint changed files, verify on stop. |
| **Agents** | `.claude/agents/` | Few, specialized: `researcher`, `implementer`, `reviewer`, `qa`. |
| **Skills** | `.claude/skills/` | On-demand how-to: `spec-writing`, `repo-conventions`, `testing`, `ui`, `api`, `release`. |
| **Scripts** | `scripts/` | Deterministic work: `verify`, `lint-changed`, `test-changed`, `sandbox-preflight`, `review-diff`. |
| **Spec scaffold** | `template/new-spec/` | Starting point for spec-driven feature work. |

**The philosophy (how the pieces divide labor):** `CLAUDE.md` holds what's true *every* session;
**skills** carry detailed how-to loaded *only when relevant* (cheap context); **hooks** enforce what
must happen *automatically and deterministically*; **scripts** capture deterministic work once;
**agents** give isolated context for research/build/review/QA; **sandboxing** scales isolation to how
much autonomy a task needs. Work flows **product → architecture → spec → code**, in small verified
batches.

Full template docs live in [`template/README.md`](template/README.md) and ship inside every project
you create.

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

`install.sh` tells you if that directory isn't on your PATH yet and prints the one line to add. If
[`gum`](https://github.com/charmbracelet/gum) isn't installed, it offers to install it (via Homebrew)
for an arrow-key model picker — say no and the plain numbered picker is used instead. Prefer not to
install at all? Skip this step and call the launcher by its full path — e.g.
`~/create-claude-product/bin/new-project my-app`.

**Step 3 — Create a project.** From the directory where you want the new project to live:

```bash
new-project my-app                # creates ./my-app here, then launches the interview
new-project my-app --dir ~/Code   # create it under ~/Code instead
new-project my-app --model sonnet # launch with a specific model (skips the picker)
new-project my-app --no-launch    # scaffold only; don't launch Claude
```

Just before Claude opens, the launcher shows a short overview of what's about to happen (the three
interview phases) and asks **which model** to run the interview with — Opus (recommended), Sonnet,
or your Claude Code default. Pass `--model <name>` to skip that prompt.

Once inside, Claude first asks **how you want to be guided** — *Fast-track* (it picks sensible
defaults, stops only at big forks), *Guide me* (every question offers options with a recommendation),
or *Manual* (full control) — then walks the three phases. Questions come as selectable lists with
pre-filled options and a marked recommendation, so you're never answering from a blank page.

The new project is created as a sibling folder in your current directory (like `git clone`), **not**
inside the tool repo. `new-project` copies `template/` into it, runs `git init` with a pristine
commit, makes scripts/hooks executable, seeds local settings, injects the transient interview skill,
writes the `.bootstrap/state.json` sentinel, and launches Claude into the bootstrap interview — which
fills the docs, records a stack, and seeds your first spec, then removes its own bootstrap machinery.

## How it works

This repo has two layers: **the payload that ships** and **the tooling that builds/installs it**.
Only `template/` (plus the transiently-injected interview skill) ever reaches a generated project —
everything else is tool-only and never copied out.

| Piece | Layer | Role |
|---|---|---|
| `template/` | **ships** | The payload — the Claude Code product template. Only its contents reach a generated project. |
| `.claude/skills/project-bootstrap/` | **ships (transient)** | The interview skill, injected into each new project and removed when bootstrap completes. |
| `bin/new-project` | tooling | Deterministic launcher: copy `template/` → child, git init, inject the skill, launch Claude. Resolves its own location through symlinks so the PATH install works. |
| `install.sh` / `uninstall.sh` | tooling | Add or remove the `new-project` symlink on your PATH. |
| `tests/` | tooling | Launcher smoke test — proves the scaffold is correct and that no tool-only file leaks into a child. |
| `docs/superpowers/` | tooling | This tool's own design spec + implementation plan (how it was built). Never shipped. |

That separation is enforced, not just documented: `template/` is an explicit allowlist (a child gets
exactly `cp -R template/`), and the smoke test asserts none of the tooling leaks in.

## Uninstall

```bash
cd create-claude-product
./uninstall.sh            # removes the `new-project` symlink from ~/.local/bin
PREFIX=/usr/local/bin ./uninstall.sh   # if you installed with a custom PREFIX
```

This only removes the launcher symlink. It does **not** touch this repo, any projects you created,
or a PATH line you may have added to `~/.zshrc`. To remove the tool entirely, also delete the cloned
repo folder. Uninstalling does nothing to projects already generated — they're independent git repos.

## Design

- Standalone tool, separate from the template, so the manual path is never lost.
- `template/` is an explicit allowlist payload — only what's in it can reach a child (fails closed).
- The interview is phased and resumable; every phase boundary is a clean, valid exit point.

Full rationale: [`docs/superpowers/specs/2026-06-21-new-project-bootstrapper-design.md`](docs/superpowers/specs/2026-06-21-new-project-bootstrapper-design.md).
