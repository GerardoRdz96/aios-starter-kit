# Agent Builder Reference

Complete technical reference for Claude Code **subagents**. Covers the frontmatter schema, tool restriction, model selection, system-prompt patterns, the skill↔agent relationship, and troubleshooting.

Source: https://code.claude.com/docs/en/sub-agents

---

## What a Subagent Actually Is

A subagent is a separate Claude invocation that the orchestrator (your main session) delegates a task to via the Agent/Task tool. Key properties:

- **Isolated context.** It does NOT see the main conversation. It receives: its own system prompt (the file body) + the delegation task prompt + `CLAUDE.md`. Nothing else.
- **Returns one message.** Its final message is the *only* thing that flows back into the main context. Everything else (its tool calls, intermediate reasoning, files it read) stays in its own context and is discarded.
- **One level deep.** A subagent cannot spawn its own subagents. Orchestration is the main session's job.
- **Optionally tool- and model-scoped.** You can pin a restricted toolset and a specific model per agent.

The headline value is **context management** + **role specialization**: keep token-heavy or noisy work out of the main thread, and pin a narrow, repeatable role.

---

## Agent vs Skill — the relationship

| | Subagent (`.claude/agents/`) | Skill (`.claude/skills/`) |
|---|---|---|
| **Context** | Isolated — no conversation history | Runs in the main conversation |
| **What it is** | A *who* — a specialized Claude with a system prompt | A *how* — a workflow/SOP Claude follows |
| **Interactive?** | No — fire-and-return | Yes — can ask the user mid-run |
| **Returns** | One final message | Continues the conversation |
| **Best for** | Token-heavy search, repeatable narrow jobs, restricted-tool work | Multi-step procedures, interactive flows, project conventions |

They compose in **two directions**:
- A **skill with `context: fork`** runs in a subagent: the agent type supplies the system prompt, the SKILL.md content becomes the task.
- A **subagent with a `skills:` field** preloads named skills into its context before it starts.

If the thing you're describing needs back-and-forth with the user, it's a skill. If it's a self-contained job you hand off and await a result from, it's an agent.

---

## Frontmatter Field Reference

A subagent file is `<name>.md` with YAML frontmatter + a markdown body. Only `name` and `description` are required.

| Field | Required | Type | Default | Description |
|-------|----------|------|---------|-------------|
| `name` | Yes | string | — | Identifier. Must match the filename. Lowercase letters, numbers, hyphens. Max 64 chars. **Convention:** make it a persona that evokes the job (`warden`, `scribe`), not a flat label — see SKILL.md Round 1. Safe because delegation keys off `description`, not `name`. |
| `description` | Yes | string | — | **When to use this agent.** This is how the orchestrator decides to delegate. Lead with the trigger condition. Add "use proactively" to encourage auto-delegation. May include `<example>` blocks. |
| `tools` | No | string (comma-separated) | inherit all | Allowlist of tools the agent may use. **Omit to inherit every tool.** Set it to enforce least-privilege. |
| `model` | No | string | inherit | `haiku`, `sonnet`, `opus`, or `inherit`. Omit to inherit the main session's model. |
| `skills` | No | string (comma-separated) | none | Names of skills to **preload** into the agent's context before it starts — the `skills:` composition direction noted in "Agent vs Skill — the relationship." Omit unless the agent needs a specific skill's procedure on hand. |
| `color` | No | string | none | Display color in the UI (`red`, `green`, `cyan`, … or a hex like `"#F59E0B"`). Cosmetic only. |
| `hooks` | No | object | none | Lifecycle hooks scoped to this agent (PreToolUse/PostToolUse/Stop). Same shape as skill/settings hooks. |

> A reliable house-standard minimum is to set exactly `name`, `description`, `tools`, `color`. Add `model` only when a tier is clearly right; add `hooks` (lifecycle automation) or `skills` (preloaded procedures) only when you need them.

### `description` — write it for the orchestrator

The orchestrator reads only the `description` to decide whether to delegate. Make it a **trigger spec**, not a brochure:

- ✅ "Use proactively after a transcript lands in knowledge/. Summarizes it and extracts action items. Returns a structured digest."
- ❌ "A helpful agent that works with transcripts and other things."

Including `<example>` blocks (context → user line → why this agent fires) measurably improves routing for agents with subtle triggers. Example:

```
description: >
  Use when the user asks to refactor or assess refactor impact across the repo.
  <example>
  Context: user is about to change a shared module.
  user: "What breaks if I change the auth signature?"
  assistant: "I'll delegate to refactor-impact to trace callers across the repo."
  </example>
```

---

## Tool Restriction — least privilege

Omitting `tools` inherits **all** tools (including Bash, Write, Edit, network, MCP). That's rarely what you want. Pick the minimum:

| Job type | Recommended `tools` |
|---|---|
| Read-only research / search | `Read, Grep, Glob` |
| Research + write a report file | `Read, Grep, Glob, Write` |
| Code analysis that runs commands | `Read, Grep, Glob, Bash` |
| Implementer that edits code | `Read, Edit, Write, Bash, Grep, Glob` |
| Web research | `WebSearch, WebFetch, Read` |

Rules of thumb:
- A **review/audit agent should be read-only** — it reports, it doesn't fix. (Findings → orchestrator decides.)
- Grant `Bash`/`Write`/`Edit` only when the output contract genuinely requires mutation.
- Tool names match the orchestrator's tools. A tool the agent lacks mid-run surfaces as a missing capability, not a permission prompt — so under-granting silently breaks the agent. Match tools to the process steps exactly.

---

## Model Selection rubric

| Model | Use for | Cost |
|---|---|---|
| `haiku` | High-volume, mechanical, or search-heavy work — file discovery, classification, bulk passes, simple extraction | Cheapest |
| `sonnet` | The default workhorse — most analysis, summarization, structured generation, code review | Mid |
| `opus` | Genuinely hard reasoning — architecture decisions, multi-constraint planning, subtle bug hunts | Highest |
| omit (`inherit`) | When the agent should track whatever the session is using | — |

Heuristics:
- If the agent fans out across many files just to *find* things → `haiku` (this is what the built-in `Explore` agent uses).
- If it produces a judgment a human would trust → `sonnet` minimum.
- Don't put bulk search on `opus` (waste) or hard reasoning on `haiku` (fragile).

---

## System-Prompt Patterns (the body)

The markdown body IS the agent's system prompt. A clean house style uses XML-tagged sections for clarity:

```markdown
<role>
You are [identity]. Your single job: [one responsibility]. Spawned by [what], to produce [what].

**CRITICAL: Mandatory Initial Read** — If the prompt contains a `<required_reading>` block, Read every file listed there before doing anything else.
</role>

## Process
1. [literal step]
2. [literal step]
...

## Output contract
Return [exact shape]. If [edge case], [what to do].

## Constraints
- [hard boundary]
- [failure handling]
- [scope cap]
```

Why each part:
- **`<role>`** — anchors identity and the *single* responsibility. Multi-job agents drift; keep it to one.
- **Mandatory read pattern** — because the agent has no conversation history, the orchestrator passes context via a `<required_reading>` block in the task prompt. Telling the agent to read those first makes hand-offs reliable.
- **Numbered process** — Claude follows literal steps far more consistently than prose.
- **Output contract** — the returned message is the entire deliverable. Specify structure (headings, fields, a written file path + summary line).
- **Constraints** — agents act semi-autonomously; state what NOT to do and how to handle empty/ambiguous input.

### `ultrathink`
Including the word `ultrathink` anywhere in the body activates extended thinking for that agent — worth it for genuine reasoning agents (architecture, root-cause), wasteful for mechanical ones.

---

## File Locations & Precedence

| Location | Path | Scope | Precedence |
|---|---|---|---|
| Project | `.claude/agents/<name>.md` | This project only | Wins over user on name clash |
| User | `~/.claude/agents/<name>.md` | All your projects | Lower |
| Plugin | `<plugin>/agents/<name>.md` | Where plugin enabled | Namespaced |

Default to **project** (`.claude/agents/`) for project-specific jobs; use **user** (`~/.claude/agents/`) for agents you want available in every repo you open.

---

## Hooks in Agents (optional)

Agents can declare lifecycle hooks that run only while the agent is active. Same shape as skill/settings hooks:

```yaml
hooks:
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "npx eslint --fix $FILE 2>/dev/null || true"
```

Events: `PreToolUse` (before a tool), `PostToolUse` (after), `Stop` (agent finishes → runs as SubagentStop). Exit 0 = allow, exit 2 = block. Use sparingly — most agents need none.

---

## Integration Notes

- **No-Self-Review principle.** A Claude subagent reviewing Claude's output has the same architecture, hence the same blind spots. For adversarial review/verification of work the main session produced, route to a **second model (a different AI)** if you have one available — don't build a Claude review agent for that purpose. A Claude *finder* agent (different task, e.g. "list candidate issues") is fine; a Claude *judge* of Claude's own work is not. If only Claude is available, at least review in a fresh, isolated context with explicit critic framing.
- **Connection preference: CLI > API > MCP.** When an agent needs to reach an external system, prefer a command-line tool, then a `scripts/` API integration, then MCP last. Grant the agent only the tool that mechanism needs.
- **Another-lineage boundary.** Subagents are Claude-only. If the *better* worker is another model lineage (live web, math, multimodal, whole-repo scans), that's a route to a different AI the orchestrator makes — not a subagent.
- **Cadence.** If an agent is part of a recurring ritual, document it so `/audit` credits it toward the Cadence pillar. A recurring, scheduled, or run-on-an-event agent is a *loop* — design its cadence, verification beat, and stop-brake per `references/agent-loops.md`.

---

## Troubleshooting

### Agent never gets invoked
- The `description` doesn't match how the task is phrased. Rewrite it as a trigger spec with the actual words used; add `<example>` blocks.
- It's not auto-delegating when you want it to → add "use proactively" to the description.
- Confirm it's discoverable: ask the session "what agents are available?" and check the name appears.

### Agent invoked when it shouldn't be
- `description` is too broad. Narrow the trigger condition. Remove "proactively" if you only want explicit delegation.

### Agent returns nothing useful / empty
- The body is guidelines without an actionable task, OR the output contract is unstated. Add an explicit "Return X" contract.
- It depended on conversation context it never received. Move that context into the task prompt's `<required_reading>` or restate it in the body.

### Agent stops mid-task or skips a step
- It's missing a tool the step needs (e.g. needs `Bash` but `tools` omitted it). Add the tool. Under-granting silently breaks the process.

### Agent does too much / drifts
- Two responsibilities crammed into one agent. Split into two focused agents.
- Model too small for the reasoning required → bump `haiku`→`sonnet`→`opus`.

### Agent tried to spawn another agent
- Not supported — one level deep. Move the orchestration up to the main session.

---

## Related Documentation

- **Subagents:** https://code.claude.com/docs/en/sub-agents
- **Skills:** https://code.claude.com/docs/en/skills  (and the sibling `/skill-builder`)
- **Hooks:** https://code.claude.com/docs/en/hooks
- **Memory (CLAUDE.md):** https://code.claude.com/docs/en/memory
- **Permissions:** https://code.claude.com/docs/en/permissions
