# Agent Loops — trigger · action · stop + verification (loop engineering)

An agent loop is an AI that **reasons → acts → observes**, repeating toward a goal until a
done-criterion is met or you stop it. This is the doctrine behind **Cadence**, the fourth C: a
cadence that *iterates* is a loop, and a loop you can't stop is a runaway token bill. The new
discipline is **loop engineering** — you stop prompting turn-by-turn and design the system that
prompts the agent for you. But the load-bearing truth is the opposite of the hype: **a loop is
only as good as its done-check**, most tasks don't need a loop at all, and unattended 24/7 swarms
are usually counterproductive for knowledge work.

> **An interpreted digest of Nate Herk's "loop engineering" framing + Anthropic's Agent SDK
> guidance.** Read it before you build anything under Cadence. *Source: Nate Herk · Anthropic.*

## The anatomy — three parts, and a fourth that's the whole point

A loop is a **trigger**, an **action**, and a **stop condition**. The inner cycle is **reason → act
→ observe** — the *observe* beat is the mechanism: the agent reads its own result instead of
assuming it worked.

1. **Trigger** — what kicks it off: a schedule (cron), an event, or a manual fire. "Runs on its
   own" is not a separate shape — it's any loop left unattended, which is exactly why those need
   the *strongest* stop-limits.
2. **Action** — the agent reasons, then acts with its tools. Give it the *right tools for this
   job's verification* — a visual build needs a screenshot, a functional one needs a test runner.
3. **Stop condition** — the "done?" check **plus a hard cap**. The agent verifies its result
   against the done-criterion; if not met, act + observe again; if met, stop and report.

## THE TWO BRAKES — the one rule this page exists for

Every loop needs **both** brakes. Miss either and you have a runaway, not a system.

- **BRAKE 1 — an OBJECTIVE done-check.** State the goal so the *model* can test against it. "Every
  test in `tests/` passes" is a goal; **"improve it" / "until you're satisfied" is not** — that is
  the named anti-pattern. When you can't be fully objective, fall back to a numeric proxy ("stop
  when the average rubric score ≥ 9").
- **BRAKE 2 — a NUMERIC hard cap.** Max tries, max tokens/budget, or max time. **A model never
  reliably stops itself** — so the human supplies the brake. Your hard cap is the difference
  between an experiment and a surprise bill.

Anthropic's Agent SDK calls *verify your work* **"the most underrated step"** — the beat beginners
skip, and what separates a loop that converges on a real result from one that confidently produces
polished, wrong work and calls it done.

## The four verification types — wire the right one (cheapest that fits)

| Type | What it is | Reach for it when |
|---|---|---|
| **Functional** | A machine answers yes/no, zero opinion — tests pass, build compiles, word-count < 50 | **Always try this first** |
| **Visual** | Must be *seen* — UI, layout, an image. The agent looks at a screenshot | The output is visual |
| **Judgment** | Needs taste — you write a rubric and a **different AI (a different model lineage)** scores it | Quality is subjective but rubric-able |
| **Human gate** | The loop **pauses, you approve, it continues** | The next step is irreversible |

**The decision rule — take the first that fits:** (1) Can a command/test return a boolean with
zero opinion? → **functional**. (2) Must it be *seen* to confirm? → **visual** (a real screenshot;
reading the HTML source to *infer* the look does not count). (3) Needs taste? → **judgment**,
scored by a **different lineage** — never let the model grade its own work (the No-Self-Review Law;
`/multi-brain`). (4) Is the next action irreversible — **send, delete, publish, pay, deploy, merge
to main**? → **human gate**: pause for approval, or in an unattended loop push to a branch + a
digest, never a silent action.

## The three loop shapes — start solo

The strong default is the **solo loop**. *The majority of tasks don't need loops* — one terminal
session and a good prompt covers most work. The "five agents each orchestrating five more" picture
is mostly false: without understanding the job, you just scale the bugs. Climb only when a single
agent genuinely can't keep up.

1. **Solo loop** — one agent reasons/acts/observes/repeats. Easiest to build and debug. **Start here.**
2. **Maker → Checker** — quality matters: one agent makes, a **separate fresh** agent grades it (so
   it can't grade its own work). The No-Self-Review Law in loop form.
3. **Manager → Helpers** — the job is big: one orchestrator splits the goal and hands pieces to
   sub-agents in parallel.

## When NOT to loop

A one-shot task with a fixed, predictable path — a single prompt or script is cheaper and more
reliable. Anything where "done" **isn't checkable** — no test, format, or criterion means nothing
to verify, so it drifts. If "done" isn't checkable, fix the goal first or do it by hand. And don't
chase loops that run for hours toward an unreachable bar.

## Pick the mechanism — and the cap it makes you supply

The kit gives you several ways to run a loop. **None has a model-side terminator — you supply the
brake on every one.**

| Mechanism | Build it with | When | The cap YOU must add |
|---|---|---|---|
| **Solo terminal loop** | just a prompt | most work; watched | you watch it / Esc; a turn cap |
| **`/loop <interval>`** | Claude Code built-in | poll something during a session you're in | Esc; it dies with the terminal |
| **A watched depth-loop** | your harness's run-until-done mode (a bash `until` loop is the portable version) | iterate to a done-check, watched | the `until <check>` **and** a `MAX_ITER` |
| **Hook** | `/hooks-builder` | event-triggered, local | a re-entry guard + (for a blocking Stop hook) a counter cap — never "until satisfied" |
| **Dynamic workflow** | `/workflow-builder` | width fan-out that iterates (until-dry / -count / -budget) | `round < MAX_ROUNDS` **and** a budget check at the top of the loop |
| **Cloud routine** | `/routines-builder` | unattended cadence, survives a closed laptop | a **single-pass** success criterion (NOT iterate-until-done) + the supervised "Run now" first |

**Before you arm any unattended loop:** run it once, watched, and confirm one real round-trip —
`/routines-builder` and `/hooks-builder` enforce this supervised first-run as a hard gate. Cadence
is earned, never free.

## How this wires into the kit

- **Cadence**, the 4th C, *is* loops — this page is its doctrine. [[four-cs-framework]]
- The **builders** that scaffold loops each owe you both brakes: `/routines-builder`,
  `/workflow-builder`, `/hooks-builder`, `/agents-team-builder`.
- Governing loops that build *themselves*: [[autonomous-entity-charter]] — *the AI builds, the
  human arms.*
- The self-improving loop the class demos (weekly `/aios-audit`) is itself a loop: give it a done-check,
  and remember a self-audit is *same-lineage* — a heartbeat, not a different-lineage review.

**Source:** Nate Herk ("loop engineering") + Anthropic Agent SDK (*verify your work*); the
reason→act→observe cycle is ReAct. This page is an interpreted digest.
**Related:** [[four-cs-framework]], [[autonomous-entity-charter]], [[3ms-framework]], [[power-skills]].
