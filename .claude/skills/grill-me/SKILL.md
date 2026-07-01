---
name: grill-me
description: Use PROACTIVELY whenever the user is working something OUT OF THEIR HEAD rather than asking a quick question — mulling or scoping a plan/design/decision, describing a process or how they do something, floating a half-formed idea, or wanting to capture knowledge before building. Natural signals: "I've been thinking about…", "I have an idea for…", "I want to build/plan/figure out…", "I'm not sure how to approach…", "let me think this through", "help me scope this", "here's how I do X". Also the explicit "grill me", "interrogate me", "stress-test this", "/grill-me". The relentless one-question-at-a-time extraction engine that captures their thinking into a durable doc and graduates it into the wiki. SAFETY: unless they explicitly asked to be grilled, OFFER first ("want me to grill you on this and capture it?") and wait for yes — never silently launch a long interview on a quick question.
argument-hint: [topic to grill on]
---

## What this skill does

Relentlessly interview the user about every aspect of a topic until you reach shared understanding. Walk down each branch of the decision tree, resolving dependencies one by one. The real goal is to **extract what's in their head into a durable, organized markdown file** so nothing is lost as context fills up — and then **graduate** that capture into the wiki so the knowledge compounds.

This is the general-purpose extraction engine. The builders (`/skill-builder`, `/agent-builder`, …) each run a Discovery Interview tied to building one artifact. This skill grills the user about *anything* — a business process, a plan, a design, a decision — for its own sake, and files the result.

*Pattern credit: original "grill me" prompt by Matt Pocock; checkpointing fork by Nate Herk. This is the AIOS adaptation: captures live in `knowledge/grills/` and graduate into `context/` or `references/` per `references/wiki-protocol.md`.*

## When to fire — and offer vs. just go

Watch for the **situation**, not the phrase: the user is mulling a plan out loud, describing "how I do X," floating a half-formed idea, or scoping something before a build. That's a grill opportunity. But the cost of getting it wrong is asymmetric — silently launching a 30-question interview when they wanted a quick answer is worse than a missed trigger. So:

- **They explicitly asked** ("grill me", "/grill-me", "stress-test this") → **just go.**
- **You inferred the opportunity** → **OFFER first, one line, then wait:** *"Sounds like there's a lot in your head here — want me to grill you on it and capture it into the wiki? (one question at a time)"* Only start on a yes.
- **It's a genuine quick question** → do not fire. No offer.

Don't collide with neighbors: exploring brand-new design space → brainstorming; building one specific artifact → that builder's own discovery interview. Grill-me extracts knowledge and decisions the user **already holds**.

## The capture file is the whole point

Long interviews fill up context. If you hold answers only in your head, you will eventually misremember, conflate, or drop something. So you **checkpoint to disk after every single answer**. The file, not your context, is the source of truth.

## Setup — BEFORE the first question

1. **Pick the topic + slug.** From `$ARGUMENTS` if given, else ask one line: "What are we grilling on?"
2. **Get today's date:** `date +%F`.
3. **Create the capture file** at `knowledge/grills/{YYYY-MM-DD}-{topic-slug}.md` (create the folder if needed). One predictable home, regardless of topic.
4. **Seed it immediately** with the template below.
5. **Tell the user where you're saving**, in one line. Then ask Q1.

## The checkpoint rule (non-negotiable)

After EVERY answer, BEFORE the next question:
- **Append** a structured entry: the question topic, the key facts and decisions (in their words where the wording matters), and any flags (things they couldn't answer + who can).
- **Update earlier entries** if a later answer changes them. Keep the running Summary current.
- **Only then** ask the next question. Never batch multiple answers into one write.

## Interview method

- **One question at a time.** For each, provide **your recommended answer** (your best inference from their context — CLAUDE.md, the wiki, the repo) so they can confirm, correct, or redirect.
- **Resolve dependencies in order:** settle the upstream decision before the ones that depend on it.
- **Explore instead of asking.** If a question can be answered by reading a file or the wiki, do that instead.
- **Flag and move on.** When only a stakeholder can answer, capture a flag with the owner and continue.
- **Keep going** until they say done or every branch is covered. Near the end: "Anything we haven't touched?"
- Match `references/voice.md` — this is a conversation, not an interrogation transcript.

## Capture file template

```
# {Topic}: Grill / Discovery Notes
Date: {date} · Goal: {one line}

## Summary / key decisions
(running synthesis, updated as you go)

## Q&A log
### Q1 — {topic}
- Asked: {question}
- Captured: {facts, decisions}
- Flags: {open item -> owner}

## Open flags (pending input)
- {item} -> {who can answer}
```

## At the end — reconcile, then graduate

1. **Final reconciliation pass:** read the whole capture for contradictions or gaps; make the Summary stand on its own.
2. **Recap in chat:** what's captured, what's flagged (with owners), suggested next step.
3. **Offer to graduate** into the wiki, proposing the destination per `references/wiki-protocol.md`: personal/work facts → a `context/` file; a decision-with-a-why → append to `decisions/log.md`; fast-changing personal facts or preferences → `memory/` (if present); evergreen reusable knowledge → a `references/` page (then update `index.md`, append to `log.md`, and add a row to `knowledge/README.md`'s Source registry: date · `knowledge/grills/<file>` · grill capture · graduated to `<page>`); a build plan → the relevant project spot. **Heads-up: `references/` is committed and public** — unlike the gitignored `knowledge/grills/` capture and the privacy-gated `context/` — so only graduate non-sensitive evergreen knowledge there; anything tied to an employer or a specific person goes to `context/`. Let the user confirm or defer — don't auto-write into the wiki without a yes.
4. If deferred, the capture stays in `knowledge/grills/` and you log a follow-up in `pending.md`.

## Guardrails

- One question at a time. Always.
- Never skip a checkpoint. The file is the source of truth, not your context window.
- Don't invent answers — flag what only a stakeholder knows.
- No parallel knowledge store: captures in `knowledge/grills/`, polished knowledge graduates into `context/` / `references/`.
- This skill stays interactive in the live session — do not fork it to an isolated agent.
