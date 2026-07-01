---
name: workflow-builder
description: Use when the user asks to design, build, optimize, or audit a SAVED DYNAMIC WORKFLOW — a JS orchestration file in `.claude/workflows/` that fans work out to N parallel sub-agents and merges results. Triggers — "build a workflow", "save this as a workflow", "make this rerunnable as a workflow", "turn this fan-out into a saved workflow", "audit my workflows", or `/workflow-builder`. Sibling of `/skill-builder`, `/agent-builder`, `/routines-builder`, `/agents-team-builder`, `/plugin-builder`, `/hooks-builder` — that family picks the mechanism; this one is the width-orchestration specialist. Runs a decision gate (just-ask / skill / sub-agent / agent team / workflow ladder), a discovery interview (deliverable, fan-out unit, scope bounds, verify pass, cost ceiling), validates against red gates, then writes `.claude/workflows/<name>.js` with the house meta/phase/agent skeleton. Build = cheap, fire = expensive — it never fires the workflow for you. Harness API: `reference.md`.
argument-hint: [workflow goal or existing workflow name]
disable-model-invocation: true
---

# /workflow-builder

Builds **saved dynamic workflows**: JS files in `.claude/workflows/` that orchestrate N parallel sub-agents deterministically (loops, fan-out, schemas, adversarial verify) and surface in the skill list by `meta.name`. The harness API lives in [reference.md](reference.md) — read it before writing any JS.

> **Heads up — the dynamic-workflow harness is a recent/preview Claude Code surface and may not exist in your build.** Check `/workflows` first (Phase 0). If the command is unknown, this skill has nothing to drive — stop and tell the user their build doesn't ship workflows yet.

**The orchestration ladder** (cheapest first): just-ask → skill (reusable recipe) → sub-agent (parallel, clean context) → agent team (small crew that talks to each other) → **dynamic workflow** (width fan-out — a JS file that spins N parallel sub-agents and merges results). The deciding question: *does this break into many pieces that can run independently of each other at the same time?* If yes → workflow.

## Phase 0 — Source + harness check (silent)

1. Confirm this skill's `reference.md` exists. If it's missing, stop and say so. Don't build from memory — the harness API drifts.
2. **Confirm the harness exists before anything else.** Run `/workflows` (lists runs) — workflows are model-agnostic harness features of recent Claude Code builds, so verify by the command, not by version strings (wrapper installs report stale numbers). If `/workflows` isn't a command, stop here and tell the user this build doesn't ship dynamic workflows yet — don't run the decision gate or interview against a surface that isn't there.

## Phase 1 — Decision gate (mandatory)

Don't ask "what workflow?" yet. **First confirm the task is workflow-shaped.** One AskUserQuestion summarizing the task, options:

- **Saved workflow** — the task splits into MANY pieces that run independently at the same time (width), AND it will recur (rerunnable). *Proceed.*
- **Script** — deterministic, no-judgment work (parse, transform, hit an API). *House pre-check: that's `scripts/`, not agents at all. Stop.*
- **Just-ask** — one Claude can do it in-session without fan-out. *No artifact. Stop.*
- **One-off workflow (don't save)** — width-shaped but probably never again. *Suggest asking for a one-off dynamic workflow with explicit scope + caps and reviewing the generated JS before approving the run. Stop.*
- **Sub-agents / agent team** — a few specialized roles, maybe talking to each other, not a wide fan-out. *Refer to `/agents-team-builder` (or plain sub-agents). Stop.*
- **Skill** — a reusable recipe run interactively, no parallelism needed. *Refer to `/skill-builder`. Stop.*

The test: *"Does this break into many pieces that can run independently of each other at the same time?"* No → not a workflow.

## Phase 2 — Preflight

- Harness support was confirmed in Phase 0 (`/workflows`) — don't re-verify by version string.
- Save location is **in-project `.claude/workflows/`** — never a global default dir. **No example workflow ships pre-built in the kit** — `.claude/workflows/` does not exist until you create one (same as agent teams, which also ship none). The first file in it is the one you build here; don't expect a populated directory.
- State the cost story ONCE here: a careless unbounded workflow can burn through a large share of a monthly subscription in one run. Mitigations are designed in Phase 3 (bounded scope, named deliverable, worker model choice).

## Phase 3 — Discovery Interview

AskUserQuestion, one round at a time; skip rounds already answered. Stop when 95% confident.

**Round A — Deliverable + recurrence.** (1) What does a successful run RETURN (one concrete artifact/answer — "a report of X with fields Y,Z", never "insights")? (2) When does this rerun (what trigger/occasion)? (3) kebab-case name.

**Round B — Fan-out shape.** (1) What is the UNIT of parallel work (a file, a wiki page, a finding, a URL)? (2) How does the run DISCOVER the unit list (glob, grep, args, fixed list)? (3) Expected batch size per run (10? 100?) and the cap if discovery explodes. (4) Single-pass, or loop-until-dry (keep spawning finders until K rounds return nothing new)?

**Round C — Quality + structure.** (1) Do workers return prose or a SCHEMA (almost always schema — define the fields)? (2) Is there a VERIFY pass (adversarial refuters / diverse lenses) before results count? For anything reporting "findings", default YES. (3) Dedupe key across rounds/workers?

**Round D — Cost.** (1) Worker model — DEFAULT Haiku for mechanical scan/extract, Sonnet for judgment work; inheriting the session model requires an explicit reason (on a big-model session every worker inherits that cost). Synthesis stays on the session model. (2) Hard bounds: max items, max rounds, `budget`-guarded loops. (3) `args` parameterization so scope can be narrowed per-run.

**Confirmation round** — echo back a fenced summary (name, deliverable, unit + discovery, phases, schemas, verify strategy, model + bounds) and get explicit yes before writing the file.

## Phase 4 — Validation gates

| Gate | Check | If red |
|---|---|---|
| **Width test** | Units genuinely independent (no ordering between them) | Block → refer back to the ladder |
| **Bounded scope** | Explicit item cap, AND — on EVERY looping design — a numeric round cap (`MAX_ROUNDS`). A budget guard alone, or an item cap alone, is NOT enough: any loop needs both brakes (objective done-check + numeric hard cap, `references/agent-loops.md`). | Block — this is the runaway-cost gate |
| **Concrete deliverable** | Return value is a named artifact/structure, not "summary"/"ideas" | Block |
| **Schema'd workers** | Workers returning data use `schema` | Yellow — warn, prose merges badly |
| **Verify pass** | Finding-type outputs have adversarial/diverse-lens verification, scored by a DIFFERENT lineage than produced them (never same-model self-grading) | Yellow — warn (default is verify) |
| **Dedupe key** | Loop-until-dry designs dedupe vs ALL seen, not vs confirmed | Block if looping |
| **No wall-clock randomness** | No `Date.now()` / `Math.random()` / argless `new Date()` (breaks resume) | Block — pass timestamps via `args` |

## Phase 5 — Generate the artifact

1. Write `.claude/workflows/<name>.js` using the house skeleton (full API + patterns in [reference.md](reference.md)):
   - `export const meta = { name, description, whenToUse, phases }` — pure literal; `name` matches filename; `description` + `whenToUse` become the surfaced skill text.
   - `phase()` per stage; workers via `agent(prompt, {label, phase, schema, model})`; `pipeline()` by default, `parallel()` only for true barriers; `.filter(Boolean)` after every parallel; bounds + dedupe from Phase 3/4.
2. Self-check (syntax only — never execute it): if Node is installed, `node --check .claude/workflows/<name>.js`. **Node is optional** — a freshly-cloned kit may not have it on PATH. When `node` is unavailable, fall back to a harness-native confirmation: re-read the file for balanced braces and a pure-literal `meta`, and let `/workflows` surface it (a parse error there means broken syntax). Don't block the build on a missing Node.
3. **Do NOT fire it.** Build = cheap (text); fire = expensive (N sessions). The user invokes it by name when they want a run.

## Phase 6 — Output to chat

```
## Saved workflow ready: <name>

File: `.claude/workflows/<name>.js` — invoke by name in any session ("run the <name> workflow"),
or narrow scope with args.

### Cost reality
One run ≈ <estimate> sub-agents on <model>. Bounds: <caps>. Workflows can eat a Pro/Max session
limit fast — fire deliberately, not habitually.

### First run
Run it once SUPERVISED on a small scope (args-narrowed) and check the deliverable shape before
trusting it on full scope.
```

## Phase 7 — Log + register

- Append to `references/log.md`: `## [<date>] create | Workflow — <name>` + one detail line.
- Add a one-line mention to CLAUDE.md (per its budget protocol — extend an existing list rather than adding a new bullet).
- New harness facts discovered while building → update `reference.md` here, not scattered notes.

## Mode 2 — Optimize / Mode 3 — Audit

**Optimize** (existing workflow misbehaving): read the JS first — never optimize unread code. Common symptoms → fixes: results vanish silently → missing `.filter(Boolean)`; runs forever → no dry-counter/budget guard or dedupe vs wrong set; merge step starved → barrier `parallel()` where `pipeline()` belongs; bland findings → workers lack schemas or verify pass; cost spikes → no caps, workers on too-big a model.

**Audit checklist** (per file in `.claude/workflows/`): [ ] meta pure-literal, name==filename [ ] bounded (caps/budget) [ ] schemas on data-returning workers [ ] verify pass on findings [ ] dedupe key correct [ ] no Date.now/Math.random [ ] `.filter(Boolean)` after parallels [ ] description/whenToUse accurate for surfacing [ ] still matches its CLAUDE.md mention.

## Notes / discipline

- **Don't fire it for the user.** Ever. Same rule as `/agents-team-builder`.
- **The prompt IS the workflow** — workers' prompts carry all context; they inherit zero conversation history.
- **Workers on the smallest model that survives the task**; synthesis on the session model.
- **Fan-out workers default to read-only / branch-only.** N agents writing the same tree in parallel collide. The safe default is read-only exploration (`agentType: 'Explore'`); a worker that genuinely must mutate files runs `isolation: 'worktree'` so each writer gets its own branch. Never fan unbounded file-writers at a shared working tree.
- **Verify panels (judges, critics, refuters) must be a DIFFERENT lineage** — never let the same model that produced a finding grade it. Judgment verification is scored by a different model lineage (No-Self-Review Law in `multi-brain`; the four verification types in `references/agent-loops.md`).
- Skill stays under 500 lines; harness detail lives in `reference.md`.
- Review of a built workflow file routes to a **different-lineage model** (No-Self-Review Law in `multi-brain`).

## Related

- [reference.md](reference.md) — harness JS API, verified shapes, house patterns.
- Sibling builders: `/skill-builder`, `/agent-builder`, `/routines-builder`, `/agents-team-builder`, `/plugin-builder`, `/hooks-builder`.
