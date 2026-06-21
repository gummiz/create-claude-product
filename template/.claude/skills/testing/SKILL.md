---
name: testing
description: Use when adding or changing behavior, or fixing a bug — write tests that catch real regressions and verify them with the project's runner.
---

# Testing

Use this whenever a change alters behavior. Tests are how "done" becomes provable rather than asserted.

## Inputs
- The behavior being added/changed, the acceptance criteria, and the project's test setup (see `system-map.md`).

## Steps
1. **Match the existing style.** Find sibling tests; mirror their structure, naming, and helpers.
2. **Test behavior, not implementation.** Assert on observable outcomes so refactors don't break tests needlessly.
3. **Cover:** the happy path, the boundaries (empty/null/max), and the error path. One clear assertion focus per test.
4. **For bugfixes:** write a test that *fails* on the current bug first, then fix until green (see `bugfix.md`).
5. **Run scoped, then full:** `./scripts/test-changed.sh` while iterating; `./scripts/verify.sh` before done.

## Outputs
- Tests that fail when the behavior breaks and pass when it works, integrated with the project runner.

## Constraints
- Never weaken or delete a test to make a change pass. If a test is wrong, fix it deliberately and say why.
- Avoid brittle tests coupled to internals, timing, or output formatting unless that's the contract.
- Don't mock what you're trying to verify. Keep tests fast and deterministic.
- Report real run output — "should pass" is not a result.
