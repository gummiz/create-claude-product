# Refactor Workflow

Refactoring changes structure **without changing behavior**. It is its own task — never bundled into a
feature or bugfix. If you find yourself wanting to "clean this up while I'm here," stop and make it a task.

## Preconditions
- There is a **named reason**: reduce duplication, clarify a boundary, enable an upcoming change, cut dead code.
  "It feels cleaner" is not enough. Record the reason (and any decision) in `docs/product/decisions.md` if notable.
- There is a **safety net**: tests cover the behavior you're about to move. If not, add characterization tests first.

## Process
1. **Capture current behavior.** Ensure `./scripts/verify.sh` is green *before* you start. Add tests where coverage is thin.
2. **Define the target shape.** A short note: what moves where, which interfaces stay stable.
3. **Refactor in small, behavior-preserving steps.** Verify after each step. Keep it green continuously.
4. **No behavior changes.** If you discover a needed behavior change, split it into a separate task/commit.
5. **Keep public interfaces stable** unless the refactor's stated goal is to change them (then follow `interfaces.md`).
6. **Delete aggressively.** Removing dead code and needless abstraction is the best refactor. Don't add new ones lightly.

## Verify
- `./scripts/verify.sh` green, with the *same* observable behavior. Diff review confirms no functional change.
- Fresh-context `reviewer` pass: "does this change behavior?" should be answerable "no".

## Anti-patterns to avoid
- Mixing refactor + feature in one diff (impossible to review, risky to revert).
- Reformatting untouched files (pollutes the diff).
- Introducing a framework/abstraction for a single current use (YAGNI — record a decision if you truly need it).
- Renaming widely "for clarity" without that being the task.
