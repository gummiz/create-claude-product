# Bugfix Workflow

For fixing defects. The discipline: **reproduce before you fix, and prove the fix with a test.**
Don't shotgun changes at a symptom.

## 1. Reproduce
- Get a reliable, minimal repro. If you can't reproduce it, you can't confirm a fix.
- Capture the exact inputs, environment, and observed vs expected behavior.

## 2. Locate the root cause
- Trace from symptom to cause. Use `docs/architecture/system-map.md` to navigate.
- Consider the `researcher` agent for unfamiliar areas. Read before changing.
- Distinguish the *root cause* from the *first place it surfaced*. Fix the cause.

## 3. Write a failing test
- Add a test that fails because of the bug (and would catch a regression). See the `testing` skill.
- For a bug with no natural test seam, note why in `notes.md` and add the closest guard you can.

## 4. Fix — minimal and targeted
- Smallest change that addresses the root cause. No opportunistic refactors in the same diff.
- Match surrounding patterns. Don't weaken types or checks to make it pass.

## 5. Verify
- The new test passes; the full `./scripts/verify.sh` stays green. Report output.
- Check for sibling bugs: did the same mistake get copied elsewhere? Fix or file them.

## 6. Record
- Note root cause and fix in the spec's `notes.md` (or commit body) so the knowledge survives.
- If the bug came from a missing constraint or convention, update `docs/` so it can't recur silently.

## Severity shortcut
- **Trivial & obvious** (typo, off-by-one with clear cause): steps 1, 4, 5. Still verify.
- **Anything else:** the full loop. Reproduction + regression test are not optional for real bugs.
