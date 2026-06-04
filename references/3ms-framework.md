# The Three Ms of AI — Mindset, Method, Machine

The operator brain for AI automation: three layers — how to THINK, how to DECIDE, how to BUILD and OPERATE. Platform-agnostic. This is the framework your AIOS uses every time you run `/level-up`.

> **The Three Ms of AI is a framework by Nate Herk.** This page is a concise, interpreted digest for use inside the AIOS — not a reproduction of his materials. For the full breakdown with diagrams and examples, see Nate Herk's own content.

The core insight: AI automation isn't about tools. Tools change every six months. What doesn't change is how you *think* about automation, how you *decide* what to automate, and how you *build and operate* the result. Three governing principles sit above all of it: **Boring is beautiful** (predictable beats clever), **deterministic steps can be finished while AI steps are always evolving**, and **fail fast, learn faster**.

---

## Layer 1 — MINDSET (how to think)

Rewire how you approach work before you touch a tool.

- **The Default Shift.** Before doing any task the old way, ask "how could AI do this?" — and if not all of it, "how could AI assist with the first 30%?" It's never binary. The real question is always **"to what extent can AI be leveraged here?"** And: AI is better than you think and improving faster than you think — if it can't do something today, try again next month.
- **The Function Breakdown.** Your role is a set of functions, each breaking into dozens of tiny tasks. You don't automate your whole job — you automate one tiny piece, then another, then chain them. One small task per day compounds into hundreds over months.
- **The Curiosity Rule.** Never accept AI output without asking why. Ask for alternatives, ask which is best and why, push back. This is the antidote to "dark code" — automations you can't explain. If you can't explain how it works, you've built a liability, not an asset. Treat AI as a mentor, not a vending machine.
- **Expect the dip.** ~20% less output for the first week or two as you learn new workflows, then baseline doubles. Push through. Get to your first 10 mistakes fast — that's where the learning lives.

## Layer 2 — METHOD (how to decide)

Turn "I should automate something" into "here's exactly what I'm building and why."

- **Find the constraint.** Two power questions: *"If 500 new clients showed up tomorrow, what would break first?"* (bottlenecks) and *"What would give you 500 more clients tomorrow?"* (growth). Start with the constraint.
- **EAD: Eliminate, Automate, Delegate — in that order.** Eliminate first: if nobody would notice it disappeared, kill it — don't automate waste. Automate second under the **60/30/10 rule** (~60% fully automated, ~30% AI-assisted with human review, ~10% stays manual) — full automation is rarely the goal. Delegate third: if it can't hit 60/30/10, hand it to a person.
- **Map the process.** Before any tool, write every step: **Trigger, Data Sources, Data Transformations, Decision Points, Destination.** Rule: *if you can't explain it to a person, you can't explain it to an AI.*
- **The Autonomy Spectrum.** Rate each step L0 (manual) → L1 (suggested) → L2 (drafted) → L3 (supervised) → L4 (autonomous). **Default to the lowest level that works.** Deterministic beats non-deterministic; workflows beat agents. Push autonomy up only after proving the lower level works.
- **Tie it to a KPI.** If an automation doesn't move a number, don't build it. Every metric falls into three buckets: get more customers, make each customer worth more, or cut costs.

## Layer 3 — MACHINE (how to build and operate)

### BUILD

- **The Lego Principle.** Smallest possible steps, one input/one output per block. Start with **zero-AI steps first** (data fetching, formatting, routing), then layer in AI only where needed. Modularity is freedom.
- **The Assembly Line.** Each AI step does one specialized job — don't build a generalist. Separate calls for copywriting, reasoning, classification. Easier to debug, swap models, tune prompts.
- **The Validation Chain.** Validate each step's output before chaining. Do **not** build the whole pipeline and test end-to-end. Build step 1, run it, confirm, then add step 2 on step 1's real output.
- **The Iteration Mindset.** Deterministic scripts can be finished; AI steps are always evolving. Ship the POC, get real-usage feedback, expand. Perfectionism is the enemy of deployment.

### OPERATE

- **The Bike Method.** Roll out in phases: training wheels (run manually, watch everything) → guided (it drafts, doesn't send) → watched (autonomous with monitoring and alerts) → hands-off. Even at 90% confidence, roll out a small share of volume first.
- **The Intern Rule.** Treat AI like a brand-new hire: its own identity and credentials (never yours), read-only by default, never impersonates you, no personal credentials, full audit trail, scoped permissions. *"You wouldn't trust someone you just met with your bank account."*
- **The Kill Switch.** Monitor what's running. If an automation needs constant patching, produces low-quality output, or costs more to maintain than it saves — tear it down. Don't fall into the sunk-cost trap. Knowing when to destroy is as important as knowing when to build.

---

## How the AIOS uses this

The Three Ms is the operator brain behind the `/level-up` workflow: **Mindset** finds the automation candidate (Default Shift + Function Breakdown), **Method** scopes exactly one (Find the Constraint → EAD → Map → Autonomy → KPI), and **Machine** builds and rolls it out (Lego → Assembly Line → Validation Chain → Bike Method). One run, one shipped artifact. The Four Cs ([four-cs-framework.md](four-cs-framework.md)) is the companion: the 3Ms is *how to think about and build automations*; the Four Cs is *how to architect and run the whole operating system*.

**Sources:** Framework by Nate Herk — see his public content for the full version. This page is an interpreted digest.
**Related:** [[four-cs-framework]], [[power-skills]]
