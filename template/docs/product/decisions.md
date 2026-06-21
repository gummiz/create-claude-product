# Decision Log

> Lightweight ADRs. Record any decision that's expensive to reverse or that someone might
> later ask "why did we do it this way?". New dependencies, frameworks, and abstractions go here.
> Append-only. Don't rewrite history — supersede with a new entry.

## How to add one
Copy the block below to the top of the list. Keep each entry to a few lines.

```
### ADR-NNN: <title>
- Date: YYYY-MM-DD
- Status: proposed | accepted | superseded by ADR-XXX
- Context: <what forced a decision>
- Decision: <what we chose>
- Consequences: <trade-offs, what this rules out, follow-ups>
- Alternatives rejected: <option — why not>
```

---

### ADR-000: Adopt this project template
- Date: TODO
- Status: accepted
- Context: Need a consistent, low-token, verification-strong, sandbox-aware setup across products.
- Decision: Use this stack-agnostic Claude Code template; keep it small.
- Consequences: Conventions live in `CLAUDE.md` + `docs/`; guardrails in hooks; how-to in skills.
- Alternatives rejected: Ad-hoc per-project setup — inconsistent and high-friction.
