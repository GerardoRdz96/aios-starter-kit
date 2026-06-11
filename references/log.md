# Wiki Log

Chronological, append-only record of what happened to the wiki and when. Newest at the bottom. Each entry starts with `## [YYYY-MM-DD] <type> | <title>` so the log stays grep-able:

```
grep "^## \[" references/log.md | tail -5
```

Types: `ingest` (new source → page), `create` (new synthesized page), `update` (edited a page), `query` (answer filed back as a page), `lint` (health check), `trim` (CLAUDE.md budget pass).

This log is the wiki's timeline. It is **not** the other two logs:
- `decisions/log.md` — the *why* behind meaningful choices.
- `knowledge/README.md` — the registry of raw sources that exist.

---

## [2026-06-04] init | aios-starter-kit wiki seeded

Seeded the starter wiki with its schema and framework pages: `wiki-protocol.md`, `index.md`, this `log.md`, plus `3ms-framework.md`, `four-cs-framework.md`, `power-skills.md`, `voice.md`, and `llm-wiki-pattern.md`. The three layers are in place — `knowledge/` (raw) → `references/` (wiki) → `CLAUDE.md` (schema). Add pages from here as you ingest sources.

## [2026-06-11] create | builder family completed + autonomous-entity charter (kit v2.1)

Added the last two builders — `/workflow-builder` (saved dynamic workflows, width fan-out) and `/hooks-builder` (event-driven hooks with mandatory supervised first-fire) — so every capability type now has a builder. Added the governance layer for that completeness: `autonomous-entity-charter.md` (five faculties, P/S/X creation matrix, measurement harness, five HITL gates), `provenance/README.md` (record template + community-import validation discipline), and `scripts/entity-scoreboard.py` (weekly append-only snapshot). Indexed the charter; README + CLAUDE.md updated.
