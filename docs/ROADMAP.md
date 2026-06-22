# Roadmap / Backlog

Parked ideas for improving `create-claude-product`. **Nothing here is started.** When you pick one
up, branch off `main` (`git checkout -b <name>`), build it, open a PR — `main` is what the installed
`new-project` command tracks, so keep it stable.

Author liked all of these; stated focus is **interview + template**, plus the **new design-phase gap**
(Theme 2).

---

## Theme 1 — Make a bootstrapped project actually runnable & verifiable  *(highest impact)*

Today the interview ends with good docs and a stack *decision*, but no runnable code, and the
generated `scripts/verify.sh` / `lint-changed.sh` / `test-changed.sh` still contain `TODO`s — so the
"ready-to-implement first feature" promise is thin.

- [ ] **A. Real stack scaffolding + script wiring.** In interview Phase 2, generate a minimal runnable
  app for the chosen stack **and** replace the `TODO`s in `verify/lint/test` so the project's
  automation genuinely works (verify truly green, not just "shell syntax OK").
- [ ] **B. Curated stack menu by project type.** Branch on web app / API / CLI / library / static
  site and offer recommended stacks via `AskUserQuestion`, instead of a generic "propose 2–3."
- [ ] **E. CI stub in the template.** Ship `.github/workflows/verify.yml` so generated projects run
  `./scripts/verify.sh` on push out of the box.
- [ ] **F. Template polish.** Add `.editorconfig`; small `verify.sh` stack auto-detection improvements.

## Theme 2 — Add a design phase  *(NEW — currently missing entirely)*

The flow is product → architecture → spec → code, with **no design step**. After the architecture is
validated, the project should either be **reviewed by a designer** or have a **design brief handed
off** to one. Human vs. agent designer is out of scope for now — the point is the brief/handoff exists.

- [ ] **G. Insert a design checkpoint after architecture validation.** For UI-bearing projects,
  produce a **design brief** (e.g. `docs/design/brief.md`: intent, audience, key screens/flows, tone,
  constraints).
- [ ] **H. Route the brief for review.** Hand it to a designer — human (export/share) or agent (a
  design-review skill/subagent) — and fold feedback back before the spec phase.
- [ ] Open question: does design sit *between* architecture and spec, or run *parallel* to spec?
  Decide when picking this up.

## Theme 3 — Interview polish

- [ ] **C. Confirm name + one-line pitch up front** (the dir name came from the CLI; let the user set
  the human-facing name and pitch first).
- [ ] **D. Completion summary + "what's next"** before the skill removes its own machinery (point at
  `verify.sh`, the delivery workflow, and the seeded first spec).

## Theme 4 — Distribution & repo hygiene (the tool itself)

- [ ] **I. Easier public install.** Add an `npx create-claude-product` / Homebrew tap / curl one-liner
  so strangers don't have to clone + run `install.sh` manually.
- [ ] **J. CI for this repo.** GitHub Actions running `tests/smoke-new-project.sh` on every push/PR,
  with a status badge in the README.

---

## Working notes

- **Workflow:** feature branches + PRs; keep `main` stable (installed command tracks it).
- **Where things live:** payload that ships = `template/`; the interview = `.claude/skills/project-bootstrap/SKILL.md`;
  tool-only build files (`tests/`, `docs/superpowers/`) never ship. See the README "How it works" table.
- **Retired:** the old `claude-code-template` repo is gone — all template changes go in `template/` here.
