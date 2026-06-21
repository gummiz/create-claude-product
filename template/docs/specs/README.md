# Specs

One folder per feature/change lives here: `docs/specs/<name>/`. Each is scaffolded from
`template/new-spec/` and drives the delivery loop in `docs/workflows/delivery.md`.

## Create a new spec
```bash
name=<short-kebab-name>
mkdir -p docs/specs/$name
cp template/new-spec/* docs/specs/$name/
```

## What each file is for
| File | Purpose |
|---|---|
| `spec.md` | Problem, goal, scope, non-goals, acceptance criteria. The "what" and "why". |
| `plan.md` | Approach: files, sequence, interfaces, risks, rollback. The "how". |
| `tasks.md` | Small, independently verifiable batches with status. |
| `acceptance.md` | The checklist a reviewer uses to call it done. |
| `notes.md` | Decisions, surprises, rollback steps, anything the next person needs. |

## Conventions
- Keep one active spec focused. Don't let a spec sprawl into many features.
- Use the `spec-writing` skill for how to write these well.
- When shipped, the spec stays as a record. Promote durable knowledge to `docs/` (decisions, architecture).

## Index of specs
<!-- TODO: list active/recent specs here, or delete this section if you prefer the filesystem as the index. -->
- _none yet_
