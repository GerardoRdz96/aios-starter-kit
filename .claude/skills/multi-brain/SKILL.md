---
name: multi-brain
description: |
  Multi-LLM auto-router. Your main assistant is the orchestrator and driver; it routes a sub-task to a different model ONLY when that model fits the job better than the main one alone. The other brains are tools the orchestrator calls — the user talks to one assistant the whole time. The roster below is YOURS TO FILL IN: define which models you have, what each is best at, and how to call it. Fires automatically when a routing rule matches.

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  HARD RULE — THE NO-SELF-REVIEW LAW (READ THIS FIRST)
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  When the user asks you to "check / review / verify / sanity-check / second-opinion" ANY work YOU just produced — code, writing, plan, anything — route the review to a model from a DIFFERENT lineage (different company/architecture) if one is on the roster. A model reviewing its own output has the same blind spots that produced the bug. If no second lineage is installed, say so, then re-derive the check from scratch instead of rubber-stamping.

  Phrases that MUST trigger a cross-model review: "check your work" · "review what you just did" · "is this right?" · "second opinion" · "sanity check" · "double-check" · "make sure this works".
---

# Multi-Brain Auto-Router

Many brains, one terminal. The orchestrator drives and stays in front of the user; it hands a sub-task to whichever brain is genuinely better for it, then integrates the result. Routing should be invisible and **rare** — most turns stay with the main model.

**Why different lineages matter:** two models from the same company share training, so they share blind spots. Cross-architecture diversity (e.g. Anthropic + OpenAI + Google + a local open-weights model) is what actually catches errors.

## Your roster — FILL THIS IN

Edit this table for *your* setup (run `/onboard` or just edit it by hand). Delete rows you don't have; add rows for what you do. Examples are placeholders.

| Brain | Lineage | Best at (role) | How to call | Cost |
|---|---|---|---|---|
| **(main)** — e.g. Claude | e.g. Anthropic | orchestrator, builder, driver | — | plan |
| *example:* Codex | OpenAI/GPT | code review, adversarial critic, rescue when stuck | `codex exec "<prompt>"` | plan |
| *example:* Gemini | Google | multimodal (video/audio/PDF), huge-context repo scans | `gemini -p "<prompt>" @file` | free tier |
| *example:* local model | open-weights (Ollama) | private/offline work, free bulk tasks | `ollama run <model> "<prompt>"` | free |

> No second CLI installed yet? That's fine — the skill stays mostly asleep. The No-Self-Review Law still applies in its fallback form (re-derive, don't rubber-stamp). When you install a second brain, add the row and the routes light up.

## Routing table — fire when:

- **[MUST]** review/check/verify work the main model just produced → different-lineage review (the Law above)
- "tear apart / stress test / poke holes" → adversarial review on a different lineage
- "I'm stuck / hand it off" OR the main model failed the same operation 2+ times in a row → rescue route to another brain (send full context: failing output, what was tried)
- video / audio / huge PDF, and a multimodal brain is on the roster → multimodal route
- "scan the whole repo / find every place X", and a huge-context brain is on the roster → whole-repo route
- "ask all the models / consensus" → consensus panel, capped at **3 lineages**, each returning the same structured template (recommendation / risks / assumptions / confidence); the orchestrator adjudicates by evidence, not by averaging

## Do NOT fire for (stay with the main model):

- "Explain / what is / how does" → direct answer
- "Write / draft / build / edit / plan" → direct (but if the user then says "now check your work" — the Law applies)
- Reviewing content the USER wrote (their notes, their draft) → direct
- Conversation, status, file ops, normal Q&A → direct
- "What did we decide?" → the decisions log and wiki, not another model

## Announcement protocol

Whenever you route somewhere the user did NOT explicitly request — announce in one line BEFORE running, so they can stop you with one word:

```
[multi-brain] routing review to <brain> — different lineage, no self-review
[multi-brain] handing to <brain> rescue — failed the same step 2x
```

## Failure-detection rule (deterministic, not a vibe)

2× same test failure, 2× same shell error, or 2× same edit with no progress → MUST route a rescue (if a second brain exists) or stop and tell the user. Reset the counter only when the step passes, the goal changes, or the user says "keep trying."

## Cost discipline

Default to the main model. Route only when the specialist's strength is the actual bottleneck. One strong model usually matches an ensemble at a fraction of the cost — the ensemble's real win is catching errors on high-stakes work, not speed. Under-firing is fine; over-firing breaks trust and burns money.
