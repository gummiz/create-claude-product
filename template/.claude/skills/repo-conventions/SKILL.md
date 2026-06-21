---
name: repo-conventions
description: Use before writing or changing code in an unfamiliar area — discover and follow this repo's existing patterns instead of inventing new ones.
---

# Repo Conventions

Use this whenever you're about to add code and aren't certain how this project already does the thing.
The rule from `CLAUDE.md`: prefer existing patterns. This skill is how you find them.

## Inputs
- The area you're about to change, plus `docs/architecture/system-map.md` for where to look.

## Steps
1. **Find a sibling.** Locate 1–2 existing files that do something similar (`Grep`/`Glob`). Read them fully.
2. **Extract the pattern:** naming, file layout, error handling, logging, tests, imports, formatting.
3. **Mirror it.** Match structure and style. New code should look like it was there already.
4. **Check tooling:** read configs (linter/formatter/test runner) and any `.editorconfig`. Honor them.
5. **If no pattern exists** for what you need, that's a small design decision — pick the boring option and,
   if notable, record it in `docs/product/decisions.md`.

## Outputs
- Code that's consistent with the surrounding codebase; no new style or structure introduced casually.

## Constraints
- Don't reformat or restructure files you weren't asked to change.
- Don't introduce a new pattern when an adequate one exists — consistency beats personal preference.
- One concept, one name — align with `docs/product/glossary.md`.
