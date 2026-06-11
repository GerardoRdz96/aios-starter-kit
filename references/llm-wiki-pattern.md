# LLM Wiki pattern (digest)

A pattern for building a personal knowledge base that an LLM maintains for you. Move from query-time retrieval (RAG) to a persistent, compounding knowledge artifact. This is the idea your whole wiki is built on.

> **Credit:** the "LLM Wiki" idea is Andrej Karpathy's. This page is an interpreted digest.

## The core idea

Instead of retrieving from raw documents every time you ask a question, you keep a curated wiki of interpreted markdown pages that the LLM owns and maintains. Knowledge **compounds**: every source you ingest and every good answer you get gets filed back as a page, so the artifact gets richer over time instead of resetting each session. The connections between pages are as valuable as the pages themselves.

It's an idea, not a product — meant to be handed to your agent (Claude Code, Codex, OpenCode), which then builds the specifics with you. The lineage is Vannevar Bush's Memex (1945): a private, actively curated knowledge store with associative trails between documents. Bush couldn't solve who maintains it. The LLM does.

## Why it beats chat memory

Chat history is a transcript: it scrolls away, it isn't organized, and a model starting a fresh session has none of it. A wiki is the opposite — it's curated, cross-linked, and reloaded deliberately. The LLM reads an index first and drills into exactly the pages it needs, so the knowledge is *retrievable and consistent*, not buried in a thousand past messages. Each answer you bother to file back makes the next answer cheaper and better. Chat forgets; the wiki accumulates.

## Architecture — three layers

1. **Raw sources** — your curated source documents (articles, papers, transcripts, data). Immutable: the LLM reads but never modifies them. Source of truth.
2. **The wiki** — a directory of LLM-generated markdown: summaries, entity pages, concept pages, comparisons, an overview. The LLM owns this layer entirely — creates pages, updates them on new sources, maintains cross-references, keeps everything consistent. You read; it writes.
3. **The schema** — a config doc (`CLAUDE.md` / `AGENTS.md`) that tells the LLM how the wiki is structured, the conventions, and the workflows. This is what makes the LLM a disciplined maintainer rather than a generic chatbot. You co-evolve it over time.

## Two navigation files

- **`index.md`** — content-oriented catalog. Every page with a link, a one-line summary, organized by category. The LLM updates it on every ingest and reads it *first* when answering, then drills in. Works well at moderate scale (~100 sources, hundreds of pages) with no embedding/RAG infrastructure.
- **`log.md`** — chronological, append-only. Ingests, queries, lint passes. A consistent prefix (`## [2026-04-02] ingest | Title`) keeps it parseable with plain unix tools.

## Operations

- **Ingest.** Drop a source in, tell the LLM to process it. It reads, discusses takeaways with you, writes a summary page, updates the index and related pages, appends a log entry. One source can touch many pages.
- **Query.** Ask against the wiki. The LLM finds relevant pages, reads them, synthesizes a cited answer. Key insight: **good answers get filed back as new pages** so explorations compound instead of vanishing into chat.
- **Lint.** Periodically health-check: contradictions, stale claims superseded by newer sources, orphan pages, index drift.

## Wiki vs RAG — why not a vector database?

The standard answer to "give the LLM my knowledge" is RAG: chunk documents, embed them, retrieve top-k chunks at query time. The wiki deliberately skips all of that. At personal scale, it wins on every axis that matters:

| | RAG (vector store) | LLM wiki |
|---|---|---|
| **What's stored** | Raw chunks of source text | *Interpreted* pages — already synthesized, deduplicated, reconciled |
| **Retrieval** | Similarity search → top-k chunks, may miss or fragment | Read the index → drill into whole, coherent pages |
| **Contradictions** | Both versions retrieved; the model must notice at answer time | Resolved at *ingest* time — the lint pass catches drift |
| **Compounding** | Answers vanish; the store only grows raw text | Good answers get filed back as pages — the artifact improves |
| **Human-readable?** | No — embeddings are opaque | Yes — you can open and read every page |
| **Infrastructure** | Embedding model, vector DB, chunking pipeline | Folders and markdown. `grep` works. |
| **Maintenance** | Re-embed on every change | The LLM edits a page like any file |

The honest trade-off: RAG scales to millions of documents; the index-first wiki works to roughly ~100 sources / hundreds of pages. A personal AIOS lives comfortably inside that range for years — and pays zero infrastructure for it. The deeper difference is *when understanding happens*: RAG defers interpretation to query time (every question re-reads raw chunks); the wiki does interpretation once, at ingest, and every later question benefits. If you ever outgrow it, the wiki is also the best possible *input* to a RAG system — interpreted pages chunk better than raw transcripts.

## Why it works

The hard part of a knowledge base is the bookkeeping — cross-references, keeping summaries current, noticing contradictions, consistency across dozens of pages. Humans abandon wikis because maintenance grows faster than value. LLMs don't get bored and can touch fifteen files in one pass, so maintenance cost stays near zero and the wiki stays alive. The human curates sources, directs analysis, asks good questions, and thinks about meaning. The LLM does the rest.

## How this kit applies it

This digest is paired with [wiki-protocol.md](wiki-protocol.md), which maps the pattern onto concrete folders: `knowledge/` is the raw layer, `references/` is the wiki, `CLAUDE.md` is the schema. The boundary rules (wiki vs `memory/` vs `decisions/`) live in the protocol.

**Sources:** Andrej Karpathy, "LLM Wiki." Interpreted digest.
**Related:** [[wiki-protocol]], [[index]]
