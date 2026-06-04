# Facilitator Guide — Teaching the AIOS class

*For the instructor. Everything here is yours to adapt. Suggested length: 90 minutes (works
as 60 if you cut the build exercise to a demo).*

---

## The one-sentence thesis

> **An AIOS turns a forgetful chatbot into a partner that knows you, remembers what it
> learns, and grows new skills — and it's just an organized folder you can read.**

If students leave with that sentence and have run `/onboard` once, the class succeeded.

## Materials in this folder

| File | Use it for |
|------|-----------|
| `explainer.html` | Project this. It's your slide deck — scroll top to bottom as you talk. EN/ES toggle, top-right. |
| `exercises.html` | Hand this to students (share the repo, or the file). They check off steps; progress saves locally. |
| `images/` | The illustrations embedded in the explainer (reusable in your own slides). |
| This guide | Your run-of-show. |

Both HTML files are self-contained — open them in any browser, online or off (fonts load
from the web; everything else is inline).

---

## Run of show (90 min)

| Time | Segment | What you do |
|------|---------|-------------|
| 0–10 | **Hook** | Open `explainer.html`. Ask: "How many times have you re-explained yourself to ChatGPT this week?" Land the goldfish metaphor (the *Problem* section). |
| 10–25 | **What an AIOS is** | Walk the *Idea* + *Anatomy* sections. Emphasize: it's just folders + markdown. Open the real `CLAUDE.md` in an editor so they see there's no magic. |
| 25–40 | **The wiki** (the core) | The *Karpathy three-layer* section. This is the deepest idea — go slow. Use the tree image: a few notes today → a canopy later. |
| 40–50 | **Skills / Agents / Routines** | The triage section + the robot trio. Do the quick "which is it?" cases out loud (they're in Exercise 6). |
| 50–60 | **How it grows** | Rituals (onboard/audit/level-up) + builders. The 3Ms and 4Cs. |
| 60–80 | **Hands-on** | Students open `exercises.html` and do Ex 0–4 live. You float and help. (See live-demo below if anyone is stuck.) |
| 80–90 | **Wrap** | Everyone runs the wow prompt: *"what should I focus on this week?"* Share screens. Assign Ex 5–7 as homework. |

---

## Live demo script (your safety net)

Have a **pre-onboarded** copy of the kit ready on your machine (run `/onboard` on yourself
before class). If the room's wifi or installs lag, demo on yours:

1. **Show the cold problem.** Open a plain Claude/ChatGPT, ask "what should I prioritize?" →
   generic answer. "It doesn't know me."
2. **Show the AIOS.** In your onboarded kit, ask the same thing → it cites your real
   priorities. "Same model. Different *operating system* around it."
3. **Show the wiki compounding.** Drop a short transcript into `knowledge/`, ask Sage to file
   it into `references/`, open the new page. "It just learned something permanent."
4. **Show growth.** Run `/audit`, read the score live. "It can even grade itself and tell me
   what to fix."

That four-beat demo *is* the whole class in 5 minutes. Everything else is detail.

---

## Anticipated questions

- **"Is this just custom instructions / a system prompt?"** No — those are one blob of text.
  An AIOS is many files the AI reads *selectively*, plus the ability to *write* new ones
  (the wiki) and *create* new capabilities (the builders). It's a filesystem, not a prompt.
- **"Do I need to code?"** No. You talk to it. The most technical thing is `git clone` and
  typing `claude`. (That's why this class targets a mixed-skill room.)
- **"Does my data go to the cloud?"** The kit is local files. What the AI *reads* goes to the
  model like any chat. Keep secrets in a gitignored `.env`; don't commit private `context/`
  if you make your repo public (the `.gitignore` has the lines ready).
- **"Why Claude Code and not X?"** The *pattern* is portable — any agent that can read/write
  files in a folder works. This kit ships Claude Code skills because that's the substrate.

## Credits to name out loud

- The **knowledge-wiki pattern** is **Andrej Karpathy's** LLM Wiki idea.
- The **3Ms** (Mindset, Method, Machine) is **Nate Herk's** framework.
- Built on **Claude Code** by Anthropic.

Naming your sources models good practice for students — and it's the honest thing to do.

---

## If you only have 60 minutes

Cut the live build (segment 60–80) down to *you* demoing Ex 1–2 while they watch, and assign
all exercises as homework. Keep the wow prompt at the end no matter what — it's the moment
that converts.
