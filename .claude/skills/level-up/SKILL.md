---
name: level-up
description: Use weekly to find and ship one new automation. Walks the 3Ms interview — Mindset (find the candidate) → Method (scope one) → Machine (build it). Trigger on "let's level up", "what should I automate next", "find me leverage this week", or as a Friday ritual. One run = one shipped artifact, or a logged decision to stop.
---

> *The Three Ms of AI is a framework by Nate Herk. See `references/3ms-framework.md`.*

## What this skill does

Walks the user through the 3Ms each week to surface and ship one new automation. **One interview = one outcome: one shipped artifact, or one logged decision to eliminate, delegate, or stop.** It also installs the 3Ms framework into the user's head over time — after 4-6 runs, the user starts spotting opportunities mid-week without prompting because the questions have become internal defaults.

This is the brain-rewire mechanism. The kit doesn't need cron jobs to anchor behavior; it needs `/level-up` running every Friday.

## What `/level-up` is NOT

- Not `/audit`. `/audit` is structural ("is the AIOS built right?"). `/level-up` is functional ("what leverage am I missing?"). Run `/audit` first if structure is messy.
- Not a multi-candidate planner. One run scopes one candidate, ending in one artifact or one logged early-exit decision.
- Not a coach. The user does the thinking. The skill conducts the interview.

## When `/level-up` runs

- **First run: after setup is real.** Once the user has connected ≥1 MCP/script and run `/audit` once. Earlier yields trivial output.
- **Cadence: weekly, Friday afternoon.** Review the week, surface one automation, ship Monday.
- **On-demand any time.** Mid-week if a manual task itches.

## Inputs the skill reads

- `context/priorities.md` — what the user said matters
- `context/about-me.md` — top_pain, role
- `connections.md` — what's reachable, by what mechanism
- `references/3ms-framework.md` — the framework (used to quote principles back)
- `decisions/log.md` — recent decisions (what's already shipped or considered)
- `.claude/skills/*/SKILL.md` frontmatter — what capabilities exist
- Recent `audits/audit-{date}.md` if present

## Execution — three phases

### Phase 1 — Mindset interview (find the candidate)

**Fresh clone, no history?** If `decisions/log.md` is empty and there's no `audits/` yet (a brand-new kit), don't stall. Skip the "what did you do in the repo this week" mining and run the interview straight from what the user tells you, plus `top_pain` in `context/about-me.md` and `context/priorities.md`. Suggest running `/audit` once so future runs have signal, but you can still ship one small automation today.

Surface 1-3 candidates ranked by leverage. Ask these in order, conversationally:

1. *"Walk me through your week. What did you do 3+ times?"* (frequency)
2. *"Anything that felt manual, boring, or copy-paste?"* (drudgery)
3. *"Anything where you thought 'a smart intern could handle this'?"* (delegation)
4. *"If your workload doubled tomorrow, what would break first?"* (constraint)
5. *"What would let you take on twice the work without breaking?"* (growth lever)

Quote relevant Mindset principles when they fit:
- *"Sounds like the Default Shift applies — to what extent could AI be leveraged here?"*
- *"This is the Function Breakdown — you're not automating the whole job, just this one piece."*
- *"AI is better than you think and improving faster than you think. If it couldn't do this last quarter, it might be ready now."*

**Output of Phase 1:** numbered list of 1-3 candidate opportunities, one-line "why this is leverage" per candidate. Ask: *"Pick one to scope."*

### Phase 2 — Method interview (scope one)

User picks one candidate. Walk the Method pipeline:

**Step 1 — Find the constraint.** Which bottleneck does this solve, or which growth lever does it open? Tie back to Phase 1 answers.

**Step 2 — EAD: Eliminate / Automate / Delegate.**
- **Eliminate first:** *"What happens if we just stop doing this?"* If the answer is "nothing breaks" → skill exits cheerfully. *"Don't automate waste."* This is a win, log to `decisions/log.md` and stop.
- **Automate second:** apply 60/30/10 framing. ~60% deterministic, ~30% AI-assisted, ~10% manual.
- **Delegate third:** if too complex/variable/judgment-heavy → suggest a person. Skill exits with a delegation suggestion, log it.

**Step 3 — Map the process.** Five elements:
- Trigger (what kicks it off)
- Data sources (where info comes from)
- Data transformations (how data changes shape)
- Decision points (where it branches)
- Destination (where output goes)

If the user can't articulate any of the five: *"If you can't explain it to a person, you can't explain it to an AI. Sketch it on paper first, then come back."* Skill stops.

**Step 4 — Pick the autonomy level.**

| Level | Name | What happens |
|---|---|---|
| L0 | Manual | No AI |
| L1 | Suggested | AI suggests, human decides every step |
| L2 | Drafted | AI drafts, human reviews and edits |
| L3 | Supervised | AI runs, human validates periodically |
| L4 | Autonomous | AI handles end-to-end |

**Default = lowest level that solves the problem.** Push back on L4 unless the user has explicitly run lower levels first. *"Workflows beat agents. If a decision doesn't HAVE to be made by AI, don't let AI make it."*

**Side-effect gate (overrides the autonomy level).** Before locking the level, ask: *does any step send, delete, publish, pay, or deploy?* If yes, that step is a mandatory human-gate **regardless of the autonomy level chosen** — the AI may prepare the action, a human approves the irreversible part. This carries into the scaffolded artifact. (Loop-engineering doctrine: `references/agent-loops.md`.)

**Step 5 — Tie to a KPI.** Which of the Three Buckets does this move?
- More output / more customers
- More value per unit of work
- Less cost

Plus a specific metric (response time, error rate, conversion rate, time-to-completion). **If the user can't name a bucket and a metric, skill stops.** *"If your automation doesn't move a number, why are you building it?"*

**Step 6 — Define "done = right."** How will the user know the output is correct? Pick the cheapest check that fits: a **boolean test** (pass/fail), **a quick look**, **a rubric**, or **your eyes**. Default to a functional test or a manual check. For content-quality judgments, route the check to a different model lineage — don't let the model that produced the work grade its own work (`references/agent-loops.md`). This line carries into the scaffolded artifact.

**Output of Phase 2:** scoped automation spec written to `decisions/log.md` as a dated entry with the Method answers + autonomy level + KPI + the "done = right" check. Durable record of what was decided and why.

### Phase 3 — Machine handoff (build it)

Ask: *"How do you want to ship this?"* Options ordered by Boring-is-Beautiful default:

1. **Prompt-only** — saved prompt template the user runs by hand. Zero infrastructure. Highest manual involvement.
2. **Deterministic skill** — SKILL.md that runs a script (no AI step). Best for transformations with clear rules.
3. **AI-assisted skill** — SKILL.md with one AI call inside. Drafts, classifies, summarizes.
4. **Sub-agent** — multi-step agent. Last resort. Only if the work genuinely needs reasoning + tool use.

**Default selected = highest non-AI option that solves the problem.** User has to explicitly choose more autonomy.

Once chosen, route to the appropriate scaffolder:
- `skill-creator` if available globally (Anthropic-shipped)
- `skill-builder` if the user has it locally (ships with this kit)
- For a sub-agent, route to `agent-builder`
- Otherwise write a SKILL.md / agent file inline with frontmatter, location, and contents

**Every scaffolded artifact keeps standard frontmatter** (`name` + `description`, only the fields skill-builder allows — don't add fields just because you can) and carries a short note block in the **body**, right under the frontmatter:

```markdown
> **Bike Method — Phase 1 (training wheels).** Run this by hand first; advance only after you've validated it manually.
> **Side-effect gate:** any step that sends / deletes / publishes / pays / deploys stays human-gated, whatever the autonomy level.
> **Done = right when:** <boolean test / a look / a rubric / your eyes>. Route content-quality checks to a second model (different lineage).
> *The Three Ms of AI is a framework by Nate Herk.*
```

This is a **convention, not enforcement** — nothing in the kit reads a `bike-method-phase` field, so the reminder lives in the body where the user actually sees it, instead of an invented frontmatter key that breaks the skill-builder rule. It nudges the user to validate manually first and to keep irreversible steps gated; it doesn't mechanically block skipping. The loop-engineering doctrine behind training-wheels phases, side-effect gates, and verification lives in `references/agent-loops.md`.

Surface the Machine principles when scaffolding:
- **Lego Principle** — smallest steps, zero-AI first if possible
- **Validation Chain** — test each step before chaining
- **Iteration Mindset** — ship the POC, expand from real usage

## Output contract

Every `/level-up` run produces:

1. **One `decisions/log.md` entry** — dated, with the Method spec
2. **Either one scaffolded artifact** (prompt, skill, or agent file) **or one logged early-exit decision** — eliminate, delegate, or stop. Early exits are wins, not failures, and still get logged.
3. **A one-screen close** — what was scoped, and either what was built (with the Bike Method Phase 1 reminder) or why the run stopped early.

## Critical implementation rules

1. **One interview = one outcome** (one artifact, or one logged early-exit decision). No multi-candidate parallel scoping.
2. **Mindset phase always runs first.** Even if the user comes in with a pre-formed idea.
3. **EAD enforces "eliminate first."** If the answer is Eliminate, exit cheerfully — that's a win, not a failure.
4. **Default to the lowest autonomy level that works.** Push back on L4.
5. **Boring-is-Beautiful default in Machine handoff.** Default = highest non-AI option.
6. **Tie-to-KPI is mandatory.** If the user can't name bucket + metric, skill stops.
7. **Bike Method ships into every artifact** as a body note (a convention, not a frontmatter field — nothing reads it).
8. **Read-only on user files except `decisions/log.md` and the new artifact.** Don't modify other existing files.
9. **Attribution on output.** Every report and every scaffolded artifact references the framework.

## Verification (for the implementer)

- **Dry run on a populated profile** with no prompt. Expected: skill surfaces 2-3 candidates pulled from recent activity, priorities, and top_pain. Generic output ("you should build a brief") = fail.
- **Fresh-clone test.** Run on a brand-new kit with an empty `decisions/log.md` and no `audits/`. Expected: skill doesn't stall or error on missing history — it interviews from `top_pain` + priorities + what the user says, and suggests `/audit` for next time.
- **Eliminate-first test.** Feed an obviously eliminate-able candidate. Expected: skill suggests Eliminate, exits, logs the win.
- **L4 push-back test.** User asks for an autonomous email-replier on first build. Expected: skill insists on L1/L2 first, won't ship L4 without explicit override.
- **Boring-is-Beautiful test.** Candidate solvable with deterministic Python. Expected: skill recommends `(2) deterministic skill` as default.
- **Bike Method anti-skip.** User scaffolds, asks to advance to Phase 4 immediately. Expected: skill conversationally walks them through what each phase means and asks them to confirm they've validated the lower phases (a nudge — the body note is a convention, not a hard lock).

---

> *The Three Ms of AI is a framework by Nate Herk. See `references/3ms-framework.md`.*
