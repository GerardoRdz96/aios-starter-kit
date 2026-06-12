# Facilitator Guide v2.1 — Teaching the AIOS class

*For the instructor. Everything here is yours to adapt. Full version: 120 minutes. Compressed: 90 (cut the hands-on to a demo) or 60 (modules 0–5 + wow prompt only).*

---

## The one-sentence thesis

> **An AIOS turns a forgetful chatbot into a partner that knows you, remembers what it
> learns, and grows new skills — and it's just an organized folder you can read.**

If students leave with that sentence and have run `/onboard` once, the class succeeded.

## Materials in this folder

| File | Use it for |
|------|-----------|
| `explainer.html` | Project this for the core concepts (modules 2–4 and 9). EN/ES toggle, top-right. |
| `exercises.html` | Hand to students — checkable steps, progress saves locally. |
| `images/` | Illustrations, reusable in your own slides. |
| This guide | Your run-of-show. |

---

## Run of show — v2 (120 min, 10 modules)

| # | Time | Module | What you do |
|---|------|--------|-------------|
| 0 | 0–5 | **Hook** | "How many times have you re-explained yourself to an AI this week?" The goldfish problem. Tease the 4-beat demo (below). |
| 1 | 5–10 | **Who am I & why this class** | *Your* AI journey, honestly — when you started, what you built, what surprised you. The message for a mixed room: this is months of practice, not a CS degree. Plain language is a feature. |
| 2 | 10–25 | **What is an AIOS** | Definition + purposes. Run the **with/without demo**: cold chat gives a stranger's answer; the AIOS gives a co-founder's answer. Land the **two-layer split**: Context+Connections = the second brain; Capabilities+Cadence = the OS on top. "An OS doesn't start with architecture — it starts with a *default*: one harness everything routes through." |
| 3 | 25–35 | **Anatomy & architecture** | The folder tree, live in an editor — no magic, just markdown. `context/`, `references/`, `knowledge/`, `.claude/skills/`, `connections.md`, `pending.md`, `decisions/`. Tool-agnostic: same folder works from Claude Code, Cowork, Codex, Gemini (`AGENTS.md`). |
| 4 | 35–45 | **The router: CLAUDE.md** | Open the real file. **Router, not manual** — it points at where things live; detail lives in the files. The budget protocol (200-line cap — why: it's re-read every turn, cost compounds). "Architecture engineering": can the agent find a file as fast as you can? If not, the architecture is the bug. |
| 5 | 45–60 | **Managing the Four Cs** | One slide per C with its management rule: Context → feed it + keep it findable. Connections → tier-1 heuristic (wire what you open weekly) + **keys-not-prompts** (tell the 150–200k discount-email war story — it lands hard). Capabilities → every skill use is data; update the skill same-session. Cadence → earned, never free; supervised run before arming a schedule. |
| 6 | 60–70 | **Power skills** | What each does + when: Superpowers (bug-cost dominates), GSD (context-rot dominates), route-by-risk doctrine, `/review` closer, Frontend Design. The 70%→92% self-verify rule. Show the install commands (`references/power-skills.md`). Quick aside: the **graphify** companion CLI (`uv tool install graphifyy`) — any repo becomes a knowledge graph the AI queries *before* touching code. |
| 7 | 70–80 | **Multi-brain** | Many models, one driver. Cloud CLIs + local models (Ollama) on one roster the *student* defines. The **No-Self-Review Law**: same architecture = same blind spots — reviews go to a different lineage. Demo if you have two CLIs installed. |
| 8 | 80–90 | **The LLM wiki (vs RAG)** | The Karpathy three-layer pattern — go slow, this is the deepest idea. Then the RAG comparison table (`references/llm-wiki-pattern.md`): interpretation at *ingest* time vs query time; human-readable vs opaque; zero infra. Honest trade-off: RAG wins at millions of docs; you don't have millions of docs. |
| 9 | 90–100 | **The growth rituals** | `/onboard` (day 1) → `/audit` (day 7, then weekly — show a real score) → `/level-up` (weekly, one automation) → `/grill-me` (when knowledge is in your head) → `/session-handoff` (every wrap-up). Then the builders + the Skill-vs-Agent-vs-Routine triage. |
| 10 | 100–120 | **Hands-on + wrap** | Students run exercises 0–4 live; you float. Everyone fires the wow prompt: *"what should I focus on this week?"* Share screens. Assign the rest as homework. |
| 11 | +10 (optional) | **Governing an AI that builds itself** | The v2.1 add-on — see the dedicated section below. Slot it after module 9 (the builders) for advanced rooms, or run it as a standalone part-2 opener. |

---

## The 4-beat live demo (your safety net — this IS the class in 5 minutes)

Have a **pre-onboarded** copy of the kit ready on your machine.

1. **Cold problem.** Plain chat: "what should I prioritize?" → generic. "It doesn't know me."
2. **The AIOS.** Same question in your kit → it cites your real priorities. "Same model. Different *operating system* around it."
3. **Compounding.** Drop a short transcript in `knowledge/`, have it filed into `references/`, open the new page. "It just learned something permanent."
4. **Growth.** Run `/audit`, read the score live. "It grades itself and tells me what to fix."

---

## Module 11 (optional, +10 min) — Governing an AI that builds itself

*New in v2.1. Run it after module 9 when the room skews senior, or whenever someone asks "wait — if it builds its own automations, what stops it?" That question IS this module.*

**The setup (1 min).** Point back at module 9: the kit now ships a builder for **every** capability type — skills, agents, teams, routines, workflows, hooks, plugins. The completeness is the point *and* the problem: an AIOS that can build anything needs rules about what ships how. The question flips from "what can it build?" to "**who governs what it builds?**"

**The pattern (5 min).** Walk `references/autonomous-entity-charter.md` top-down, one beat per section:

1. **Five faculties** — Learning, Dreaming, Evolving, Measuring, Acting. An autonomous AIOS is all five; you are the *editor*, not the approver.
2. **The creation matrix** — three risk tiers. **P** (passive: wiki pages, drafts) auto-ships with rollback. **S** (judgment artifacts: skills, agents, workflow files) auto-ships but UNARMED, gated by a different-lineage review + validation scan. **X** (executable: armed hooks, scheduled routines, fired teams) — *"the AI builds, the human arms."* That one sentence is the take-home.
3. **The measurement harness** — evolving without measuring is just drift. Weekly scoreboard (`scripts/entity-scoreboard.py`), graduation rule (a capability must demonstrably do its job once within 14 days or it's flagged "verify or retire"), regression rule (a metric drops after an autonomous ship → suspect commits get flagged). *Numbers decide, not vibes.*
4. **Five hard HITL gates** — arming Tier X, identity, external voice, money & keys, the daily revert digest. Everything else, the AI decides.
5. **Provenance** — one record per creation *and per community import* (`references/provenance/`): who built it, who reviewed it, was it validated, did it ever work. Community skills get a static validation scan BEFORE install — installing someone's skill is letting their instructions run inside your AIOS.

**The demo (2 min).** Run `python3 scripts/entity-scoreboard.py --dry-run` live — the room watches the AIOS count its own capabilities and grade itself. Tie it back to module 9's `/audit`: same idea, now append-only and trend-aware.

**The metaphor that lands.** Extend module 5's intern-with-keys: *you've now given the intern a workshop where it can build new tools. Fine — but the keys to actually switch each tool on stay on your keyring.* Same "keys, not prompts" doctrine, one level up.

**Slide outline (if you make slides):** (1) The builder family is complete — 7 builders, one per capability type. (2) The flip: what can it build → who governs it. (3) The P/S/X matrix — "the AI builds, the human arms". (4) Measurement: graduation + regression, scoreboard screenshot. (5) The five HITL gates. (6) Provenance + the import scan. (7) Close: autonomy is earned per-tier, never granted wholesale.

**Anticipated question:** "Isn't this overkill for a personal setup?" — Honest answer: yes, until the week it isn't. You adopt the charter the day you arm your first unattended automation; before that it's a 5-minute read that shapes habits.

## Audience calibration

- **Entry-level** (most of the room): everything runs through the demos and metaphors — goldfish, stranger-vs-co-founder, intern-with-keys. They never need to see JSON.
- **Cowork users**: show that the same folder works in Claude Desktop's Cowork tab — open the folder, talk. The CLI is the upgrade path, not the entry fee.
- **Seniors in the room**: feed them the trade-off slides — wiki-vs-RAG, CLI>API>MCP token economics, keys-not-prompts as capability-based security. Invite them to challenge the wiki scaling limit; concede it honestly (~100 sources) and show why that's fine.

## Anticipated questions

- **"Is this just a system prompt?"** No — many files read *selectively*, plus the ability to *write* new ones (the wiki) and *create* capabilities (builders). A filesystem, not a prompt.
- **"Do I need to code?"** No. `git clone` and typing `claude` is the ceiling. Cowork users don't even need that.
- **"Why a wiki and not RAG?"** Module 8. Short version: at personal scale, interpreted pages + an index beat embeddings on quality, transparency, and maintenance — and you can read every page.
- **"Is it safe to connect things?"** Module 5's war story. Keys, not prompts: scope what it *can* do; never rely on telling it what it *shouldn't*.
- **"Does my data go to the cloud?"** Local files; what the AI reads goes to the model like any chat. Secrets in gitignored `.env`; private `context/` stays out of public repos.
- **"Why Claude Code and not X?"** The pattern is portable — `AGENTS.md` proves it. This kit ships Claude Code skills because that's the richest harness today.

## Credits to name out loud

- **Knowledge wiki pattern** — Andrej Karpathy. **3Ms + Four Cs frameworks** — Nate Herk. Built on **Claude Code** by Anthropic.

Naming sources models good practice — and it's the honest thing to do.

---

## Compressed formats

- **130 min:** all 10 modules + module 11 (governance) after module 9 — best for senior rooms that will actually arm automations.
- **90 min:** keep all 10 modules; cut module 10 to a 10-minute demo of exercises 1–2; assign the rest as homework.
- **60 min:** modules 0–5 + the wow prompt. Hand out the study guide; modules 6–9 become a part-2 session (they stand alone well — module 11 makes a strong part-2 closer).
