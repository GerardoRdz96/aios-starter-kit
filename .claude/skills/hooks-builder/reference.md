# Claude Code hooks — schema + protocol reference

Provenance: stable-core verified June 2026 against live configs + official docs. Official docs: https://code.claude.com/docs/en/hooks — re-verify event names there after major Claude Code updates.

## Events

**Stable core** (live-verified + official docs):
`SessionStart` · `SessionEnd` · `UserPromptSubmit` · `PreToolUse` · `PostToolUse` · `Stop` · `SubagentStop` · `Notification` · `PreCompact`

- `Stop` fires when the main agent finishes EACH RESPONSE — it is NOT "session ended" (`SessionEnd` is). The single most common event-choice mistake.
- **Matchers are per-event, not "tool vs non-tool":** `PreToolUse`/`PostToolUse` match on TOOL NAMES (`"Write|Edit"`); several non-tool events (`SessionStart`, `SessionEnd`, `Notification`, `SubagentStart`, `PreCompact`, …) accept matchers over their own dimensions; others ignore matchers. Check the official per-event table before assuming.
- Hooks can: **gate** (block the action), **inject context** (stdout/JSON lands in the conversation — how memory plugins inject recall), or **side-effect** (anything).

**Extended / candidate events** (observed or community-reported names — NOT all guaranteed in your build; the authoritative list is the official docs, confirm each before use — this surface moves):
`Setup`, `InstructionsLoaded`, `UserPromptExpansion`, `MessageDisplay`, `PermissionRequest`, `PermissionDenied`, `PostToolUseFailure`, `PostToolBatch`, `SubagentStart`, `TaskCreated`, `TaskCompleted`, `StopFailure`, `TeammateIdle`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `PostCompact`, `Elicitation`, `ElicitationResult`. Treat anything outside the stable core as advanced: read its docs entry, then dry-fire.

## Settings schema (all three layers use the same shape)

```json
{
  "hooks": {
    "<Event>": [
      {
        "matcher": "<regex>",                  // per-event semantics — see Events section
        "hooks": [
          { "type": "command",                        // v1 scope: command-only.
            "command": "bash /abs/path/script.sh",   // or inline; abs paths quoted if spaces
            "timeout": 5 }                            // seconds — ALWAYS set
          // Other handler types exist (http, mcp_tool, prompt, agent) + fields (if, args,
          // async, statusMessage). prompt/agent handlers SPEND TOKENS per match — explicit
          // cost case required before use.
        ]
      }
    ]
  }
}
```

Layers + precedence: `~/.claude/settings.json` (user, all projects) · `.claude/settings.json` (project, committed/shared) · `.claude/settings.local.json` (project, personal, gitignored). All matching hooks run — layers add, they don't override.

## Hook protocol (command contract)

- **stdin**: one JSON event payload — fields vary by event; tool events include the tool name + input (e.g. for Bash: the command). Parse with `jq` or read-and-ignore.
- Two decision-control modes:
  - **Exit-code mode**: exit 0 = allow/success; **exit 2 = block** (PreToolUse blocks the tool call; other blockable events have event-specific block semantics — check the docs per event). stderr becomes the feedback shown to the model. **Inversion trap — `Stop`/`SubagentStop`: exit 2 (or `decision:"block"`) does NOT stop the agent; it forces it to CONTINUE, feeding your stderr back as the next instruction. An unguarded blocking `Stop` hook is a brakeless infinite loop.** The stdin payload carries a built-in `stop_hook_active` boolean — `true` once the agent is already continuing because of a Stop hook; read it as your loop detector and allow the stop. See [Blocking `Stop` hooks](#blocking-stop-hooks--the-brakeless-loop-trap) below and `references/agent-loops.md`.
  - **JSON-output mode** (richer, preferred for guards): exit 0 + a JSON control object on stdout, e.g. `{"continue":true,"suppressOutput":true}` or decision fields per event. JSON mode can allow/deny/modify with a reason instead of a bare exit code.
- Other exits / timeout — treated as hook failure; session continues (fail-open) but logs. A *crashing* guard script therefore fails OPEN. **Every guard skeleton this skill produces starts fail-closed by DEFAULT:** `set -euo pipefail` + `trap 'echo "guard error — denying" >&2; exit 2' ERR` at the top, so internal errors deny instead of silently allowing. Relax to fail-open only deliberately, for side-effect (non-guard) hooks.
  - **Caveat — put decision logic in `if`/`case` conditionals (exempt from `set -e`); only truly unexpected failures should reach the trap.** Under `set -e` a bare `grep -q "rm -rf"` that finds nothing exits non-zero → the trap fires → you deny EVERY call (the wrapper silently flips a "block if matches" idiom into "block everything"). Correct body: `if grep -q "rm -rf" <<< "$cmd"; then echo "blocked" >&2; exit 2; fi` then `exit 0` — never a bare `grep -q` as the decision.
- Keep high-frequency hooks (the PostToolUse:Read class) under ~100ms — they run on EVERY match, every session.

## Blocking `Stop` hooks — the brakeless-loop trap

A `Stop`/`SubagentStop` hook that exits 2 makes the agent CONTINUE, not stop (see the inversion trap above). So a "keep going until it's right" Stop hook with no brake is an infinite loop that bills forever. **Never block "until satisfied."** A safe blocking Stop hook DEFAULTS to allow-stop and only blocks under BOTH brakes at once: a persisted counter cap (force-allow after N ≤ 8 blocks) AND an objective boolean done-check (a command that exits 0 when the work is verifiably done — a passing test, not a vibe). Loop-engineering doctrine: `references/agent-loops.md`.

`.claude/hooks/stop-guard.sh` (fail-safe skeleton — copy, then replace the done-check):
```bash
#!/usr/bin/env bash
# Blocking Stop hook — DEFAULTS TO ALLOW-STOP. Blocks (= forces continue) only when
# BOTH a counter under its cap AND an objective done-check say "not done yet".
set -uo pipefail
input="$(cat)"

# 0. Loop detector: if we are ALREADY continuing because of this hook, stop now.
[ "$(jq -r '.stop_hook_active // false' <<< "$input")" = "true" ] && exit 0

# 1. Hard counter brake — persisted across fires; force allow-stop after N blocks.
N=8
state="${CLAUDE_PROJECT_DIR:-.}/.claude/.stop-guard-count"
count=$(( $(cat "$state" 2>/dev/null || echo 0) + 1 ))
if [ "$count" -gt "$N" ]; then rm -f "$state"; exit 0; fi   # cap hit → let it stop

# 2. Objective boolean done-check — NEVER "until it looks satisfied".
#    Replace with a real test that exits 0 only when the work is verifiably done.
if make -q verify >/dev/null 2>&1; then rm -f "$state"; exit 0; fi   # done → allow stop

# Not done AND under the cap → block (this CONTINUES the agent).
echo "$count" > "$state"
echo "verify still failing (attempt $count/$N) — fix it, then stop." >&2
exit 2
```

Both brakes are independent fail-safes: lose the done-check and the counter still ends it; lose the counter and `stop_hook_active` + the done-check still end it.

## Variants

- **Skill-scoped hooks** — in a SKILL.md frontmatter (`hooks:` with `PreToolUse`/`PostToolUse`/`Stop`→SubagentStop); active ONLY while that skill runs. Built via `/skill-builder`.
- **Plugin hooks** — `hooks/hooks.json` inside a plugin, same nesting; paths MUST use `${CLAUDE_PLUGIN_ROOT}`. Built via `/plugin-builder`.

## Taking a live inventory (do this before building or auditing)

1. Read the `"hooks"` key of all three layers: `~/.claude/settings.json`, `.claude/settings.json`, `.claude/settings.local.json`.
2. List scripts in `~/.claude/hooks/` and `.claude/hooks/` — note which are **plugin-managed** (installed by a plugin; usually named after it).
3. **Don't hand-edit plugin-managed hooks** — they're overwritten on plugin update. Your own hooks belong in the project layers (or user layer for cross-project ones).

## Safety rails (house rules)

1. Hooks run arbitrary shell **as you** on every matched event — supervised first-fire test is mandatory before arming (dry-fire with fake stdin, live-fire once, failure drill).
2. Always set `timeout`. Never put secrets on the command line — source `.env` inside the script.
3. Guards are fail-closed by default (see the wrapper above); side-effect hooks may be deliberately fail-open.
3b. **Arm hooks in `.claude/settings.local.json` (gitignored), not the tracked `settings.json`** — a public or shared repo must never ship armed hooks that execute on someone else's machine the moment they open the project. Promote to the tracked file only for hooks you explicitly intend to distribute, and say so in the PR.
4. Few > many: every hook taxes every matched event forever. Audit kills zombies.
5. Show the settings.json diff whether the write goes through `update-config` or directly.
