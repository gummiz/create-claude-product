# New-Project Bootstrapper Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `bin/new-project`, a bash launcher that deterministically scaffolds a new project from `template/` and hands off to the phased `project-bootstrap` interview skill.

**Architecture:** A single bash launcher does the deterministic work (copy payload → git init → chmod → inject transient skill → write sentinel → launch Claude). A plain-bash smoke test drives it via a `--no-launch` seam. The interview skill (`project-bootstrap`) is prompt content, fleshed out separately and verified by its own checklist + a manual dry run.

**Tech Stack:** Bash, git, plain-bash test harness (no test framework dependency).

## Global Constraints

- Bash only; **no new dependencies** (no `bats`, no node) — tests are plain bash.
- `template/` is an **allowlist payload**: nothing tool-only (`bin/`, tool `README.md`, tool `CLAUDE.md`, `docs/superpowers/`, the `project-bootstrap` skill) may reach a generated child.
- The launcher copies the payload exactly as-is; it does not edit child docs.
- Commit messages in generated children: `chore: scaffold from template`.
- Sentinel format: `.bootstrap/state.json` = `{ "phase": <int>, "name": "<str>", "created": "<iso8601>" }`, starting at phase 1.
- Report real command output; never weaken or hide failures.

---

### Task 1: Launcher arg parsing + guards + test harness

**Files:**
- Modify: `bin/new-project` (replace skeleton)
- Test: `tests/smoke-new-project.sh` (replace skeleton)

**Interfaces:**
- Produces: CLI `new-project <name> [--dir <parent>] [--no-launch]`. Exit codes: `2` = usage error, `1` = runtime abort (e.g. target exists, payload missing), `0` = success.

- [ ] **Step 1: Write the failing test**

Replace `tests/smoke-new-project.sh` with:

```bash
#!/usr/bin/env bash
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$REPO/bin/new-project"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
fail=0
assert() { if eval "$2"; then echo "ok   - $1"; else echo "FAIL - $1"; fail=1; fi; }

# --- guards ---
"$BIN" >/dev/null 2>&1;            assert "usage error on no args"   '[ "$?" = "2" ]'
mkdir -p "$TMP/exists"
"$BIN" exists --dir "$TMP" --no-launch >/dev/null 2>&1
assert "aborts on existing target" '[ "$?" = "1" ]'

exit $fail
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/smoke-new-project.sh`
Expected: FAIL lines (skeleton exits 1 for everything, so the no-args case reports the wrong code).

- [ ] **Step 3: Write minimal implementation**

Replace `bin/new-project` with:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$ROOT_DIR/template"
SKILL_SRC="$ROOT_DIR/.claude/skills/project-bootstrap"

usage() {
  cat >&2 <<'EOF'
Usage: new-project <name> [--dir <parent>] [--no-launch]

  <name>          Name (and directory) of the new project.
  --dir <parent>  Parent directory to create it in (default: current dir).
  --no-launch     Scaffold only; do not launch Claude.
EOF
}
die() { echo "new-project: $*" >&2; exit 1; }

NAME=""
PARENT="$PWD"
LAUNCH=1
while [ $# -gt 0 ]; do
  case "$1" in
    --dir) shift; [ $# -gt 0 ] || { usage; exit 2; }; PARENT="$1" ;;
    --no-launch) LAUNCH=0 ;;
    -h|--help) usage; exit 0 ;;
    -*) usage; exit 2 ;;
    *) [ -z "$NAME" ] || { usage; exit 2; }; NAME="$1" ;;
  esac
  shift
done
[ -n "$NAME" ] || { usage; exit 2; }

[ -d "$TEMPLATE_DIR" ] || die "template payload not found at $TEMPLATE_DIR"

TARGET="$PARENT/$NAME"
[ -e "$TARGET" ] && die "target already exists: $TARGET"

echo "new-project: scaffolding $TARGET (steps pending)" >&2
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash tests/smoke-new-project.sh`
Expected: `ok - usage error on no args` and `ok - aborts on existing target`.

- [ ] **Step 5: Commit**

```bash
git add bin/new-project tests/smoke-new-project.sh
git commit -m "feat(launcher): arg parsing, usage + target-exists guards, test harness"
```

---

### Task 2: Copy payload + make scripts/hooks executable

**Files:**
- Modify: `bin/new-project` (replace the final `echo` placeholder with copy + chmod)
- Test: `tests/smoke-new-project.sh` (add a success-path block)

**Interfaces:**
- Consumes: `$TARGET`, `$TEMPLATE_DIR` from Task 1.
- Produces: after a successful run, `$TARGET` contains the payload with `scripts/*.sh` and `.claude/hooks/*.sh` executable.

- [ ] **Step 1: Add the failing assertions**

In `tests/smoke-new-project.sh`, insert this block **before** the `exit $fail` line:

```bash
# --- success path ---
"$BIN" demo --dir "$TMP" --no-launch >"$TMP/out.txt" 2>&1
CHILD="$TMP/demo"
assert "child created"               '[ -d "$CHILD" ]'
assert "payload CLAUDE.md copied"     '[ -f "$CHILD/CLAUDE.md" ]'
assert "payload verify.sh copied"     '[ -f "$CHILD/scripts/verify.sh" ]'
assert "verify.sh executable"         '[ -x "$CHILD/scripts/verify.sh" ]'
assert "hook executable"              '[ -x "$CHILD/.claude/hooks/stop-verify.sh" ]'
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/smoke-new-project.sh`
Expected: FAIL on "child created" (the launcher only echoes today).

- [ ] **Step 3: Write minimal implementation**

In `bin/new-project`, replace the final line
`echo "new-project: scaffolding $TARGET (steps pending)" >&2`
with:

```bash
# 1. copy payload
mkdir -p "$TARGET"
cp -R "$TEMPLATE_DIR"/. "$TARGET"/

# 2. make scripts + hooks executable
chmod +x "$TARGET"/scripts/*.sh 2>/dev/null || true
chmod +x "$TARGET"/.claude/hooks/*.sh 2>/dev/null || true
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash tests/smoke-new-project.sh`
Expected: all five new assertions `ok`.

- [ ] **Step 5: Commit**

```bash
git add bin/new-project tests/smoke-new-project.sh
git commit -m "feat(launcher): copy payload and chmod scripts/hooks"
```

---

### Task 3: Template `.gitignore` + git init + initial commit

**Files:**
- Create: `template/.gitignore`
- Modify: `bin/new-project` (append git init/commit after chmod)
- Test: `tests/smoke-new-project.sh` (add git assertions)

**Interfaces:**
- Consumes: `$TARGET` from Task 2.
- Produces: `$TARGET/.git` with exactly one commit; a clean working tree (machine-local + bootstrap files are gitignored by the payload's `.gitignore`).

- [ ] **Step 1: Create the template `.gitignore`**

Create `template/.gitignore`:

```gitignore
# Machine-local Claude config + overrides (never committed)
.claude/settings.local.json
CLAUDE.local.md

# Transient bootstrap machinery (present only during new-project bootstrap)
.bootstrap/
.claude/skills/project-bootstrap/

# OS / editor noise
.DS_Store
*.log
```

- [ ] **Step 2: Add the failing assertions**

In `tests/smoke-new-project.sh`, append inside the success-path block (before `exit $fail`):

```bash
assert "git initialized"   '[ -d "$CHILD/.git" ]'
assert "exactly one commit" '[ "$(git -C "$CHILD" rev-list --count HEAD 2>/dev/null)" = "1" ]'
assert "working tree clean" '[ -z "$(git -C "$CHILD" status --porcelain 2>/dev/null)" ]'
```

- [ ] **Step 3: Run test to verify it fails**

Run: `bash tests/smoke-new-project.sh`
Expected: FAIL on "git initialized".

- [ ] **Step 4: Write minimal implementation**

In `bin/new-project`, append after the chmod block:

```bash
# 3. git init + initial commit (pristine template)
git -C "$TARGET" init -q
git -C "$TARGET" add -A
git -C "$TARGET" \
  -c user.name="${GIT_AUTHOR_NAME:-$(git config user.name 2>/dev/null || echo create-claude-product)}" \
  -c user.email="${GIT_AUTHOR_EMAIL:-$(git config user.email 2>/dev/null || echo noreply@example.com)}" \
  commit -qm "chore: scaffold from template"
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bash tests/smoke-new-project.sh`
Expected: the three git assertions `ok`. (Working tree is clean because the local settings, sentinel, and transient skill added in Task 4 are all gitignored.)

- [ ] **Step 6: Commit**

```bash
git add template/.gitignore bin/new-project tests/smoke-new-project.sh
git commit -m "feat(launcher): git init + initial commit; add template .gitignore"
```

---

### Task 4: Local settings + inject transient skill + sentinel

**Files:**
- Modify: `bin/new-project` (append settings copy, skill injection, sentinel write)
- Test: `tests/smoke-new-project.sh` (add assertions)

**Interfaces:**
- Consumes: `$TARGET`, `$SKILL_SRC`, `$NAME` from earlier tasks.
- Produces: `$TARGET/.claude/settings.local.json`; `$TARGET/.claude/skills/project-bootstrap/SKILL.md`; `$TARGET/.bootstrap/state.json` with `phase: 1` and `name`.

- [ ] **Step 1: Add the failing assertions**

In `tests/smoke-new-project.sh`, append inside the success-path block:

```bash
assert "settings.local.json present" '[ -f "$CHILD/.claude/settings.local.json" ]'
assert "transient skill injected"    '[ -f "$CHILD/.claude/skills/project-bootstrap/SKILL.md" ]'
assert "sentinel present"            '[ -f "$CHILD/.bootstrap/state.json" ]'
assert "sentinel phase 1"            'grep -q "\"phase\": 1" "$CHILD/.bootstrap/state.json"'
assert "sentinel name demo"          'grep -q "\"name\": \"demo\"" "$CHILD/.bootstrap/state.json"'
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/smoke-new-project.sh`
Expected: FAIL on "settings.local.json present".

- [ ] **Step 3: Write minimal implementation**

In `bin/new-project`, append after the git commit block:

```bash
# 4. seed local settings from the example
if [ -f "$TARGET/.claude/settings.local.example.json" ]; then
  cp "$TARGET/.claude/settings.local.example.json" "$TARGET/.claude/settings.local.json"
fi

# 5. inject the transient bootstrap skill
[ -d "$SKILL_SRC" ] || die "bootstrap skill not found at $SKILL_SRC"
mkdir -p "$TARGET/.claude/skills/project-bootstrap"
cp -R "$SKILL_SRC"/. "$TARGET/.claude/skills/project-bootstrap"/

# 6. write the sentinel
mkdir -p "$TARGET/.bootstrap"
created="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
cat > "$TARGET/.bootstrap/state.json" <<EOF
{
  "phase": 1,
  "name": "$NAME",
  "created": "$created"
}
EOF
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash tests/smoke-new-project.sh`
Expected: the five new assertions `ok`, and "working tree clean" from Task 3 still `ok` (all three additions are gitignored).

- [ ] **Step 5: Commit**

```bash
git add bin/new-project tests/smoke-new-project.sh
git commit -m "feat(launcher): seed local settings, inject bootstrap skill, write sentinel"
```

---

### Task 5: Launch handoff + leak guards

**Files:**
- Modify: `bin/new-project` (append launch/handoff)
- Test: `tests/smoke-new-project.sh` (add handoff + leak assertions)

**Interfaces:**
- Consumes: `$TARGET`, `$LAUNCH` from earlier tasks.
- Produces: with `--no-launch` (or no `claude` on PATH), prints the resume command and exits 0 without launching; otherwise `exec claude` in `$TARGET`.

- [ ] **Step 1: Add the failing assertions**

In `tests/smoke-new-project.sh`, append inside the success-path block:

```bash
assert "no-launch printed resume cmd" 'grep -q "Next: cd" "$TMP/out.txt"'
assert "no tool bin leaked"           '[ ! -e "$CHILD/bin/new-project" ]'
assert "no tool docs leaked"          '[ ! -e "$CHILD/docs/superpowers" ]'
assert "no tool skill leaked into payload copy" '[ "$(grep -c project-bootstrap "$CHILD/.gitignore")" -ge 1 ]'
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/smoke-new-project.sh`
Expected: FAIL on "no-launch printed resume cmd" (nothing is printed yet).

- [ ] **Step 3: Write minimal implementation**

In `bin/new-project`, append at the end:

```bash
# 7. launch the interview, or hand off
PROMPT="A new project was just scaffolded from the template. A .bootstrap/state.json sentinel is present — run the project-bootstrap interview to take it from here."

if [ "$LAUNCH" -eq 1 ] && command -v claude >/dev/null 2>&1; then
  cd "$TARGET"
  exec claude "$PROMPT"
fi

echo "Scaffolded $TARGET"
echo "Next: cd \"$TARGET\" && claude \"$PROMPT\""
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash tests/smoke-new-project.sh`
Expected: all assertions `ok`, exit 0.

- [ ] **Step 5: Commit**

```bash
git add bin/new-project tests/smoke-new-project.sh
git commit -m "feat(launcher): launch handoff with --no-launch seam and leak guards"
```

---

### Task 6: Flesh out the `project-bootstrap` interview skill

**Files:**
- Modify: `.claude/skills/project-bootstrap/SKILL.md`

**Interfaces:**
- Consumes: `.bootstrap/state.json` written by the launcher (Task 4).
- Produces: a complete phase contract the skill follows at runtime. (Prompt content — verified by the in-skill checklist + a manual dry run, not by an automated test.)

- [ ] **Step 1: Replace the skill body with the full phase contract**

Overwrite `.claude/skills/project-bootstrap/SKILL.md` keeping the existing frontmatter, expanding each phase with concrete instructions:

```markdown
# Project Bootstrap Interview

Runs inside a freshly scaffolded child project to take it from empty `TODO` docs to a
ready-to-implement first feature. Phased, checkpointed, resumable via `.bootstrap/state.json`.

## On entry
1. Read `.bootstrap/state.json`. If absent, this skill does not apply — stop.
2. Resume at the recorded `phase`. Never re-run a completed phase.
3. Reuse the project's own skills where noted; do not duplicate their logic here.

## Phase 1 · Product  (writes docs/product/*)
Ask one question at a time (purpose, target user, problem, constraints, must-nots, key terms).
Fill `docs/product/vision.md`, `constraints.md`, `glossary.md`; add the first ADR(s) to
`decisions.md` only if a real decision was made. Delete prompt comments as you fill each section.
Then: `git add docs/product && git commit -m "docs: product vision, constraints, glossary"`,
set `state.json` phase to 2. This is a clean exit point.

## Phase 2 · Architecture + stack  (writes docs/architecture/*, scaffolds runnable structure)
Propose 2–3 stack options with trade-offs and a recommendation. On the user's choice, record an
ADR in `docs/product/decisions.md`, fill `docs/architecture/{overview,system-map,interfaces,quality-attributes}.md`,
and scaffold the **minimal runnable** structure for that stack so `./scripts/verify.sh` is green.
Offer (do not force) a fuller starter. Add stack-specific entries to `.gitignore`.
Run `./scripts/verify.sh` and report the real output. Then commit and set phase to 3.

## Phase 3 · First spec  (seeds docs/specs/<feature>/)
Ask what the first feature is. Copy `template/new-spec/` to `docs/specs/<feature>/` and run the
spec interview (reuse the project's `spec-writing` skill). Commit.

## On completion (after Phase 3)
Delete `.bootstrap/` and `.claude/skills/project-bootstrap/`, then commit
`chore: remove bootstrap machinery`. The child is now a normal repo.

## Checklist
- [ ] Resumes from the recorded phase; never restarts a completed phase
- [ ] Each phase commits before advancing and is a valid stopping point
- [ ] Phase 2 leaves `verify.sh` green (real output reported)
- [ ] On completion, `.bootstrap/` and this skill are removed
```

- [ ] **Step 2: Manual verification (no automated test)**

Re-read the skill and confirm: every phase names the exact files it writes, every phase commits, and the completion step removes both `.bootstrap/` and the skill. Fix inline if not.

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/project-bootstrap/SKILL.md
git commit -m "feat(skill): full project-bootstrap phase contract"
```

---

### Task 7: README status + end-to-end dry run

**Files:**
- Modify: `README.md` (drop the "under construction" note)
- Test: full `tests/smoke-new-project.sh` run

- [ ] **Step 1: Run the full smoke test**

Run: `bash tests/smoke-new-project.sh`
Expected: every line `ok`, exit 0.

- [ ] **Step 2: Manual end-to-end dry run**

Run: `bin/new-project scratch --dir /tmp --no-launch`
Then inspect `/tmp/scratch`: confirm git log has one commit, `cat /tmp/scratch/.bootstrap/state.json` shows phase 1, and `ls /tmp/scratch/bin` does not exist. Remove `/tmp/scratch` after.

- [ ] **Step 3: Update README**

In `README.md`, delete the blockquote line beginning `> Status: under construction.`

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: mark launcher ready; verified end-to-end"
```

---

## Self-Review

**Spec coverage:**
- Launcher steps 1–9 → Tasks 2–5. ✓
- `template/` allowlist / no leak → Task 5 leak guards. ✓
- Transient skill inject + removal → injected Task 4, removal contract in Task 6. ✓
- Sentinel + resumability → Task 4 (write), Task 6 (resume/clean-exit). ✓
- Phase 1/2/3 content → Task 6. ✓
- `verify.sh` green, real output → Task 6 Phase 2. ✓
- Degrade when `claude` absent → Task 5. ✓
- Testing (smoke test + manual skill check) → Tasks 1–5 (smoke), Task 6 (manual), Task 7 (dry run). ✓
- Docker / npx / submodules → out of scope per spec. ✓

**Placeholder scan:** No "TBD"/"implement later"; every code step shows complete code. ✓

**Type/name consistency:** `--no-launch`, `$TARGET`, `$TEMPLATE_DIR`, `$SKILL_SRC`, `$NAME`, sentinel keys (`phase`/`name`/`created`) used identically across tasks. ✓
