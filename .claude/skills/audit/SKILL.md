---
name: audit
description: Use when someone asks for an AIOS audit, asks to score their setup against the Four Cs, or says "is my AIOS working" / "audit my setup" / "find gaps in my AIOS". Produces a Four-Cs scoreboard with top-3 fixes ranked by leverage.
---

## What this skill does

Runs the **Four Cs Audit** on the current Claude Code project. Reads (never writes) the project's operating manual, memory, skills, agents, MCPs, decisions, and references. Scores each of the Four Cs out of 25. Surfaces strengths and the top 3 leverage-weighted gaps with concrete next-step commands.

**Scope is structural — "is the AIOS built right?"** It is NOT a capability planner. Capability gaps ("you could build a daily brief if you connected calendar") belong to `/level-up`. The audit answers: are the files, folders, registries, and connections in good shape?

First run is the baseline. Re-run weekly to watch the score climb. That's the compounding hook.

## Today's context

- **Date:** !`date +%Y-%m-%d`
- **Project root:** the current working directory

## The Four Cs (scored 25 each = 100 total)

| Layer | Test |
|---|---|
| **Context** | Knows the user — identity, team, voice, decisions, references |
| **Connections** | Reaches the user's stuff — MCPs, integrations, data sources |
| **Capabilities** | Knows how to do work — skills + agents |
| **Cadence** | Runs without being asked — schedules, hooks, recurring rituals |

## Execution

### Step 1: Discover the project shape

The audit looks for **patterns and intent**, not exact paths. File names vary. Use Glob and Read to check:

**Operating manual:** `CLAUDE.md` (root), `CLAUDE.local.md` (gitignored).
**Memory:** `MEMORY.md` (root), `~/.claude/projects/<id>/memory/MEMORY.md`, or `memory/` folder.
**Skills:** `.claude/skills/*/SKILL.md` — count + frontmatter.
**Agents:** `.claude/agents/*.md` — count + frontmatter. Match by frontmatter: only count files with `name`/`description` frontmatter; skip `README.md` (a folder README is not an agent).
**Connection mechanisms** (any of these = "reachable"):
- MCPs: `.mcp.json`, `.claude/settings.json` (mcpServers key), `.claude/settings.local.json`
- API scripts: `scripts/*.py|.js|.ts` documented in CLAUDE.md
- Export pipelines: `data/`, `imports/`, `exports/` with refresh script + last-run timestamp
- API keys + reference guide: `.env` entries + corresponding `references/{tool}-api.md`

**Connections registry:** `connections.md` (anywhere).
**Reference guides:** `references/{tool}-api.md`, `references/*-reference.md`, or equivalent.
**Decisions:** `decisions/log.md`, `decisions.md`, or any append-only decisions file.
**References / SOPs:** `references/`, `docs/`, `sops/` folders.
**Templates:** `templates/`, `.claude/templates/`.
**Hooks / scheduled jobs:** `.claude/settings.json` hooks key, or skill names matching `morning-*`, `weekly-*`, `daily-*`, `monthly-*`, `standup`.

Don't penalize for non-canonical names if equivalent intent is captured elsewhere.

### Step 2: Score each C (25 points each)

#### Context (25 pts)

| Criterion | Points | How to detect |
|---|---|---|
| Operating manual exists and is substantive (>200 words) | 5 | Read CLAUDE.md, count words |
| Identity / role / voice captured | 5 | CLAUDE.md mentions who the user is + role/mission, OR `.claude/rules/*.md` exists |
| Persistent memory exists with multiple entries | 5 | MEMORY.md exists with >3 entries, OR `memory/` has >3 files |
| Reference docs exist | 5 | `references/`, `docs/`, or `sops/` has ≥1 file |
| Decisions captured | 5 | `decisions/log.md` or equivalent has ≥1 entry |

#### Connections (25 pts) — domain-aware, mechanism-agnostic

A "reachable" connection counts via ANY mechanism: MCP, script, export pipeline, or `.env` key + `references/{tool}-api.md`. The kit is API-first; the audit doesn't prefer MCPs.

**The 7 Tier-1 Universal Data Domains:**

| # | Domain | Examples |
|---|---|---|
| 1 | Outcomes / Financials | Stripe, QuickBooks, a metrics dashboard, Looker |
| 2 | Customer / people interactions | HubSpot, Salesforce, Gmail-as-CRM, community DMs |
| 3 | Calendar | Google Cal, Outlook, Calendly |
| 4 | Communication | Gmail, Outlook, Slack, Teams, Discord |
| 5 | Project / task tracking | ClickUp, Asana, Linear, Notion DB, Jira |
| 6 | Meeting intelligence | Granola, Otter, Fireflies, Gong, Zoom |
| 7 | Knowledge / files | Notion, Drive, Dropbox, Confluence, SharePoint |

**Tier-2 (bonus):** AI service API keys (OpenRouter, Anthropic, OpenAI), decisions/history, content/publishing.

| Criterion | Points | How to detect |
|---|---|---|
| Tier-1 domain coverage | 10 | 1.4 pts per tier-1 domain reachable. Round to nearest 0.5. Cap 10. |
| Reference guide presence | 5 | **0 if no connections are reachable.** Otherwise start at 5, -1 per connected tool with no `references/{tool}-api.md`. Floor 0. |
| Auth / pipeline freshness | 5 | **0 if no connections are reachable.** Otherwise start at 5, -1 per connection in `needs-auth`/`expired` state, or script with no run within 30 days. Floor 0. |
| Documentation in `connections.md` | 3 | 0 if missing; 1 sparse; 2 most; 3 covers all reachable. |
| Intentional + safely-scoped write path | 2 | +1 if at least one connection has an INTENTIONAL, scoped write path a cadence actually needs (send email, post update); +1 if keys are scoped to least privilege (read-only, or write/admin scopes no broader than a cadence needs). Read-only is fine when nothing needs to write — don't blanket-penalize it, and don't reward over-broad write keys. |

#### Capabilities (25 pts)

| Criterion | Points | How to detect |
|---|---|---|
| 3+ skills installed | 10 | Count `.claude/skills/*/SKILL.md` |
| 1+ user-built skill | 10 | A skill in `.claude/skills/` **beyond the box-shipped set** (`agent-builder`, `agents-team-builder`, `audit`, `grill-me`, `hooks-builder`, `level-up`, `multi-brain`, `onboard`, `plugin-builder`, `routines-builder`, `session-handoff`, `skill-builder`, `workflow-builder`). A fresh clone scores **0** here — this point is for skills *you* add. (Update this set if the kit ships more.) |
| 1+ user-built agent | 5 | An agent in `.claude/agents/*.md` **beyond the box-shipped `scribe` + `warden`**. A fresh clone scores **0**. |

#### Cadence (25 pts)

| Criterion | Points | How to detect |
|---|---|---|
| 1+ recurring/scheduled trigger | 10 | `.claude/settings.json` hooks, OR skill name matches `morning-*` / `daily-*` / `weekly-*` / `monthly-*` / `standup` |
| Recent activity / usage signal | 10 | Files in `.claude/skills/` modified within 30 days, OR `decisions/log.md` has entry within 30 days |
| Templates folder populated | 5 | `templates/` or `.claude/templates/` has ≥1 file |

### Step 3: Identify top 3 gaps by leverage

For each criterion that lost points: leverage = (points lost) × (impact multiplier).

**Impact multipliers:**
- 0 tier-1 domains reachable: **4x** (AIOS is blind to the work)
- Operating manual missing or thin: **3x** (foundation)
- ≤2 tier-1 domains reachable: **3x** (Connections is the gateway to live data)
- 0 skills: **2x** (no Capabilities = no AIOS)
- No recurring trigger: **2x** (no Cadence = no autonomy)
- No intentional write path where a cadence needs one: **2x** (viewer, not an OS)
- 0 reference guides for connected tools: **1.5x** (every future skill re-researches the same APIs)
- No decisions log: **1.5x**
- All others: **1x**

Sort gaps by leverage descending. Take top 3. For each, write a one-line concrete next step:
- **Need a new skill?** Recommend `skill-creator` (Anthropic) or `skill-builder` (local), or "write SKILL.md at `.claude/skills/<name>/SKILL.md` with YAML frontmatter."
- **Need to log a decision?** "Append to `decisions/log.md`."
- **Need to reach a tier-1 domain?** Prefer API+script (write `scripts/{tool}_api.py` + save `references/{tool}-api.md`). Recommend `claude mcp add` only if no API path exists.
- **Connected tool missing a reference guide?** "Research the API once, save endpoints + auth + common queries to `references/{tool}-api.md`."
- **Need a recurring trigger?** "Add a hook to `.claude/settings.json`, or write a skill named `daily-*` you run each morning." For how to engineer a durable cadence/loop (triggers, brakes, verification), see `references/agent-loops.md`.

### Step 4: Output the report

Print directly in chat (Markdown). Format:

```
# AIOS Audit — {date}
**Score: {total}/100** ({stage})

Stage thresholds:
- 0-39 → Stage 0: Foundation
- 40-69 → Stage 1: Built
- 70-89 → Stage 2: Compounding
- 90-100 → Stage 3: Autonomous

## Scoreboard

Context        {bar}  {n}/25  {label}
Connections    {bar}  {n}/25  {label}
Capabilities   {bar}  {n}/25  {label}
Cadence        {bar}  {n}/25  {label}

(bar = ## per 5pts, rounding each C score to the nearest whole point before rendering; label = "Strong" ≥20, "Solid" 15-19.99, "Thin" 8-14.99, "Missing" <8 — bands are continuous, so fractional Connections scores always land in exactly one band)

## Strengths
- {1-3 short bullets from highest-scoring criteria}

## Top 3 Gaps (ranked by leverage)
1. **{gap name}** (-{points} × {multiplier})
   → {concrete next-step}
2. **{gap name}** (-{points} × {multiplier})
   → {concrete next-step}
3. **{gap name}** (-{points} × {multiplier})
   → {concrete next-step}

## Suggested next: {single most leveraged action}

---
Structural gaps only. To explore CAPABILITY gaps (what your AIOS could DO that it can't yet), run /level-up after this audit.
```

### Step 5: Offer to save the report

After printing, ask: "Save this audit to `audits/audit-{date}.md` so you can track score over time?" If yes, write it (creating `audits/` folder if needed). This is the only writable side effect.

## Notes

- **Read-only by default.** Never modify CLAUDE.md, memory, skills, or any project files. Only optional write is the audit report.
- **Be flexible about file names.** Don't penalize for using non-canonical names if intent is captured.
- **Be honest, not generous.** A 95/100 is a flex. Most setups land 40-70.
- **Don't suggest skills that don't exist.** Point at what's actually available.
- **Speed matters.** Report in under 60 seconds wall-clock. Read targeted files, count skill folders without reading each fully (frontmatter only).
- **Cadence detection is fuzzy.** Infer from skill names if hooks/cron data isn't cleanly available.
