# Facilitator Guide v2.2 — Teaching "What Is an Agentic OS — and How to Build Your Own"

*For the instructor. Everything here is yours to adapt. Full version: 120 minutes. Compressed: 90 (cut the hands-on to a demo) or 60 (modules 0–5 + wow prompt only).*

---

## The one-sentence thesis

> **An AIOS turns a forgetful chatbot into a partner that knows you, remembers what it
> learns, and grows new skills — and it's just an organized folder you can read.**

If students leave with that sentence and have run `/onboard` once, the class succeeded.

## You're joining a movement — AIOS "in the wild" (a 30-second credibility beat)

*Drop this early (module 1 or 2) so first-timers know this isn't a fringe hobby — it's a pattern serious builders independently converged on in 2026.*

- **Daniel Miessler — PAI** ("Personal AI Infrastructure," a self-described "Life Operating System," ~16k★ on GitHub): a full personal AIOS on Claude Code, with a named-assistant identity layer and one local daemon for dashboard + schedule + voice + messaging.
- **Alireza Rezvani — gAIOS** (open-source, MIT): built on the **same Four Cs** taught in this class, credited to Nate Herk — proof the framework travels beyond its author.
- **Cole Medin — "AI Second Brain"** + the "context engineering" movement (~13.5k★): the same bets we make — markdown files as memory, a simple index instead of a vector database (Karpathy's pattern), and CLI over heavyweight tool plugins.
- **The academic "AIOS"** (Rutgers, "LLM Agent Operating System," COLM 2025, arXiv 2403.16971): a *different* thing — an OS **kernel that runs under** agents. The useful contrast for the room: *theirs runs under the agent; ours runs around it, and you can read every file.*

The honest line: "You're not early to something weird. You're on time for something real." (Sources: the four projects above + arXiv 2403.16971.)

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
| 5 | 45–60 | **The Four Cs as one live thread** | **Teach this from the dedicated "spine demo" section below, not as four abstract slides.** Walk ONE worked example (daily research→email) up all four Cs: Context = `/onboard`; Connections = Gmail connector (safe Outlook stand-in) + CLI>API>MCP + keys-not-prompts war story; Capabilities = `/skill-builder` + the starter set; Cadence = **two** routines (A: research→email integrative, B: weekly `/aios-audit` self-improving loop). The escalating thread proves the layers depend on each other. |
| 6 | 60–70 | **Power skills** | What each does + when: Superpowers (bug-cost dominates), GSD (context-rot dominates), route-by-risk doctrine, `/review` closer, Frontend Design. The 70%→92% self-verify rule. Show the install commands (`references/power-skills.md`). Quick aside: the **graphify** companion CLI (`uv tool install graphifyy`) — any repo becomes a knowledge graph the AI queries *before* touching code. |
| 7 | 70–80 | **Multi-brain** | Many models, one driver. Cloud CLIs + local models (Ollama) on one roster the *student* defines. The **No-Self-Review Law**: same architecture = same blind spots — reviews go to a different lineage. Demo if you have two CLIs installed. |
| 8 | 80–90 | **The LLM wiki (vs RAG)** | The Karpathy three-layer pattern — go slow, this is the deepest idea. Then the RAG comparison table (`references/llm-wiki-pattern.md`): interpretation at *ingest* time vs query time; human-readable vs opaque; zero infra. Honest trade-off: RAG wins at millions of docs; you don't have millions of docs. |
| 9 | 90–100 | **The growth rituals** | `/onboard` (day 1) → `/aios-audit` (day 7, then weekly — show a real score) → `/level-up` (weekly, one automation) → `/grill-me` (when knowledge is in your head) → `/session-handoff` (every wrap-up). Then the builders + the Skill-vs-Agent-vs-Routine triage. |
| 10 | 100–120 | **Hands-on + wrap** | Students run exercises 0–4 live; you float. Everyone fires the wow prompt: *"what should I focus on this week?"* Share screens. Assign the rest as homework. |
| 11 | +10 (optional) | **Governing an AI that builds itself** | The v2.1 add-on — see the dedicated section below. Slot it after module 9 (the builders) for advanced rooms, or run it as a standalone part-2 opener. |

---

## The 4-beat live demo (your safety net — this IS the class in 5 minutes)

Have a **pre-onboarded** copy of the kit ready on your machine.

1. **Cold problem.** Plain chat: "what should I prioritize?" → generic. "It doesn't know me."
2. **The AIOS.** Same question in your kit → it cites your real priorities. "Same model. Different *operating system* around it."
3. **Compounding.** Drop a short transcript in `knowledge/`, have it filed into `references/`, open the new page. "It just learned something permanent."
4. **Growth.** Run `/aios-audit`, read the score live. "It grades itself and tells me what to fix."

---

## The spine demo — the Four Cs as ONE escalating thread (this IS module 5, expanded)

*The heart of the class. Don't teach the four Cs as four features — teach them as four floors of one building, by walking a single worked example up all four. The thread: a daily "research a topic and email it to me" assistant. You start with nothing and end with a real autonomous routine, and every C visibly earns its place. The dependency — no Cadence without Capabilities, no Capabilities without Connections, no Connections without Context — gets **proven**, not asserted.*

### C1 · Context — *teach it who you are* → `/onboard`
Run `/onboard` live (or open a pre-onboarded copy). The 7 questions write `context/`, `references/voice.md`, and fill `CLAUDE.md`. The point to land: this is the gap between a **stranger's answer and a co-founder's answer**. Fire the wow prompt — *"what should I focus on this week?"* — and let the room hear it cite the student's *real* priorities. Context is the fuel; everything above runs on it. **Context is king, not the model** — everyone has the same model.

### C2 · Connections — *give it senses* → a connector (Gmail), not Outlook
Work email (Outlook / M365) is IT-gated — so don't fight it on stage. Use **personal Gmail via the claude.ai connector** as the safe, reproducible stand-in: *Settings → Connectors → Gmail → authorize*. No code, and it works in Claude Desktop / Cowork too, so the non-CLI crowd can replicate it. Ask live: *"what are my 3 most recent unread emails?"* — it reads them.
- **The credibility line:** *"At a regulated workplace, the same pattern runs through approved, governed channels — same shape, different plumbing."* Turn the limitation into a teaching moment.
- **Connection-related skills / doctrine to name:** the rule is **CLI > API > MCP** (token cost + reliability climb in that order). Show `gh` as a live CLI connection; name the public `printing-press` skill (not bundled in this kit) as "how I print a CLI for anything that *doesn't* have a connector." A connector is the click-to-connect **floor**; a printed CLI is the build-anything **ceiling**.
- **Keys, not prompts** (tell the war story): the 150–200k discount-email blast. The fix was never "add a rule" — it was *don't hand it the send key*. Scope every connection minimally; read-only by default. A prompt is never a permission layer.

### C3 · Capabilities — *teach it how YOU work* → `/skill-builder` + the starter set
A capability is *your* way of doing a task, written down so the model stops guessing.
- **Build one live with `/skill-builder`** (Discovery Interview → `SKILL.md`). The reverse-engineer trick (the fast path): do the task once end-to-end, then say *"look back at what we just did and make it a skill."*
- **The starter set worth showing** — all ship in the kit: `/onboard` (C1), `/aios-audit` (grades the four Cs), `/level-up` (find one automation a week), `/grill-me` (get what's in your head into the wiki), `/session-handoff` (clean context switches), plus the **builder family** (`/skill-builder` · `/agent-builder` · `/routines-builder` · `/workflow-builder` · `/hooks-builder` · `/plugin-builder` · `/agents-team-builder`).
- **For our thread**, the capability is *"research today's news on my topic, the way I like it"* — a small skill that produces a tight digest in the student's voice.
- **Every skill use is data:** after each run, say what worked and *"update the skill."* The skill that never gets feedback quietly rots.

### C4 · Cadence — *make it run while the laptop is closed* → show TWO routines
Cadence = Context + Connections + Capabilities, fired on a schedule or event, **unasked**. Show two, so the room sees the full range of what cadence is for:

**Cadence A — the integrative routine (all three lower Cs cooperating, outward-facing):**
> *Daily 7am: research [my topic] → write the digest in my voice → email it to me (or a coworker) via Gmail.*
This is the thread's payoff. Point at each C as it fires: it knows the topic + tone (**Context**), it can reach the inbox (**Connection**), it knows how I like the digest (**Capability**), and now it happens every morning without me (**Cadence**). Build it with `/routines-builder` → a cloud routine. **Hard rule: supervised "Run now" first** — watch one real round-trip before you arm the schedule. Cadence is earned, never free.

**Cadence B — the self-improving loop (the AIOS grading itself, inward-facing):**
> *Weekly Sunday: run `/aios-audit` → score my own four Cs → commit the scoreboard to `references/audits/<date>.md` → file the top-3 fixes.*
This is the loop that makes the OS get better on its own: it reads its own state, grades it, and queues its own homework — a tiny self-improving system. Students leave knowing their AIOS isn't static; it has a heartbeat that keeps raising its own floor. (The loop-engineering doctrine behind cadences like this — how to design a loop and the verify-before-you-arm discipline — lives in `references/agent-loops.md`; the full-strength version is the weekly Improvement loop in `references/autonomous-entity-charter.md` — name it as "where this goes next.")

**Why two:** Cadence A does *outward* work **for** you (research → email = leverage); Cadence B does *inward* work **on the system itself** (audit → improve = compounding). One thread, two directions — that's the whole idea of cadence in two demos.

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

**The demo (2 min).** Run `python3 scripts/entity-scoreboard.py --dry-run` live — the room watches the AIOS count its own capabilities and grade itself. Tie it back to module 9's `/aios-audit`: same idea, now append-only and trend-aware.

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
