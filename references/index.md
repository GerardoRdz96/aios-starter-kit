# Wiki Index

The catalog of your AIOS knowledge wiki. Every page lives here once, under a category, with a one-line summary. **Read this first** when answering a question, then drill into the pages it points to. Update it whenever you create, rename, or retire a page — a page that isn't in the index is invisible.

How the wiki works: [wiki-protocol.md](wiki-protocol.md). Timeline of changes: [log.md](log.md).

This is a **starter kit**. The few pages below ship with the template. You and your AI add pages here as the wiki grows — one new entry per page created.

---

## Operating the wiki

- [Wiki Protocol](wiki-protocol.md) — how the AI maintains the wiki: three layers, page conventions, ingest/query/lint workflows, the CLAUDE.md budget. The schema.
- [LLM Wiki pattern](llm-wiki-pattern.md) — digest of Andrej Karpathy's "LLM Wiki" idea this whole system is built on, including the wiki-vs-RAG comparison. *Source: Karpathy.*

## Frameworks & methods

- [The Three Ms of AI](3ms-framework.md) — Mindset / Method / Machine. How to think about, decide on, and build automations. Drives `/level-up`. *Source: Nate Herk.*
- [The Four Cs of an AIOS](four-cs-framework.md) — Context / Connections / Capabilities / Cadence. How to architect and run an AI operating system; what `/audit` scores against. Includes the two-layer split (second brain vs AIOS), CLAUDE.md-as-router, the tier-1 connections heuristic, and keys-not-prompts. Companion to the 3Ms. *Source: Nate Herk.*
- [Power Skills](power-skills.md) — the Claude Code skill stack and the plan → execute → review build doctrine: Superpowers, GSD, route-by-risk, `/review`, Frontend Design, the self-verify 70%→92% rule, install commands.
- [Autonomous-Entity Charter](autonomous-entity-charter.md) — the governance layer for an AIOS that builds itself: five faculties, risk-tiered creation matrix (P/S/X — "the AI builds, the human arms"), measurement harness with graduation/regression rules, five hard HITL gates, provenance records (`provenance/`). Adopt before granting autonomy.

## Concepts

*(Add concept and entity pages here as you ingest sources — one page per concept, kebab-case filename.)*

## Tools & APIs

*(Add tool, CLI, and API guides here as you wire connections into your AIOS.)*

## Sources

*(Source digests — pages that summarize one raw `knowledge/` file — can live in their own category or under the concept they inform. Mark them `(digest)` and cite the raw file in `**Sources:**`.)*

## Projects

*(Add a page per project you build or reference.)*

## Working with you

- [Voice](voice.md) — how you want your AIOS to write; the register to match when it drafts *for* you. A fill-in-the-blank template — customize it.
