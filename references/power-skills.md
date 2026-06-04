# Power Skills — the Claude Code build doctrine

The skill stack and build doctrine your AIOS reaches for on non-trivial work: plan with **Superpowers**, execute by risk (**Superpowers TDD** vs **GSD**), close with an adversarial **review**. These are real, public Claude Code skills installed user-wide so they work in every project.

> Interpreted digest. The original framing ("the best Claude Code skills, found across hundreds of hours of client work") is Nate Herk's; the skills themselves are public Claude Code / Anthropic tools.

## The skills

### Superpowers — the senior-developer process
Forces the AI to work like a senior developer: **plan first, work in an isolated environment, write tests before code, then self-review twice** (once for spec match, once for code quality). Solves the number-one failure mode — rushed code that looks fine and falls apart when run.
- **When:** any project building software or automations headed for production, or anywhere a bug is expensive.
- **Front door:** the `brainstorming` skill (brainstorm → spec → write plan → execute plan), plus quality-gate skills (test-driven-development, systematic-debugging, verification-before-completion, requesting/receiving-code-review, using-git-worktrees).
- **Trade-off:** ~8% overhead on *simple* tasks — skip it there; lean in on medium+ work where fewer debugging cycles pay it back.

### GSD (Get Shit Done) — the clean-context environment
If Superpowers is *how* the AI writes code, GSD is the *environment* it writes in. Fixes **context rot** — the wall where long sessions degrade and the AI starts cutting corners or claiming things are done when they're not.
- **Mechanism:** spawns a **fresh sub-agent per task**, each with a clean context window. The main session stays clean; each task gets full context, not leftovers.
- **Quality gates:** scope-drop detection (catches a silently dropped requirement), security enforcement, autonomous spec-to-done mode for walk-away builds.
- **Cost reality:** GSD is *not* a token saver — all those sub-agents cost tokens. What it saves is the *hours* of redoing work the AI broke after forgetting your ask. `/gsd-help` lists the commands.

### /review and /ultra-review — built-in, most people miss them
Not installed skills — already in Claude Code.
- **`/review`** — fast, local structured code review on what you just built (bugs, edge cases, design). Costs only usual usage tokens. Run it after every non-trivial build.
- **`/ultra-review`** — uploads your branch to a cloud sandbox and runs a fleet of reviewer agents in parallel, each attacking from a different angle. Discipline: a bug must be *independently reproduced and verified* before it appears on your list — confirmed bugs only. Runs 10–20 min in the background; **costs money** (a few free runs on Pro/Max, then per-run). Reserve for high-stakes merges (auth, payments, data migrations) — and ask before launching, never auto-fire.

### Frontend Design
Makes anything visual — websites, slide decks, components — look polished and avoid the generic AI aesthetic. Reach for it any time the deliverable has a visual surface.

## The build doctrine — plan, execute by risk, review

Plan with Superpowers → execute by **which risk dominates the task** → always close with an adversarial review.

| If the dominant risk is… | Route execution to | Why |
|---|---|---|
| **Bug-cost** — tricky logic, money, algorithms, edge-heavy, security | **Superpowers TDD** | Test-first catches correctness bugs the plan-execute path ships. Pay the time/token premium where a bug is expensive. |
| **Context-rot** — long, multi-file, many tasks, walk-away builds | **GSD autonomous** | Equal spec-correctness, faster, fewer tokens, clean context per task across the long haul. |
| **Both** | **GSD for breadth + SP TDD on the 1–2 critical modules** | GSD's speed on the bulk, SP's correctness only where it's costly. |

Two standing rules:
- **Triage first.** Trivial / small well-specified work gets *neither* heavy process — just build it. The pipeline adds no quality on tiny tasks.
- **The review closer is non-optional.** Both execution arms can ship latent bugs their own gates miss and still pass a grader — only an independent review catches them. Review is load-bearing, not polish. For real independence, route the review to a **different model lineage** than the one that wrote the code (same architecture = same blind spots).

One-line doctrine: **Plan with Superpowers → execute by risk (TDD when a bug is expensive, GSD when context-rot is the enemy) → always close with an adversarial review.**

## Where to get these

These install from the Claude Code plugin marketplace (and, for Superpowers/GSD, their GitHub repos). **Install them user-global** so they're available in every project, not just one. `/review` and `/ultra-review` ship inside Claude Code already.

The "sell outcomes, not workflows" lesson travels with this stack: when you put these in front of a client or teammate, pitch the outcome (hours saved, mistakes prevented, throughput gained), not the skill names.

**Sources:** Public Claude Code / Anthropic skills; framing after Nate Herk. Interpreted digest.
**Related:** [[3ms-framework]], [[four-cs-framework]]
