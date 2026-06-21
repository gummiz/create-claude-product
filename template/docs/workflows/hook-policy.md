# Hook Policy

Hooks enforce the things that must happen **every time**, deterministically — independent of whether the
model remembers. They are the floor, not the brain.

## Principles
- **Deterministic.** Same input → same result. No randomness, no model calls.
- **Fast.** Milliseconds, not seconds. They run on every matching tool call. Defer slow work to scripts run on demand.
- **Script-based.** Plain shell in `.claude/hooks/`. Versioned, reviewable, testable with `bash -n` and by hand.
- **Fail safe.** On any ambiguity or internal error, **exit 0 (allow)** rather than blocking work — except the
  dedicated *block* hooks, whose entire job is to deny known-dangerous actions.
- **Narrow.** Each hook does one thing. Don't pile logic into one mega-hook.

## What hooks ARE allowed to do
- Block a specific, known-dangerous command or a write to a protected path (deterministic pattern match).
- Run a fast formatter or linter on just-changed files and surface the result.
- Trigger verification on stop (delegating to `scripts/verify.sh`).
- Emit a short message or a non-zero exit to signal "stop / fix this".

## What hooks must NEVER do
- **Never call an LLM** or anything nondeterministic/network-dependent in the hot path.
- **Never run long or heavy work** (full test suites, builds, installs) inline — delegate to a script the model/user runs.
- **Never mutate source in surprising ways** beyond agreed formatting. No auto-refactors, no content rewrites.
- **Never depend on a specific stack being present** — detect and no-op if the tool is missing.
- **Never leak secrets** or print sensitive file contents.
- **Never hard-block normal work** due to their own bugs. Guard everything; default to allow.

## Hook types and their purpose
- **PreToolUse** (`pretool-*`): gate an action *before* it runs.
  - `pretool-block-dangerous-bash.sh` — deny destructive shell commands (rm -rf /, disk wipes, fork bombs…).
  - `pretool-protect-sensitive-paths.sh` — deny writes to secrets/infra/lockfiles unless explicitly intended.
- **PostToolUse** (`posttool-*`): react *after* a successful action, usually on file writes.
  - `posttool-format-changed.sh` — format the changed file if a formatter exists.
  - `posttool-lint-changed.sh` — lint the changed file and surface issues (non-fatal).
- **Stop** (`stop-*`): run when Claude is about to finish a turn.
  - `stop-verify.sh` — run `scripts/verify.sh` if present, so a turn doesn't end on a broken state.

## Important containment note
Hooks run in **your** environment, not inside the bash sandbox. A misbehaving or malicious hook can do real
damage. Keep them small, audited, and deterministic — and do high-risk work in full-process isolation
(see `sandbox-policy.md`).

## Adding a hook (checklist)
- [ ] Does it *have* to be automatic every time? If not, make it a script instead.
- [ ] Is it deterministic, fast, and stack-tolerant (no-op when tooling absent)?
- [ ] Does it fail safe (allow on error), except for intentional block hooks?
- [ ] `bash -n` clean and manually tested on a sample payload?
- [ ] Wired in `.claude/settings.json` with the right matcher.
