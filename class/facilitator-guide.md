# Facilitator Guide v2 — Teaching the AIOS class

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
| 6 | 60–70 | **Power skills** | What each does + when: Superpowers (bug-cost dominates), GSD (context-rot dominates), route-by-risk doctrine, `/review` closer, Frontend Design. The 70%→92% self-verify rule. Show the install commands (`references/power-skills.md`). |
| 7 | 70–80 | **Multi-brain** | Many models, one driver. Cloud CLIs + local models (Ollama) on one roster the *student* defines. The **No-Self-Review Law**: same architecture = same blind spots — reviews go to a different lineage. Demo if you have two CLIs installed. |
| 8 | 80–90 | **The LLM wiki (vs RAG)** | The Karpathy three-layer pattern — go slow, this is the deepest idea. Then the RAG comparison table (`references/llm-wiki-pattern.md`): interpretation at *ingest* time vs query time; human-readable vs opaque; zero infra. Honest trade-off: RAG wins at millions of docs; you don't have millions of docs. |
| 9 | 90–100 | **The growth rituals** | `/onboard` (day 1) → `/audit` (day 7, then weekly — show a real score) → `/level-up` (weekly, one automation) → `/grill-me` (when knowledge is in your head) → `/session-handoff` (every wrap-up). Then the builders + the Skill-vs-Agent-vs-Routine triage. |
| 10 | 100–120 | **Hands-on + wrap** | Students run exercises 0–4 live; you float. Everyone fires the wow prompt: *"what should I focus on this week?"* Share screens. Assign the rest as homework. |

---

## The 4-beat live demo (your safety net — this IS the class in 5 minutes)

Have a **pre-onboarded** copy of the kit ready on your machine.

1. **Cold problem.** Plain chat: "what should I prioritize?" → generic. "It doesn't know me."
2. **The AIOS.** Same question in your kit → it cites your real priorities. "Same model. Different *operating system* around it."
3. **Compounding.** Drop a short transcript in `knowledge/`, have it filed into `references/`, open the new page. "It just learned something permanent."
4. **Growth.** Run `/audit`, read the score live. "It grades itself and tells me what to fix."

---

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

- **90 min:** keep all 10 modules; cut module 10 to a 10-minute demo of exercises 1–2; assign the rest as homework.
- **60 min:** modules 0–5 + the wow prompt. Hand out the study guide; modules 6–9 become a part-2 session (they stand alone well).
