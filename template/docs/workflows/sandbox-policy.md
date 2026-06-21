# Sandbox & Execution Policy

How much autonomy is safe depends on what the work can touch. Pick a mode **before** starting, and
escalate isolation as risk rises. The core rule: **more autonomy / more untrusted input → stronger isolation.**

## The three execution modes

### 1. local-safe (default)
- **When:** normal development on a trusted repo; reversible, local changes.
- **Autonomy:** Claude proposes; you approve writes and commands per the permission rules. `ask` stays on.
- **Isolation:** your normal working checkout. Built-in bash sandbox on for command execution.
- **Network:** read-only / fetches you expect. No production mutations.

### 2. focused-autonomous
- **When:** a well-scoped task with an approved spec + plan, and you want fewer interruptions.
- **Autonomy:** broaden the `allow` list for the specific tools/commands this task needs; keep deny intact.
- **Isolation:** **built-in bash sandbox** for all command execution; work on a branch or git worktree.
- **Network:** restricted. No deploys, no destructive remote calls.
- **Guardrail:** the smaller the task and blast radius, the more autonomy is safe here.

### 3. high-risk
- **When:** broad autonomy, long unattended runs, untrusted inputs/data, network mutations, or anything
  that could damage data, credentials, or external systems.
- **Isolation:** **full-process isolation — container or VM.** Not just the bash sandbox.
- **Network:** explicitly allowlisted egress only; secrets scoped to throwaway/test values.
- **Recovery:** snapshot/disposable environment so you can discard and rebuild.

## Built-in bash sandbox vs full-process isolation

| | Built-in bash sandbox | Full-process isolation (container/VM) |
|---|---|---|
| Contains shell commands | Yes | Yes |
| Contains **hook scripts** | **No — hooks run in your environment** | Yes |
| Contains **MCP servers** | **No — MCP runs outside the sandbox** | Yes |
| Filesystem blast radius | Limited, but not airtight | Whole isolated FS, disposable |
| Right for | everyday + focused-autonomous work | high-risk, untrusted, unattended work |

**Key warning:** bash sandboxing alone does **not** fully contain hooks or MCP servers — they execute
with your environment's privileges. So any work where a hook or MCP tool could do real damage (or where
inputs are untrusted) must run inside full-process isolation, not just the bash sandbox.

## Before escalating to high-risk
Run `./scripts/sandbox-preflight.sh` and confirm its checklist:
- Disposable environment (container/VM) ready and snapshotted.
- Secrets scoped to test values; no prod credentials reachable.
- Network egress allowlisted.
- Deny list reviewed for the irreversible actions relevant to this task.

## Quick decision guide
- Reversible, local, you're watching → **local-safe**.
- Scoped task, want speed, trusted inputs → **focused-autonomous** (bash sandbox + branch).
- Untrusted input, network writes, long unattended, or hooks/MCP that could do harm → **high-risk** (container/VM).
