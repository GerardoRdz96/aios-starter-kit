---
name: session-handoff
description: Use when the user wants to wrap up, clear context, switch machines or tools, or continue work in a fresh session — "hand off", "wrap up this session", "save where we are", "I need to clear context", "write a handoff", "/session-handoff". Prints and saves a structured handoff note (what we did, files touched, open decisions, next steps) so the next session — in any tool — can pick up exactly where this one left off.
argument-hint: [optional: topic or destination of the handoff]
---

## What this skill does

Generates a **handoff note** for the current session: a single markdown block that a fresh session (or a different AI tool entirely) can read to continue the work without re-deriving anything. This is the cheapest insurance an AIOS has against context loss.

*Pattern credit: Nate Herk's session-handoff skill — "if you keep retyping the same prompt, that's a skill."*

## When to fire

- The user says they're done for now, switching tools (Claude Code ↔ Cowork ↔ another CLI), or context is getting full.
- Proactively offer (one line, don't insist) when a long session is clearly winding down.

## The handoff template

Produce this, filled in from the actual session — concrete file paths, not vague summaries:

```
# Session handoff — {date} — {topic}

## What we did
- {completed item, with file paths}

## Files created / changed
- {path} — {one-line what/why}

## Open decisions (waiting on the user)
- {decision} — options considered: {...}

## In progress / next steps
1. {next concrete action, specific enough to start cold}

## Gotchas for the next session
- {anything surprising: a failing test, a quirk found, a constraint}
```

## Where it goes

1. **Print it in chat** (always — the user may just copy it).
2. **Save it** to `knowledge/handoffs/{YYYY-MM-DD}-{slug}.md` (create the folder if needed). This is a deliberate exception to the "`knowledge/` is immutable raw source" rule: a handoff is a local, gitignored operational record of *this* session, not a fact that graduates into `references/`. Keep `handoffs/` out of version control so private session notes never get committed.
3. If any item belongs in `pending.md` (a follow-up that would otherwise be lost), append it there too and say so.

## Guardrails

- Report honestly: if something is half-done or broken, the handoff says so. A flattering handoff is a useless handoff.
- Keep it under a page. The next session needs orientation, not a transcript.
