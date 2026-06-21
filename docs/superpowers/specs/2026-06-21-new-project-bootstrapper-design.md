# Design: `create-claude-product` Bootstrapper

- Date: 2026-06-21
- Status: approved (pending implementation plan)
- Scope: A **standalone tool repo** that turns the Claude Code product template into a new,
  interviewed, spec-ready project with one shell command.

## Problem

Starting a new project from this template today is manual: copy the directory, `git init`,
`chmod` the scripts/hooks, copy local settings, then hand-fill a pile of `TODO` placeholders in
`docs/product/*` and `docs/architecture/*` from memory. The deterministic parts are tedious and
the judgment parts (requirements, stack choice, first spec) are exactly where a guided interview
helps most. We want a smooth, single-entry UX that does both — **without entangling the tool with
the template, and without losing the existing manual `cp -R` path.**

## Goals

- One shell command scaffolds a new project and drops the user into a guided interview.
- The interview fills the product docs, picks and records a stack, and seeds the first spec —
  **all the way to a ready-to-implement first feature**.
- A half-finished bootstrap still leaves a valid, usable repo (clean exit at every phase).
- Reuse existing skills (`brainstorming` flow, `repo-conventions`, `spec-writing`) instead of
  duplicating requirements logic.
- The tool lives in its **own repo**, separate from the template. The current template repo is
  **untouched** and remains a working manual fallback.

## Non-goals (deferred)

- **Docker / sandbox isolation.** Deferred. Plugs in later through the template's existing
  `docs/workflows/sandbox-policy.md` + `scripts/sandbox-preflight.sh` seam without changing this
  design.
- **`npx`-style distribution.** A published `create-claude-product` wrapper is a trivial later add
  over the bash launcher; not needed now. (Repo named to make this clean later.)
- **Submodule / subtree syncing.** Not needed — see "Why no drift" below.

## Repository strategy

A **new standalone repo, `create-claude-product`** (the *tool*), which contains a copy of the
template as an explicit *payload*. The existing template repo is **frozen** as the manual fallback.

```
create-claude-product/                  ← the TOOL (new repo)
├── bin/new-project                     ← launcher (bash)
├── .claude/skills/project-bootstrap/   ← interview skill (tool-only, never shipped to children)
├── template/                           ← the PAYLOAD: a copy of the current template's content
│   ├── CLAUDE.md
│   ├── docs/  (product, architecture, workflows, specs)
│   ├── scripts/  (verify, lint-changed, …)
│   ├── .claude/{agents,hooks,skills}/  (spec-writing, repo-conventions, testing, …)
│   └── template/new-spec/
├── tests/                              ← launcher smoke test
└── README.md                          ← about the tool

claude-code-template/                   ← FROZEN: unchanged manual fallback (cp -R still works)
```

### Key decisions and why

- **`template/` is an explicit allowlist payload, not a root-copy-with-excludes.** Stamping a
  child is `cp -R template/ <target>/` — only what is in `template/` can ever reach a child. An
  allowlist *fails closed*; a blocklist of excludes *fails open* (forget one and the launcher/skill
  leak into every generated project). The one extra directory level is worth it.
- **The interview skill is transient in children.** The launcher copies `template/` into the
  child, then injects `project-bootstrap` into the child's `.claude/skills/` for the bootstrap
  session only. On Phase 3 completion the skill **removes itself and `.bootstrap/`**. Generated
  projects never permanently carry bootstrap machinery.
- **The current template repo is frozen as the manual fallback.** It stays exactly as-is. The
  template evolves *inside `create-claude-product/template/`* going forward.
- **Why no drift:** because the frozen repo no longer evolves, there is only **one** living copy of
  the template (inside the tool). No submodule/subtree/sync mechanism is required. The frozen repo
  is an escape hatch, retire-able later, not a parallel product to keep in lockstep.

## Architecture

Three components, split by nature of work (deterministic shell vs. judgment-heavy skill vs. state).

### 1. Launcher — `bin/new-project` (bash)

Deterministic work only, no judgment:

```
new-project <name> [--dir <parent>]
```

Steps:
1. Resolve target path (`<parent>/<name>`, default parent = cwd). **Abort if it already exists.**
2. Locate the tool's own `template/` payload (relative to the script). Abort if missing.
3. `cp -R template/ <target>/`.
4. `git init` + initial commit (`chore: scaffold from template`).
5. `chmod +x <target>/scripts/*.sh <target>/.claude/hooks/*.sh`.
6. `cp <target>/.claude/settings.local.example.json <target>/.claude/settings.local.json`.
7. Inject the transient bootstrap skill: copy the tool's `.claude/skills/project-bootstrap/`
   into `<target>/.claude/skills/project-bootstrap/`.
8. Write sentinel `<target>/.bootstrap/state.json`
   (`{ "phase": 1, "name": "<name>", "created": "<iso>" }`).
9. `exec claude` inside the target with an initial prompt that triggers the interview skill.

**Degradation:** if `claude` is not on `PATH`, steps 1–8 still complete and the launcher prints the
exact next command. Never a dead end.

### 2. Interview skill — `project-bootstrap` (runs inside the child during bootstrap)

Phased, checkpointed, resumable. Reads `.bootstrap/state.json` on entry and resumes at the
recorded phase. Reuses the template's own skills rather than reimplementing them.

| Phase | Produces | Reuses |
|---|---|---|
| 1 · Product | fills `docs/product/{vision,constraints,glossary}.md`; seeds `decisions.md` | brainstorming-style one-question-at-a-time Q&A |
| 2 · Architecture + stack | proposes 2–3 stacks → user picks → records an **ADR** in `decisions.md`; fills `docs/architecture/*`; scaffolds **minimal runnable** structure so `verify.sh` is green | `repo-conventions` |
| 3 · First spec | seeds `docs/specs/<feature>/` from `template/new-spec/`; runs the spec interview | `spec-writing` |

Phase 2 scaffold depth: **minimal-but-runnable** by default (enough that `verify.sh` passes and the
app starts). A fuller starter (e.g. Vite/Next/FastAPI hello-world) is offered as an interview
choice, not forced.

Each phase: write docs → `verify`/sanity-check where applicable → commit → update `state.json`.
**Phase 3 completion also deletes `.bootstrap/` and `.claude/skills/project-bootstrap/`** so the
child becomes a clean normal repo.

### 3. State + resumability — `.bootstrap/state.json`

The mechanism that makes "to first spec" survivable:
- Every phase boundary is a **clean exit point** — its docs are committed, the repo is valid.
- Re-entering Claude resumes from the recorded phase.
- Phase 3 completion removes `.bootstrap/` (and the transient skill); the repo is now normal.

## Data flow

```
$ new-project my-app
  └─ cp -R template/ → child + git init + chmod + inject skill + sentinel   (deterministic, ~5s)
  └─ exec claude (in child) → project-bootstrap reads state.json
       Phase 1 ─ interview ─ write product docs ─ commit ─ [clean exit]
       Phase 2 ─ pick stack ─ ADR + arch docs + scaffold ─ verify ─ commit ─ [clean exit]
       Phase 3 ─ spec interview ─ seed docs/specs/<feature> ─ commit
  └─ skill removes .bootstrap/ + project-bootstrap skill  → normal repo
```

## Error handling

- Target dir exists → abort with message (no clobber).
- `template/` payload not found next to the script → abort.
- `claude` missing → scaffold completes, print next-step command.
- Interview interrupted mid-phase → resumable from last committed phase via `state.json`.
- `verify.sh` failing after Phase 2 scaffold → **report the real output**, do not hide or weaken.

## Testing

- **Launcher smoke test:** scaffold into a temp dir; assert `template/` contents copied, `.git`
  exists, scripts executable, `settings.local.json` present, transient skill injected,
  `.bootstrap/state.json` present, and that **no tool-only files** (`bin/`, tool README) leaked
  into the child.
- **Skill:** prompt-driven; verified by a manual dry-run plus an in-SKILL checklist (phase
  resumability, clean-exit validity, removal of `.bootstrap/` + transient skill on completion).

## Bootstrapping the tool repo itself

`create-claude-product` is created once by copying the current template into `template/` and adding
the `bin/`, skill, and tests layer on top. The frozen `claude-code-template` repo is left untouched.
