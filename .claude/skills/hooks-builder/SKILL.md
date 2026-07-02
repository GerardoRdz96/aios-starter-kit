---
name: hooks-builder
description: Use when the user asks to design, build, optimize, or audit Claude Code HOOKS — event-driven shell commands in settings.json that fire on SessionStart, PreToolUse, PostToolUse, Stop, etc. Triggers — "build a hook", "add a hook", "run X every time I edit/commit/start a session", "block tool X when…", "audit my hooks", or `/hooks-builder`. Sibling of `/skill-builder`, `/agent-builder`, `/routines-builder`, `/agents-team-builder`, `/plugin-builder` — this one is the event-driven-local specialist (the hooks lane `/routines-builder` hands off to).
argument-hint: [what should fire, on which event]
disable-model-invocation: true
---

# /hooks-builder

Builds **Claude Code hooks**: event-driven commands the harness executes deterministically on matched events. A hook is the right tool when the behavior must happen EVERY time, mechanically — memory and prompts cannot fulfill "always do X on Y"; only the hook layer can. Schema, events, and the stdin/exit-code protocol live in [reference.md](reference.md).

## What this skill does

- **Build** a new hook: decision gate → discovery → script + config → supervised first fire → register.
- **Optimize** an existing hook (read it first).
- **Audit** all configured hooks (user + project + plugin layers).

Use this whenever the ask is "every time / whenever / always when <event>, do X" about a LOCAL, in-session behavior.

## Quick start — hook vs the other cadence mechanisms

| Mechanism | Fires when | Machine on? | Session open? | Builder |
|---|---|---|---|---|
| **Hook** | a Claude Code EVENT matches | yes | a CC process must exist (no human needed) | this skill |
| Scheduled routine (cloud or local cron/launchd + `claude -p`) | a clock schedule | depends | no | `/routines-builder` |
| `/loop` | recurring interval inside one session | yes | yes | `/loop` itself |
| Skill-scoped hook | only while a specific skill runs | yes | yes | `/skill-builder` (frontmatter) |
| Plugin hook | shipped inside a plugin, fires for its users | — | — | `/plugin-builder` |

**Scope (v1): hooks this skill authors are `type:"command"` only.** Claude Code reportedly also supports `http`/`mcp_tool`/`prompt`/`agent` handlers and fields like `if`/`async` — but these handler names are candidate/observed, not all guaranteed in your build, so confirm each against the official docs first. (prompt/agent handlers also spend tokens on every match, so they need an explicit cost case.) See reference.md before reaching for them.

**Division of labor with `update-config`:** where that built-in skill is available, it owns the mechanical settings.json edit. This skill owns everything around it — the decision, the design, the script, the test discipline — and invokes `update-config` for the write (or edits directly when it's unavailable, reporting exactly what changed).

## Mode 1: Build

### Step 0 — The Decision Gate (FIRST)

1. **Is it event-driven inside Claude Code sessions?** (a tool call, session start/end, a stop) If it's clock-driven → `/routines-builder`. STOP and refer.
2. **Must it fire every time, deterministically?** If "usually / when relevant" → it's an instruction for CLAUDE.md or a skill, not a hook. STOP and refer.
3. **Only while one skill runs?** → skill-scoped hooks in that skill's frontmatter via `/skill-builder`. STOP and refer.
4. **Shipping to others?** → plugin `hooks/hooks.json` via `/plugin-builder`. STOP and refer.
5. **Deterministic, no LLM judgment needed in the action?** Hooks should run scripts, not think. If the action needs judgment, the hook may still fire `claude -p` — but flag the cost and consider whether a skill ritual fits better. A hook that spawns `claude -p` MUST cap it (`--max-turns` + a hard `timeout`) AND carry a re-entry guard (e.g. `[ -n "${CLAUDE_HOOK_DEPTH:-}" ] && exit 0; export CLAUDE_HOOK_DEPTH=1` at the top), and must NEVER fire from a `Stop` hook the same run can re-trigger — an LLM-spawning hook whose child can re-fire it, with no depth guard, is a fork bomb. See `references/agent-loops.md`.

State the verdict in one sentence before interviewing.

### Step 1 — Discovery Interview

AskUserQuestion, one round at a time; skip what's known. *Why each matters: wrong event = never fires; wrong matcher = fires constantly; wrong failure mode = blocked sessions.*

- **Round A — Trigger.** Which event? Core set: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop` (end of each RESPONSE, not session), `SubagentStop`, `SessionEnd`, `PreCompact` — extended events in reference.md. Which matcher (for tool events: tool-name regex, e.g. `Write|Edit`; several non-tool events also accept matchers — see reference.md per-event table)? How often will that realistically fire per session (every-Read hooks run hundreds of times — keep them <100ms)?
- **Round B — Action.** What does it DO: allow/block (exit 2 = block), inject context (stdout on certain events), or side effect (notify, log, format, validate)? Inline command or script file? (Anything >1 line → a script in `.claude/hooks/` (project) or `~/.claude/hooks/` (user).)
- **Round C — Scope + failure.** Scope: user (`~/.claude/settings.json`, all projects), project-shared (`.claude/settings.json`, committed), project-personal (`.claude/settings.local.json`)? Timeout (default 5-10s — ALWAYS set one)? On script failure: fail-open (log, continue) or fail-closed (block)? Default fail-open unless it's a guard.
- **Confirmation** — echo a fenced `## Hook Summary` (event, matcher, action, scope, timeout, failure mode, script path) and get explicit yes.

### Step 2 — Build

1. Write the script (if any) to the scoped hooks dir; `chmod +x`. Script contract: read the event JSON from stdin, do ONE thing, exit 0 (allow / success) or 2 (block, PreToolUse) — full protocol in [reference.md](reference.md). Never put secrets in the command line; source them inside the script from `.env`.
2. Config edit: invoke the **`update-config`** skill with the exact hooks JSON block (shape in reference.md). If editing directly, show the diff of the settings file.

### Step 3 — Supervised first-fire test (MANDATORY — don't skip, don't leave unverified)

Hooks run as YOU with your permissions on every matched event. Before calling it done:

1. **Dry-fire the script standalone**: `echo '<realistic event JSON>' | <script>` — verify output + exit code for both the match case and a benign case.
2. **Live-fire once**: trigger the real event in-session (e.g. a harmless Write for a `PreToolUse:Write` hook) and confirm: fired? right decision? no latency pain?
3. **Failure drill**: make the script fail (or time out) once; confirm the session degrades the way Round C chose.
4. Report exactly what you ran and what happened. A hook that can't pass all three stays UNARMED (config commented out / removed).

### Step 4 — Document & register

CLAUDE.md one-liner if it changes day-to-day behavior (respect the budget protocol); append `references/log.md` (`## [<date>] create | Hook — <name>`); note in `pending.md` anything deferred. New hook-layer facts → update [reference.md](reference.md).

## Mode 2: Optimize

Read the current config + script FIRST — never optimize what you haven't read. Symptoms → fixes: fires too often → tighten matcher regex; session feels slow → measure script runtime, move work async or cache; silent failures → add logging to a file (never stdout on non-inject events); blocks unexpectedly → check exit codes (a crashing script can read as exit 2); hook stopped working after an update → re-verify event names + settings layer precedence.

## Mode 3: Audit

For every hook across `~/.claude/settings.json`, `.claude/settings.json`, `.claude/settings.local.json`, and active plugins:

- [ ] Event + matcher still match real tool names (no stale regexes)
- [ ] Timeout set; script exists, executable, <100ms for high-frequency events
- [ ] Failure mode intentional (fail-open vs fail-closed) and documented
- [ ] No secrets in command lines; scripts source `.env` internally
- [ ] Still wanted — kill zombie hooks (each one taxes every matched event forever)
- [ ] Layer is right (user vs project vs local) for who should get it
- [ ] Registered: log entry exists; CLAUDE.md mentions it if behavior-changing

## Complete example (flagship) — a fail-closed `PreToolUse` guard

Goal: block destructive shell before it runs. Defensive, fail-closed, fast — the shape to copy first.

`.claude/hooks/bash-guard.sh`:
```bash
#!/usr/bin/env bash
# PreToolUse:Bash guard — fail-CLOSED. Blocks dangerous commands; denies on its own errors.
set -euo pipefail
trap 'echo "bash-guard error — denying" >&2; exit 2' ERR
cmd="$(jq -r '.tool_input.command // ""')"   # the command the model wants to run
# Decision logic in a conditional (exempt from set -e): a match blocks with exit 2.
case "$cmd" in
  *"rm -rf /"*|*"rm -rf ~"*|*"mkfs"*|*"dd if="*)
    echo "blocked: destructive command pattern" >&2; exit 2 ;;
esac
exit 0   # default: allow
```

`.claude/settings.local.json` fragment (via `update-config`):
```json
{ "hooks": { "PreToolUse": [ { "matcher": "Bash", "hooks": [ { "type": "command",
  "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/bash-guard.sh\"", "timeout": 5 } ] } ] } }
```

Test all three: block case `echo '{"tool_input":{"command":"rm -rf /"}}' | bash .claude/hooks/bash-guard.sh; echo $?` → message on stderr, exit 2 (denied); benign case `echo '{"tool_input":{"command":"ls -la"}}' | bash .claude/hooks/bash-guard.sh; echo $?` → exit 0 (allowed); failure drill `echo 'not json' | bash .claude/hooks/bash-guard.sh; echo $?` → trap fires → exit 2 (fail-CLOSED deny). Then live-fire: ask for a harmless `ls` (runs) and confirm a destructive command is blocked.

### Side-effect counterpart — a fail-OPEN `SessionEnd` ping

When the hook is a notification, not a guard, fail-OPEN is right (a failed ping must never wedge the session). SessionEnd — NOT `Stop`, which fires at the end of every response.

`.claude/hooks/session-end-ping.sh`:
```bash
#!/usr/bin/env bash
# SessionEnd ping; fail-open. Reads event JSON on stdin (unused).
set -a; source "$CLAUDE_PROJECT_DIR/.env" 2>/dev/null; set +a
curl -sm 4 "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
  -d chat_id="${TG_CHAT_ID}" -d text="🔔 AIOS session ended" >/dev/null || true
exit 0
```

`.claude/settings.local.json` fragment (via `update-config`):
```json
{ "hooks": { "SessionEnd": [ { "hooks": [ { "type": "command",
  "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/session-end-ping.sh\"", "timeout": 6 } ] } ] } }
```

Test: `echo '{}' | bash .claude/hooks/session-end-ping.sh; echo $?` → message arrives, exit 0. Then end one disposable session live. Failure drill: run with `FAIL_TEST=1` injected (add `[ "${FAIL_TEST:-}" = 1 ] && exit 1` at the top during testing) in a disposable session → session unaffected (fail-open) → remove the test line.

## Important notes

- The decision gate is not optional — most "automate X" asks are routines or skills, not hooks.
- Hooks are the only layer that can guarantee "always" — but each one runs forever on every match. Bias toward FEW, fast, well-tested hooks.
- Read before optimizing; test before arming; route review of any non-trivial hook script to a **different-lineage model** (No-Self-Review Law in `multi-brain`).
- Full schema/protocol: [reference.md](reference.md). Official docs: https://code.claude.com/docs/en/hooks

## Related

- [reference.md](reference.md) — events, settings schema, stdin/exit protocol, inventory how-to.
- `/routines-builder` — clock-driven cadence (hands event-driven work here).
- `update-config` — the mechanical settings.json writer this skill delegates to (when available).
- `/skill-builder` (skill-scoped hooks) · `/plugin-builder` (plugin hooks).
