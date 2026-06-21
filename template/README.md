# Claude Code Product Template

A small, opinionated, **stack-agnostic** starting point for building digital products end-to-end with
Claude Code. It optimizes for four things: **consistency** across projects, **low token usage**,
**strong verification**, and **safe autonomy**. It works for frontend-heavy, backend-heavy, and mixed work.

The system is deliberately small. Don't grow it past what you actually use.

## What's in here

| Piece | Where | Purpose |
|---|---|---|
| **Operating guide** | `CLAUDE.md` | Short, high-signal rules always in context. |
| **Docs (source of truth)** | `docs/` | Product intent, architecture, and workflows. Read on demand. |
| **Hooks** | `.claude/hooks/` | Deterministic guardrails that run *every time* (block dangerous bash, protect paths, format/lint, verify on stop). |
| **Agents** | `.claude/agents/` | Few, specialized: researcher, implementer, reviewer, qa. |
| **Skills** | `.claude/skills/` | On-demand how-to (spec-writing, repo-conventions, testing, ui, api, release). |
| **Scripts** | `scripts/` | Deterministic work: verify, lint-changed, test-changed, sandbox-preflight, review-diff. |
| **Spec template** | `template/new-spec/` | Scaffold for spec-driven feature work. |

### How the pieces divide labor (this is the whole philosophy)
- **`CLAUDE.md`** = what's true *every* session. Stays under ~120 lines.
- **Skills** = detailed how-to, loaded *only when relevant*. Keeps context cheap.
- **Hooks** = things that must happen *automatically and deterministically*. No reliance on the model remembering.
- **Scripts** = deterministic work, written once, instead of re-explaining steps in prose every time.
- **Agents** = isolated context for research, implementation, review, and QA.
- **Sandboxing** = how much autonomy is safe for a given task (see `docs/workflows/sandbox-policy.md`).

## Quick start

```bash
# 1. Copy this template into a new project
cp -R claude-code-template my-product && cd my-product
git init

# 2. Make scripts and hooks executable
chmod +x scripts/*.sh .claude/hooks/*.sh

# 3. Set up local config + overrides
cp .claude/settings.local.example.json .claude/settings.local.json   # optional, gitignored
cp CLAUDE.local.example.md CLAUDE.local.md                            # optional, gitignored

# 4. Fill in the product docs (these drive everything)
#    docs/product/vision.md, constraints.md, glossary.md
#    docs/architecture/overview.md, system-map.md

# 5. Point the scripts at your stack
#    Edit scripts/verify.sh, lint-changed.sh, test-changed.sh (search for TODO)

# 6. Open the project in Claude Code and start working.
./scripts/verify.sh   # confirms the scripts run and degrade gracefully
```

## Starting a new project from this template
1. Copy the tree, `git init`, `chmod +x` the scripts and hooks.
2. Fill `docs/product/vision.md` + `constraints.md` — these are the highest-leverage files.
3. Sketch `docs/architecture/overview.md` and `system-map.md` (boundaries, not detail).
4. Adapt `scripts/verify.sh`, `lint-changed.sh`, `test-changed.sh` to your stack (each has TODOs).
5. Review `.claude/settings.json` permissions and harden the deny list for your context.
6. Delete any docs/skills/agents you won't use. Smaller is better.

## Creating a new feature spec
```bash
name=checkout-redesign
mkdir -p docs/specs/$name
cp template/new-spec/* docs/specs/$name/
```
Then follow `docs/workflows/delivery.md`: fill `spec.md` → `plan.md` → `tasks.md`, implement in small
batches, run `./scripts/verify.sh`, do a fresh-context review against `acceptance.md`, then release.
See the `spec-writing` skill for how to write a good spec.

## Working with Claude Code using this template
- Let `CLAUDE.md` set the rules; it's always loaded.
- Ask Claude to **plan first** for anything multi-file or ambiguous (it should, by default).
- Invoke skills by name when relevant ("use the testing skill", "use spec-writing").
- Use agents for isolation: `researcher` to explore, `implementer` to build, `reviewer`/`qa` to check.
- Let hooks do the enforcing — don't rely on remembering to format, lint, or verify.
- Choose an execution mode up front (`docs/workflows/sandbox-policy.md`). Higher autonomy → stronger isolation.

## The role of each safety layer
- **Permissions** (`.claude/settings.json`): allow / ask / deny for tools and commands. Conservative by default.
- **Hooks**: enforce the must-happen-every-time rules deterministically. See `docs/workflows/hook-policy.md`.
- **Sandboxing**: bash sandbox for everyday work; full-process isolation (container/VM) for high-risk autonomy.
  Bash sandboxing alone does **not** contain hooks or MCP servers — escalate isolation accordingly.

## Pruning & extending without bloat
- **Prune:** delete unused skills, agents, docs, and permission entries. An empty doc is debt; remove it.
- **Extend:** add a skill only when you've repeated the same instructions 2–3 times. Add a hook only for
  things that must be automatic and deterministic. Add a script when a prompt keeps re-explaining steps.
- Keep `CLAUDE.md` under ~120 lines. If it's growing, the detail belongs in a doc or skill instead.
