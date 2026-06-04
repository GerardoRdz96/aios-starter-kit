---
name: agents-team-builder
description: Use to design and launch a Claude Code agent team (2–5 specialized agents that share a task list, talk peer-to-peer, work in parallel). Triggers — "build an agent team", "design a team of agents", "set up a Claude agent team", "I need a multi-agent crew", "create an agent team for X", "spin up a team of teammates", "build me a Claude team", or `/agents-team-builder`. Sibling of `/skill-builder`, `/agent-builder`, `/routines-builder` — that family picks the *mechanism* and walks the discovery; this one is the agent-teams specialist. Runs a four-part discovery interview (goal, team, roles, deliverables), enforces the do/don't gates, saves a rerunnable template to `.claude/teams/<name>.md`, and ends with a paste-ready invocation prompt + tmux observability tip.
argument-hint: [optional one-line goal]
disable-model-invocation: false
---

# /agents-team-builder

Builds Claude Code **agent teams**: 2–5 specialized agents that share a task list, **talk to each other peer-to-peer**, and work **in parallel**. Sibling of `/skill-builder`, `/agent-builder`, `/routines-builder`.

> Agent teams are an experimental Claude Code feature. They require the `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` env var and a recent Claude Code version. The do/don't gates below keep teams cheap and well-scoped.

## Phase 0 — Readiness check (silent)

Confirm the user actually wants a team of *interacting* agents (peer-to-peer messaging, shared task list), not independent parallel sub-agents. If they only need parallel work with no peer comms, that's plain sub-agents — note it and continue to the decision gate, which will catch it.

## Phase 1 — Decision gate (mandatory)

Don't ask "what team do you want to build?" yet. **First confirm this should even be a team.** Ask the user one AskUserQuestion summarizing the task they want done, with these options:

- **Agent team** — multiple specialized areas, parallel + reactive, quality matters (multi-pass review). *Proceed.*
- **Sub-agents (no team)** — independent parallel work, no peer comms needed. *Tell the user to just ask Claude to spin sub-agents; don't team.*
- **Dynamic workflow** — wide fan-out (10s–100s agents), no peer comms. *Point them at a width-fan-out workflow instead.*
- **`/goal` loop** — depth not width; run until criteria met. *Refer the user there.*
- **Just-ask** — simple one-shot. *Don't fire anything; suggest they just ask Claude.*

If the chosen option is not **agent team**, stop here and explain *why* in one line. Do not proceed.

## Phase 2 — Enablement check

Read `.claude/settings.local.json` and verify `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS == "1"`.

- **If set:** confirm to the user *"Agent teams enabled at project level — good."* and move on.
- **If missing:** tell the user *"Agent teams require the `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` env var. May I add it to `.claude/settings.local.json`?"* On yes, add the `env` block (or add the key to an existing `env` block). On no, stop and tell them the feature won't fire without it.

Also remind the user: **the env var only applies to NEW Claude Code sessions**. If you just added it, they need to launch a fresh `claude` session before the team can run. The skill can still build the prompt + save the template right now — they're persistent artifacts.

Verify the Claude Code version supports agent teams (`!claude --version`). If the feature isn't available in their version, stop and tell them to update.

## Phase 3 — Discovery Interview

Ask via AskUserQuestion. Do NOT batch all rounds — one round per AskUserQuestion call so the user focuses. If the user supplied a one-line goal as an argument or in their trigger message, skip Round A's goal question and just confirm.

### Round A — Goal + team size + model

One AskUserQuestion with three questions:

1. **Goal** (free-form via "Other") — "What's the end deliverable in one sentence?" Provide 0 canned options; require the user to type it.
2. **Team size** — options: 2 / 3 / 4 / 5. Recommended: 3 ("the sweet spot — enough specialization, not too expensive").
3. **Model** — options: Haiku / Sonnet (Recommended) / Opus. Sonnet is the right default cost/quality trade for most teams.

### Round B — Roles (the heart of the build)

Ask the user to define each role. ONE AskUserQuestion per teammate (so up to 5 rounds). For each:

1. **Role name** — free-form (e.g., "Frontend dev", "QA agent", "Researcher", "Critic").
2. **Job + outputs** — free-form: "What does this teammate do, and what concrete file(s) do they produce?"
3. **Owns these files** — free-form: list of file paths/globs this teammate is the sole writer for.
4. **Talks to** — free-form: which other role(s) by name does this teammate message?

Track answers in a scratch table:

| # | Role | Job | Outputs | Files owned | Talks to |
|---|------|-----|---------|-------------|----------|

### Round C — Final deliverables + approval mode

One AskUserQuestion with two questions:

1. **Final deliverables** — free-form bullet list. What does the *human* see at the end? (a running app? a PR? a test report? a doc?)
2. **First-run approval mode** — options:
   - **Human approves every teammate's plan (Recommended)** — safest first run; relax later.
   - **Main session approves teammate plans** — lower friction; the orchestrator is the gatekeeper.
   - **One teammate is the plan reviewer** — specialist pattern; pick which role in the next message.

## Phase 4 — Validation gates (block on red)

Run these checks on the answers. **Red = block and ask the user to fix.** Yellow = warn but proceed.

| Gate | Check | If red |
|---|---|---|
| **Team size** | 2 ≤ N ≤ 5 | Block. Tell the user why (cost scales linearly; 10+ is 10× more expensive). |
| **File ownership** | Every teammate has at least one file/glob nobody else writes | Block. Show the overlap. |
| **Recipients named** | Every teammate that produces a handoff names the recipient | Block. Show the unnamed handoffs. |
| **Deliverables concrete** | At least one deliverable is a *file path* or *runnable artifact* — not "summary" / "ideas" | Block. Ask for a concrete artifact. |
| **Goal one-line** | Goal is ≤ 200 chars and starts with a verb | Yellow. Trim if longer. |
| **Approval mode picked** | Phase 3 Round C answered | Block. |

## Phase 5 — Generate the artifact

**Step 1 — Name the team.** Ask the user for a kebab-case team name (default: derive from the goal, e.g., "landing-page-build" or "research-trio"). This is the file slug.

**Step 2 — Write the saved template** to `.claude/teams/<team-name>.md`. Use this exact structure:

```markdown
# Agent Team: <Team Name>

**Goal:** <one-line goal>
**Created:** <YYYY-MM-DD>
**Status:** ready / re-firable
**First-run approval mode:** <Human-approves | Main-approves | Reviewer-teammate>

## Invocation prompt (paste into a fresh Claude session)

GOAL: <goal>

Create a team called <team-name> of <N> teammates using <model>:

  1. <Role 1> — <job + outputs>. Owns: <files>. Talks to: <recipients>.
  2. <Role 2> — <job + outputs>. Owns: <files>. Talks to: <recipients>.
  3. <Role 3> — <job + outputs>. Owns: <files>. Talks to: <recipients>.
  [...continue for N teammates]

Final deliverables:
  - <deliverable 1>
  - <deliverable 2>
  - <deliverable 3>

Approval mode: <approval-mode-instruction>

## Notes
- Each teammate inherits the orchestrator's permissions, MCPs, skills, and project files. No conversation history is passed — context is the prompt above.
- For real per-agent visibility, run in tmux (not VS Code).
- To re-fire this team later: open a fresh Claude session in this repo, then paste the "Invocation prompt" block above.
```

**Step 3 — Update `.claude/teams/index.md`** (create if missing). One-line entry per team:
```markdown
- [<team-name>](<team-name>.md) — <one-line goal> · created <YYYY-MM-DD>
```

**Step 4 — If Phase 2 had to set the env var,** remind the user one more time: *"Restart your Claude Code session before firing this team — the env var only applies to new sessions."*

## Phase 6 — Output to chat (the paste-ready brief)

In the chat, output exactly this block (substitute real values):

```
## Agent team ready: <team-name>

Saved template: `.claude/teams/<team-name>.md`
Re-fire later by pasting that file's invocation prompt into a fresh session.

### To run now

1. (If env var was just added) Restart Claude Code in this directory.
2. Open a fresh `claude` session — ideally inside tmux for per-agent visibility:
   ```
   tmux new -s team
   claude
   ```
3. Paste the invocation prompt from `.claude/teams/<team-name>.md`.
4. First run: keep the human-approval mode on; switch to main-approves once the pattern is working.

### Cost reality

Each teammate is a full Claude session. <N> teammates ≈ <N>× the cost of one. Watch the
session limit on first runs; stop early if a teammate goes off-track (the tmux split-pane view
makes this catch easy).
```

## Phase 7 — Log

If the project keeps a `references/log.md`, append one line:
```markdown
## [<YYYY-MM-DD>] create | Agent team — <team-name>
Built via `/agents-team-builder`. Goal: <goal>. <N> teammates on <model>. Saved at `.claude/teams/<team-name>.md`. First-run approval mode: <mode>.
```

## Notes / discipline

- **Don't pre-fill role definitions.** The skill must walk the user through each role even if they want to rush. Pre-filled roles are how teams get bad file-ownership and overlap.
- **Don't fire the team for them.** This skill *builds* the prompt and saves the template. The user fires the team manually in a fresh session. The separation matters: build = cheap (just text); fire = expensive (N parallel Claude sessions).
- **Don't bypass the decision gate.** "Just-ask" is a valid outcome; many tasks users describe with team language are actually sub-agent or just-ask jobs.
- **3 is the sweet spot.** When in doubt, recommend 3.
- **Skill stays under 500 lines.**
- **Cost discipline:** Tell the user before Phase 5 that this team will be ~N× a single-Claude session. They should know before they save the template.
- **Example use:** a team you might build — a 3-role "research-trio" (a searcher who gathers sources, a synthesizer who drafts, a critic who fact-checks). The kit doesn't ship pre-built teams; you design your own here.

## Related

- `.claude/skills/skill-builder/SKILL.md`, `agent-builder/SKILL.md`, `routines-builder/SKILL.md` — sibling builders.
