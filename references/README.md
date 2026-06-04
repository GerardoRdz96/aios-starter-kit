# references/ — your AIOS knowledge wiki

This folder is your **knowledge wiki**: a set of interpreted, cross-linked markdown pages that your AI owns and maintains for you. It follows Andrej Karpathy's "LLM Wiki" pattern — knowledge that *compounds* over time instead of resetting every chat session.

## The three-layer pattern

```
knowledge/      raw, immutable sources you drop in (articles, PDFs, transcripts, data)
   ↓ the AI reads and interprets
references/      THIS folder — the wiki the AI writes: digests, concept pages, guides
   ↑ governed by
CLAUDE.md + references/wiki-protocol.md      the schema that keeps the AI disciplined
```

- **`knowledge/`** is the source of truth. The AI reads from it but never rewrites it.
- **`references/`** is the wiki. The AI creates and updates pages, keeps cross-links consistent, and keeps the catalog current. **You read it; the AI writes it.**
- **`CLAUDE.md`** + [`wiki-protocol.md`](wiki-protocol.md) are the schema — the conventions and workflows that turn a generic chatbot into a disciplined wiki maintainer.

## Start here

- **[index.md](index.md)** — the catalog. The AI reads this *first* to find the right page, then drills in. Every page is listed here once.
- **[log.md](log.md)** — append-only timeline of what changed and when.
- **[wiki-protocol.md](wiki-protocol.md)** — the full rules: page format, naming, the ingest → query → lint loop, and the `CLAUDE.md` budget. **Read this to understand how the wiki operates.**

## The loop, in one breath

**Ingest** a source → the AI writes/updates pages, updates the index, logs it. **Query** the wiki → the AI answers with citations and files good answers back as new pages. **Lint** periodically → catch contradictions, stale claims, orphans, index drift.

This is a starter kit — a handful of framework pages ship with it. Everything else, you and your AI grow together.
