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
