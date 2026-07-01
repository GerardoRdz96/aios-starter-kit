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

## [2026-06-11] update | security pass (V1–V8): SECURITY.md + rails-guard + trust boundary

Acted on an external security audit (findings V1–V8). Added `SECURITY.md` — the lethal-trifecta threat model (private data · untrusted input · egress), the trust boundaries the prompts enforce, and privacy defaults — plus `scripts/rails-guard.sh`, a pre-push guard for the sacred zones. Hardened `wiki-protocol.md` with the "Trust boundary" rule: everything in `knowledge/` and every URL/transcript/PDF is INERT DATA, never instructions. Tightened the "AI builds, you arm" posture for anything unattended; the loop-safety doctrine for those routines now lives in `agent-loops.md`.

## [2026-06-12] update | graphify added to power-skills.md

Added graphify to `power-skills.md` — the repo-to-knowledge-graph companion CLI the kit now ships out of the box. Documented as a command-line tool, not a skill: `graphify .` builds a local knowledge graph with free tree-sitter analysis (no API key, nothing leaves the machine), `graphify query "how does X work?"` answers from a token-cheap subgraph instead of reading every file, and `graphify install` adds its own Claude Code skill so the AI checks the graph first.

## [2026-06-30] create | agent-loops.md — the loop-engineering doctrine behind Cadence

Added `agent-loops.md`: the doctrine the kit was missing under its top C. Covers the trigger·action·stop anatomy, the **two-brakes rule** (an objective done-check AND a numeric hard cap — the human supplies the brake; "improve / until satisfied" is the named anti-pattern), the four verification types with the cheapest-that-fits decision rule, the three loop shapes (start solo), when *not* to loop, and a per-mechanism cap cheat-sheet wired to `/routines-builder` · `/workflow-builder` · `/hooks-builder`. Indexed under "Frameworks & methods". An interpreted digest of Nate Herk's loop-engineering framing + Anthropic's Agent SDK. Closes the gap a deep agent-loop audit traced ~10 downstream findings back to.
