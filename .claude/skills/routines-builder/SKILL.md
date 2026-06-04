---
name: routines-builder
description: Use when someone wants to set up recurring/automated cadence — build, optimize, or audit a Claude Code Routine (cloud scheduled agent via /schedule), a local hook, a /loop, or a daily-*/weekly-* ritual skill. Triggers on "schedule this", "automate X weekly", "make my AIOS run itself", "wire a recurring job", "attack our cadence gap". Runs a decision gate and Discovery Interview, then a mandatory supervised test before arming anything.
argument-hint: [what to automate + how often]
disable-model-invocation: true
---

## What This Skill Does

Designs, ships, optimizes, and audits **recurring automations** so the AIOS runs without being asked — the Cadence pillar of the Four Cs. It's the third sibling of `/skill-builder` and `/agent-builder`: **decision gate and Discovery Interview first, a mandatory supervised test before anything fires, files/schedules last.**

The headline mechanism is **Claude Code Routines** — saved tasks that run on Anthropic's cloud on a schedule, even with your laptop closed, **fully autonomous and acting AS you**. That power is exactly why this skill never arms a schedule until a supervised "Run now" has passed. Full mechanics (triggers, environments, network modes, connectors, limits, what won't work) are in [reference.md](reference.md).

Use this whenever:
- Wiring a new recurring trigger (cloud routine, hook, loop, or ritual skill)
- Deciding **which** cadence mechanism fits a job
- Optimizing or auditing an existing routine
- Closing a Cadence gap surfaced by `/audit`

---

## Quick Start: the four cadence mechanisms

| Mechanism | Runs on | Needs machine on? | Needs open session? | Min interval | Best for |
|---|---|---|---|---|---|
| **Cloud Routine** (`/schedule`) | Anthropic cloud | No | No | 1 hour | True autonomy — repo-centric work that lands as a reviewable `claude/` branch + session |
| **Hook** (`.claude/settings.json`) | Your machine | Yes (at the event) | No | event-driven | React to an event (SessionStart, PreToolUse, file write) |
| **`/loop`** | Your machine | Yes | Yes | 1 min | Polling / babysitting within an active session |
| **Ritual skill** (`daily-*`/`weekly-*`) | Your machine | Yes | Yes (you trigger) | manual | A consistent SOP you run by hand; `/audit` counts it toward Cadence |

**Important reality:** cloud routines **can't reach local MCP, localhost, or your `.env`**, and everything posts **as you**. They shine on work reachable through a GitHub repo or an API. Anything that needs local-only services or a tool with no API won't ride along until a cloud Connector or API exists.

---

## Mode 1: Build a Routine

### Step 0 — The Decision Gate (FIRST)

Pick the right mechanism before scoping anything:

1. **Is the work reachable from a GitHub repo or a plain API, and valuable run unattended?** → **Cloud Routine** (`/schedule`). This is the default for real autonomy.
2. **Does it need local files, localhost, or your local MCP servers?** → a cloud routine **can't** do it. Use a **hook**, **`/loop`**, or a **ritual skill** locally.
3. **Is it reacting to a local event** (session start, a file changed)? → **hook**.
4. **Is it polling something during a session you're already in?** → **`/loop`**.
5. **Is it really a manual SOP you just want to run consistently?** → a **ritual skill** named `weekly-*`/`daily-*` (no true automation, but `/audit` credits it).

State one sentence on the chosen mechanism and why. If cloud-routine is chosen, continue below. (For hook/loop/ritual, hand off to `update-config` for hooks, `/loop`, or `/skill-builder` for a ritual skill — and still do the discovery + test discipline.)

### Step 1 — Discovery Interview (cloud routine)

Ask with AskUserQuestion, one round at a time, skipping what's already known.

**Round 1: Job & cadence**
- What exactly should the routine do, start to finish? (One job. If it's two, that's two routines.)
- How often? (cron preset or natural language; **min 1 hour**. Respect daily caps: Pro 5 / Max 15 / Team 25 / Enterprise 25 runs/day.)
- Also trigger on a GitHub event or API call? (e.g. "weekly AND on every new PR")

**Round 2: Repo & scope**
- Which repo does it clone? (Your own AIOS repo is a good default for self-running rituals.) Consider a **lean dedicated repo** if the target's `CLAUDE.md` would drag in irrelevant context.
- What files/dirs is it allowed to touch? What is off-limits?

**Round 3: Environment & secrets**
- Does it need external APIs or secrets? If yes → those go in **cloud env vars at claude.ai** (never `.env` — the fresh clone has none). The prompt must say "read KEY from the environment, don't look for a `.env`."
- Network mode: **Trusted** (GitHub + Anthropic + connectors only — the default, fine for repo-only work) or **Full** (needed for external APIs)?
- Setup script needed before each run? (`npm install`, `pip install`.)

**Round 4: Output & failure path**
- What does success look like, concretely? (e.g. "push to a `claude/audit-YYYY-WW` branch, open a draft PR summarizing the score delta.")
- Where does output land? (`claude/` branch, a connector post, a notes file committed back as a memory trail.)
- **What should it do on failure?** There are no automatic retries — bake a fallback into the prompt ("if X fails, log it and stop" / "notify me").

**Round 5: Identity & safety**
- It runs and posts **as you**. Confirm any comms/connector actions are OK to carry your name. Default to **draft/branch output** over auto-posting until trust is established.

**Round 6: Confirmation** — summarize:
```
## Routine Summary: [name]
**Mechanism:** Cloud Routine (/schedule)
**Job (one sentence):** [what it does]
**Triggers:** [schedule + any GitHub/API]
**Repo:** [owner/repo]   **Touches:** [allowed] / **Off-limits:** [forbidden]
**Environment:** [env vars? network mode? setup script?]
**Output:** [claude/ branch / PR / connector / notes]
**On failure:** [fallback]
**Runs as:** you — [comms confirmed Y/N]
```
Proceed only on confirmation.

### Step 2 — Write the routine prompt

The **prompt IS the routine.** Write it as a one-shot the agent can finish without you:
- Be specific; name files/dirs; state what success looks like.
- Set boundaries ("only modify X, don't touch Y").
- Include the output format ("push to `claude/...`, open a draft PR with a summary").
- Tell it where secrets live ("API key is an env var — use it directly, no `.env`").
- Say what to do on failure.
- Put **stable** rules in the repo's `CLAUDE.md` (read automatically on the fresh clone); keep **run-specific** instructions in the prompt. Don't duplicate.

### Step 3 — Environment setup (manual, at claude.ai — flag clearly)

If the routine needs env vars, a network mode change, or a setup script, those are configured in the **claude.ai web UI before creating the routine** — the AIOS cannot set these programmatically. Hand the user the exact list of env-var names and network mode to set, and pause until confirmed. Repo-only routines (e.g. the self-audit) need none of this.

### Step 4 — Create + the MANDATORY supervised test

Create the routine via the **`/schedule`** skill (the terminal path to Routines). Then, before the schedule is armed:

1. **"Run now"** and watch one execution live.
2. Verify it read `CLAUDE.md`, stayed in scope, produced the agreed output on the `claude/` branch / session.
3. **Test the failure path**, not just the happy path.
4. Confirm secrets resolved from env vars (if any) and the network mode was sufficient.

**This test is a hard gate.** Do not arm a recurring schedule until a supervised run passes. (This is the one place routines-builder never skips, even when asked to "just schedule it.")

### Step 5 — Arm the schedule

Once the supervised run passes, set the recurring schedule via `/schedule`. Confirm back to the user: cadence, repo, next fire time, daily-cap headroom, and how to review/pause it.

### Step 6 — Document & register

Add the routine to `CLAUDE.md` (a "Your routines / cadence" area): name, what it does, cadence, repo, output location. This is also what lets `/audit` credit the Cadence pillar.

---

## Mode 2: Optimize a Routine

- **Burning the daily cap / tokens** → widen the interval, narrow the prompt scope, or split into a leaner repo.
- **Stops to ask questions** → the prompt isn't one-shot; make it self-sufficient with explicit success criteria.
- **Fails silently** → add a failure fallback ("if X, log and notify me").
- **`.env` errors** → move secrets to cloud env vars; tell the prompt to read them directly.
- **Blocked outbound calls** → switch Trusted → Full (and weigh the exfiltration risk for untrusted inputs).
- **Bloated context** → trim the repo's `CLAUDE.md` or point at a dedicated lean repo.

## Mode 3: Audit Cadence

- [ ] At least one real recurring trigger exists (routine / hook / loop / ritual skill)
- [ ] Each cloud routine has passed a supervised "Run now"
- [ ] Secrets are in cloud env vars, never committed `.env`
- [ ] Network mode is the minimum needed (Trusted unless an external API requires Full)
- [ ] Every routine prompt is one-shot with an explicit failure path
- [ ] Comms/connector actions that post **as you** were tested before being wired
- [ ] Routines push only to `claude/`-prefixed branches; bearer tokens not leaked
- [ ] Each routine is documented in CLAUDE.md so `/audit` can see it

---

## Reference Recipe: Weekly Self-Audit

The canonical first routine (closes the Cadence gap):
- **Repo:** your own AIOS repo  **Cadence:** weekly  **Network:** Trusted (repo-only)  **Env vars:** none
- **Prompt (one-shot):** "Run the /audit skill on this repo. Then do decisions-log housekeeping: flag any decision older than 30 days with no follow-up. Write the audit report to `audits/audit-<YYYY-MM-DD>.md`. Push to a `claude/weekly-audit-<YYYY-WW>` branch and open a draft PR titled 'Weekly audit <date>' summarizing the score and the delta vs the previous audit. If /audit can't run, log why in the PR body and stop. Do not modify any file outside `audits/`."
- **Output:** reviewable `claude/` branch + draft PR each week. Nothing merges without you.

---

## Important Notes

- **Decision gate is not optional** — most "schedule this" asks for *local* work belong to a hook, `/loop`, or a ritual skill, not a cloud routine.
- **The supervised "Run now" test is a hard gate** before arming any schedule, even on "just schedule it."
- **Everything runs as you.** Default to draft/branch output; test before wiring any comms connector.
- **Secrets → cloud env vars, never `.env`.** Never commit `.env` to "solve" a missing-key error.
- Cloud routines can't reach local MCP, localhost, or local files — only what's in the repo or an API.
- For the full triggers / environments / network / connectors / limits reference, see [reference.md](reference.md).
