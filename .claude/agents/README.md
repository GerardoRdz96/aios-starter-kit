# Subagents

Subagents are specialized Claudes your AIOS (Sage) delegates to. Each one lives in its own file here as `.claude/agents/<name>.md` — a YAML frontmatter block (name, description, tools, model) plus a prompt that defines its role, process, and constraints.

## Why delegate?

You hand a focused job to a subagent so it runs in its **own clean context window**, separate from your main conversation. That keeps your chat uncluttered and lets the subagent use only the tools it needs (most ship read-only). The subagent does its work and returns one result — it never edits on its own unless its tools allow it. The main session decides what to do with what comes back.

## What ships in this kit

- **`scribe`** — turns a raw meeting/call transcript dropped in `knowledge/` into a structured digest (summary, key decisions, action items, open questions). Read-only: it returns the digest, it doesn't file it.
- **`warden`** — read-only audit of the `references/` knowledge wiki. Hunts for broken `[[links]]`, orphan pages, stale claims, contradictions, and index drift, then reports findings. It never edits — it tells you what to fix.

Both are scoped to `Read, Grep, Glob` and run on a smaller model, so they're cheap to fire.

## Building more

These two are starting points. Build your own with **`/agent-builder`**, which walks a decision gate (is this really an agent, or a skill/routine?) and a Discovery Interview, then writes a new file here. Reach for a subagent when a job genuinely benefits from isolation or restricted tools — otherwise a skill is usually the better fit.
