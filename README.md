<div align="center">

# 🧠 AIOS Starter Kit

**Build your own personal AI Operating System.**

A clonable template that turns Claude Code into a thought partner that *remembers* — it
knows who you are, compounds knowledge across sessions, and grows new skills over time.

*Un sistema operativo de IA personal. Una plantilla para clonar que convierte a Claude Code
en un compañero de trabajo que **recuerda**.*

</div>

---

## What is an AIOS? / ¿Qué es un AIOS?

A normal AI chat forgets everything when you close it. An **AI Operating System** doesn't.

It's a folder — version-controlled, owned by you — that gives your AI assistant four things
a blank chat never has:

1. **Context** — it knows who you are and what you're working on.
2. **A knowledge wiki** — facts it has learned, written down and reused (not lost in chat history).
3. **Skills** — repeatable workflows you trigger with `/commands`.
4. **A way to grow** — builders that let it create *new* skills, agents, and automations.

You don't program it. You *talk* to it, and it writes itself into a system that gets more
useful every week.

> **Español:** Un chat normal de IA olvida todo cuando lo cierras. Un **Sistema Operativo de
> IA (AIOS)** no. Es una carpeta — con control de versiones, tuya — que le da a tu asistente
> cuatro cosas que un chat en blanco nunca tiene: **contexto** (sabe quién eres),
> una **wiki de conocimiento** (lo que ha aprendido, escrito y reutilizable), **skills**
> (flujos de trabajo que activas con `/comandos`), y una **forma de crecer** (constructores
> que crean nuevas skills, agentes y automatizaciones). No lo programas: hablas con él.

---

## Quickstart / Inicio rápido

You need [Claude Code](https://claude.com/claude-code) installed.

```bash
# 1. Clone the kit  /  Clona el kit
git clone https://github.com/GerardoRdz96/aios-starter-kit.git my-aios
cd my-aios

# 2. (optional) make it your own private repo  /  hazlo tu propio repo privado
rm -rf .git && git init

# 3. Open Claude Code in the folder  /  Abre Claude Code en la carpeta
claude

# 4. Inside Claude Code, run the onboarding wizard  /  Corre el asistente de bienvenida
/onboard
```

`/onboard` interviews you (about 7 short questions), then fills in your context. That's it —
you have a working AIOS. Try asking it: *"what should I focus on this week?"*

> **Español:** Necesitas Claude Code instalado. Clona el kit, ábrelo con `claude`, y corre
> `/onboard`. Te hará unas 7 preguntas y llenará tu contexto. Listo: ya tienes un AIOS
> funcionando. Pregúntale: *"¿en qué me debo enfocar esta semana?"*

---

## What's inside / Qué incluye

```
my-aios/
├── CLAUDE.md            ← the operating system: who your AI is + how it works
├── aios-intake.md       ← the 7-question intake /onboard reads
├── .claude/
│   ├── skills/          ← /commands you run (onboard, audit, level-up, 4 builders)
│   ├── agents/          ← specialized helpers (scribe, warden)
│   └── teams/           ← multi-agent crews you build later
├── context/             ← what your AI knows about YOU (filled by /onboard)
├── references/          ← your knowledge wiki (the AI owns and writes this)
├── knowledge/           ← raw sources you drop in (transcripts, PDFs, notes)
├── artifacts/           ← deliverables your AI builds for you
├── decisions/           ← append-only log of decisions + why
├── routines/            ← scheduled / recurring automations
└── archives/            ← old stuff (move here, don't delete)
```

### The skills it ships with / Las skills incluidas

| Command | What it does |
|---------|--------------|
| `/onboard` | Day-1 setup wizard. ~7 questions → your context files. |
| `/audit` | Health check. Scores your AIOS on the **Four Cs** (Context, Connections, Capabilities, Cadence). |
| `/level-up` | Weekly ritual. Find one thing to automate, scope it, ship it. Runs on the **3Ms** (Mindset, Method, Machine). |
| `/skill-builder` | Build a new skill. |
| `/agent-builder` | Build a new specialized agent. |
| `/routines-builder` | Build a scheduled / recurring automation. |
| `/agents-team-builder` | Design a small team of agents that work in parallel. |

The first three are **rituals** (you run them on a cadence). The last four are **builders** —
this is how your AIOS grows itself.

---

## The big idea: a knowledge wiki that compounds

The most important folder is `references/` — your AIOS's **knowledge wiki**, built on
[Andrej Karpathy's LLM Wiki pattern](https://github.com/karpathy). Three layers:

```
knowledge/      →   references/        →   CLAUDE.md + wiki-protocol.md
(raw sources)       (the wiki the           (the rules that keep
 you drop in)        AI writes & owns)        the wiki disciplined)
```

You drop a source in `knowledge/`. Your AI reads it, discusses it with you, and writes an
*interpreted* page into `references/`. Next session, it reads that page instead of starting
cold. **Knowledge compounds instead of resetting every chat.** The rules live in
`references/wiki-protocol.md`.

> **Español:** La carpeta más importante es `references/` — la **wiki de conocimiento** de
> tu AIOS, basada en el patrón LLM Wiki de Andrej Karpathy. Tú sueltas una fuente en
> `knowledge/`, la IA la lee, la discute contigo, y escribe una página interpretada en
> `references/`. La próxima sesión lee esa página en vez de empezar de cero. **El
> conocimiento se acumula en vez de reiniciarse en cada chat.**

---

## How it grows / Cómo crece

Once you're onboarded, the loop is simple:

- **Run `/audit`** on day 7 and then weekly — it scores your setup and names the top gaps.
- **Run `/level-up`** weekly — it finds one manual thing you keep doing and helps you turn it
  into a skill, an agent, or a routine.
- **Drop sources** into `knowledge/` as you learn — the wiki grows.
- **Build** with the four builder skills whenever you hit a repeating need.

Your AIOS in month three looks nothing like day one — because you grew it.

---

## A note on privacy / Una nota sobre privacidad

This kit ships empty of personal data. Once `/onboard` fills your `context/` files, that
folder is about *you*. If you make your copy public, check `.gitignore` — there are
commented lines to keep `context/`, `knowledge/`, and `decisions/` private. **Never commit
secrets** (`.env` files are already ignored).

---

## Credits / Créditos

- The **knowledge wiki** pattern: [Andrej Karpathy](https://github.com/karpathy)'s LLM Wiki idea.
- The **3Ms framework** (Mindset, Method, Machine): a framework by **Nate Herk**.
- Built on [Claude Code](https://claude.com/claude-code) by Anthropic.

Derived and generalized from a personal AIOS. Shared so you can build your own.

**License:** MIT — see [LICENSE](LICENSE). Use it, fork it, make it yours.
