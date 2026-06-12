# Claude Code hooks — schema + protocol reference

Provenance: stable-core verified June 2026 against live configs + official docs. Official docs: https://code.claude.com/docs/en/hooks — re-verify event names there after major Claude Code updates.

## Events

**Stable core** (live-verified + official docs):
`SessionStart` · `SessionEnd` · `UserPromptSubmit` · `PreToolUse` · `PostToolUse` · `Stop` · `SubagentStop` · `PreCompact`

- `Stop` fires when the main agent finishes EACH RESPONSE — it is NOT "session ended" (`SessionEnd` is). The single most common event-choice mistake.
- **Matchers are per-event, not "tool vs non-tool":** `PreToolUse`/`PostToolUse` match on TOOL NAMES (`"Write|Edit"`); several non-tool events (`SessionStart`, `SessionEnd`, `Notification`, `SubagentStart`, `PreCompact`, …) accept matchers over their own dimensions; others ignore matchers. Check the official per-event table before assuming.
- Hooks can: **gate** (block the action), **inject context** (stdout/JSON lands in the conversation — how memory plugins inject recall), or **side-effect** (anything).

**Extended events** (per official docs 2026-06; verify before first use — this surface moves):
`Setup`, `InstructionsLoaded`, `UserPromptExpansion`, `MessageDisplay`, `PermissionRequest`, `PermissionDenied`, `PostToolUseFailure`, `PostToolBatch`, `Notification`, `SubagentStart`, `TaskCreated`, `TaskCompleted`, `StopFailure`, `TeammateIdle`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `PostCompact`, `Elicitation`, `ElicitationResult`. Treat anything outside the stable core as advanced: read its docs entry, then dry-fire.

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
  - **Exit-code mode**: exit 0 = allow/success; **exit 2 = block** (PreToolUse blocks the tool call; other blockable events have event-specific block semantics — check the docs per event). stderr becomes the feedback shown to the model.
  - **JSON-output mode** (richer, preferred for guards): exit 0 + a JSON control object on stdout, e.g. `{"continue":true,"suppressOutput":true}` or decision fields per event. JSON mode can allow/deny/modify with a reason instead of a bare exit code.
- Other exits / timeout — treated as hook failure; session continues (fail-open) but logs. A *crashing* guard script therefore fails OPEN. **Every guard skeleton this skill produces starts fail-closed by DEFAULT:** `set -euo pipefail` + `trap 'echo "guard error — denying" >&2; exit 2' ERR` at the top, so internal errors deny instead of silently allowing. Relax to fail-open only deliberately, for side-effect (non-guard) hooks.
- Keep high-frequency hooks (the PostToolUse:Read class) under ~100ms — they run on EVERY match, every session.

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
