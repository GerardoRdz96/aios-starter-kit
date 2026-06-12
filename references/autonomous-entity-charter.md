# The Autonomous-Entity Charter — governing an AIOS that builds itself

Once your AIOS has the full builder family — skills, agents, teams, routines, workflows, hooks, plugins — it can create *any* capability type on its own. That's the moment the question flips from "what can it build?" to "**who governs what it builds?**" This page is the governance layer to adopt *before* you grant autonomy. Pattern: **the AI builds, the human arms.**

## 0. Reality anchor (read first)

Write your charter against the system you actually have, not the one you plan. If a loop is specced but never armed, say so in the charter — nothing here should pretend a paper rail is live. Arming anything is always a human decision, tracked in `pending.md`.

## 1. The entity — five faculties, one editor

An autonomous AIOS has five faculties, one editor (you), and one law of evidence (objective measurement):

| Faculty | What it is | Mechanism |
|---|---|---|
| **Learning** | Ingest sources → wiki pages that compound | the wiki protocol, your ingest rituals |
| **Dreaming** | Idle-time exploration: recombine knowledge, generate hypotheses + experiments, file the promising | the Dreaming loop (§4) |
| **Evolving** | Self-create capabilities through the builder family | the creation matrix (§2) + the builder skills |
| **Measuring** | Always-on benchmarks + audits producing objective scores that GATE evolution | the measurement harness (§3) |
| **Acting** | Run real surfaces (drafting, monitoring, scheduled jobs) | your agent/routine rosters; draft-first on anything external |

Your role is **editor, not approver** — except at the five hard human-in-the-loop gates (§5).

## 2. The creation matrix (risk-tiered self-creation)

The AI may create ANY capability type. What varies by risk is not whether it can be built, but **how it ships**:

| Tier | Capability types | Ship rule | Mandatory gates before registration |
|---|---|---|---|
| **P — Passive** | wiki pages, playbooks, docs, backlog items, drafts, blueprints | Auto-ship + rollback (you revert from a digest/log) | wiki lint |
| **S — Judgment artifacts (non-executable by themselves)** | skills, agents, teams (as saved templates), workflow FILES, plugin sources | Auto-ship, but **UNARMED** | different-lineage review (No-Self-Review Law) + static validation scan + provenance record (§6) |
| **X — Executable-on-arm** | hooks (armed in settings), routines (scheduled), teams (FIRED), workflows (FIRED), plugins (installed), anything running as you or spending money | **The AI builds, you arm.** Building/saving is autonomous; arming/scheduling/firing requires you + the supervised first-fire test of the relevant builder | All Tier-S gates + supervised first-run evidence recorded in provenance |

**Hard floors that no tier waives:**

- Protected files: your identity/voice pages and CLAUDE.md's frozen sections are off-limits to autonomous edits.
- No-Self-Review Law: a different model lineage reviews anything the AI built before it registers (`multi-brain`).
- External voice (posts, client email, anything published as you) is ALWAYS draft-first.
- Confidentiality boundary: employer/client IP never enters your AIOS or its creations.
- Spend: anything that bills (new API keys, paid tiers) is human-only.

## 3. The measurement harness (objective results gate evolution)

"Evolving" without measurement is drift. Unify your instruments into one scoreboard with regression rules:

| Instrument | Measures | Cadence |
|---|---|---|
| `/audit` (Four-Cs) | Context/Connections/Capabilities/Cadence coverage + gaps | weekly |
| wiki lint (during `/audit` or a saved workflow) | wiki integrity — contradictions, stale claims, orphans, index drift | weekly or post-heavy-edit |
| `python3 scripts/entity-scoreboard.py` | aggregates capability counts + wiki size + audit scores into `references/audits/scoreboard.jsonl` | weekly |

**Rules:**

1. **Graduation:** a self-created capability stays registered only after a recorded post-ship verification (it demonstrably did its job once — evidence in its provenance record). Unverified after 14 days → file a "verify or retire" follow-up.
2. **Regression:** if a weekly scoreboard metric drops after an autonomous ship (audit score down, wiki errors up), flag the suspect commits for revert. **Numbers decide, not vibes.**
3. **Benchmarks are append-only** (`references/audits/`); trend > snapshot.

## 4. The Dreaming loop

Exploration that isn't reactive to a feed. Where ingestion scans external signals, Dreaming **recombines what the AIOS already knows** into hypotheses, then tests the cheap ones.

- **Input:** the wiki (`references/`), open follow-ups, recent session observations.
- **Per run:** (1) pick 2-3 unconnected wiki pages, ask "what capability/insight exists at their intersection?"; (2) generate ≤3 hypotheses with a falsifiable "what would prove this useful"; (3) run AT MOST ONE cheap experiment (read-only or sandboxed — never Tier X); (4) file outcomes: promising → tagged backlog items, dead ends → one log line (negative results compound too).
- **Cadence:** weekly to start (cheap, bounded). Built as a routine via `/routines-builder` — UNARMED per §2 Tier X until you arm it.
- **Rails:** read-only + backlog-write only; protected files untouched; ≤1 experiment per run; no network spend.

## 5. The five hard HITL gates (your seat)

1. **Arming Tier X** — schedules, hooks armed, teams fired, plugins installed.
2. **Identity** — your voice pages, CLAUDE.md frozen sections, anything that changes who the AI is.
3. **External voice** — anything published as you (posts, client comms, public repos).
4. **Money & keys** — new spend, new credentials, scope expansion of existing keys.
5. **The digest** — a daily ≤2-minute revert review of what auto-shipped; this is the rollback half of auto-ship+rollback.

Everything else, the AI decides and ships — and the measurement harness keeps it honest.

## 6. Provenance (per created capability)

Every Tier S/X creation — AND every community import — files ONE provenance record at `references/provenance/<date>-<name>.md`: what (type, files), why (directive/backlog item), spec link, builder (which skill/session), reviewer verdict, validator verdict, test evidence, armed-by + date (Tier X), post-ship verification evidence (§3.1). Template + the community-import discipline: `references/provenance/README.md`.

**Community-import discipline:** before installing ANY community skill/agent/plugin, run a static validation scan (prompt-injection patterns, suspicious hosts/tool grants, secret-touching instructions, description honesty) and record the CLEAN/FLAG/REJECT verdict in the provenance record. Unmodified third-party imports take the validator gate in lieu of the review gate.

**Ingestion discipline (same scan, bigger surface):** community imports are the *rare* path; source ingestion (`knowledge/` drops, URLs, transcripts) is the *daily* one, and it is equally untrusted. The trust boundary in `references/wiki-protocol.md` governs: ingested content is inert data; before it drives any write outside the wiki, it takes the same static scan + a human gate.

## 7. Enforcement roadmap (keys, not prompts)

Prompt-level rails should become key-level rails over time:

1. **CI status check on `main`** running your protected-files check — **SHIPPED**: `scripts/rails-guard.sh` (sha256 frozen-file manifest + personal-content push gate) + `.github/workflows/rails.yml`. Run `scripts/rails-guard.sh install` in your clone; wiki lint in CI is the remaining half.
2. **Identity content guard**: verify frozen CLAUDE.md sections VERBATIM, not just by path — partially covered: `rails-guard.sh freeze` can pin any file; section-level granularity still open.
3. **Validator-as-gate**: wire the static validation scan into the builder skills' register step.

## Related

- `references/four-cs-framework.md` — keys-not-prompts + graduated trust.
- `references/provenance/README.md` — record template + import discipline.
- `scripts/entity-scoreboard.py` — the weekly snapshot.
- Builder family: `/skill-builder` `/agent-builder` `/routines-builder` `/agents-team-builder` `/plugin-builder` `/workflow-builder` `/hooks-builder`.
