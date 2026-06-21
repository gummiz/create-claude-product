# Acceptance: <name>

> The checklist a fresh-context reviewer uses to call this done. Mirror the spec's acceptance
> criteria here as concrete, checkable items. The `reviewer` and `qa` agents work from this file.

## Acceptance criteria
<!-- Each item: the criterion + exactly how to verify it. Copy/refine from spec.md. -->
- [ ] <criterion> — verify: `<command / test / observable behavior>`
- [ ] <criterion> — verify: `<...>`

## Quality gates
- [ ] `./scripts/verify.sh` passes; output captured.
- [ ] No unrelated changes / reformatting (diff stays focused).
- [ ] Existing patterns followed; no undocumented new dependency or abstraction.
- [ ] No weakened tests, types, or checks.
- [ ] Constraints in `docs/product/constraints.md` respected.

## Evidence
<!-- Filled at done-time: real command output / links proving each criterion. "Should pass" is not evidence. -->
-

## Sign-off
- Reviewer verdict: approve | approve-with-nits | changes-required
- QA Go/No-Go:
