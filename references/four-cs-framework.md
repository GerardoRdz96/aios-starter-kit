# The Four Cs of an AIOS — Context, Connections, Capabilities, Cadence

The architecture for building an AI operating system: four layers, each depending on the one before — Context → Connections → Capabilities → Cadence. This is the framework `/audit` scores against, and the companion to the [Three Ms](3ms-framework.md). The 3Ms is *how to think about and build automations* (platform-agnostic); the Four Cs is *how to architect and run an AIOS*.

> **The Four Cs is a framework by Nate Herk.** This page is a concise, interpreted digest for use inside the AIOS. For the full version, see Nate Herk's own content.
>
> *The Four Cs of an AIOS™ is a trademark of Nate Herk. © 2026 Nate Herk.*

## The one-line test for each layer

| C | The question it answers | "It's working" looks like |
|---|---|---|
| **Context** | Does it know your business? | Fresh session: "what does this business do and who works here?" → it answers. |
| **Connections** | What can it actually touch? | "What's on my calendar tomorrow? What did John message yesterday?" → it sees it, no copy-paste. |
| **Capabilities** | How do *you* do the work? | It writes in your style, with your frameworks — not generic. |
| **Cadence** | Does it run while your laptop is closed? | Things happen on a schedule or event without you asking. |

**Each layer can't exist without the previous one.** No real Capabilities without Connections to act on; no Cadence without all three beneath it. Build bottom-up.

**The two-layer split:** the first two Cs *are* the second brain (Context + Connections = does it know your world and can it reach live data); the last two are the AIOS proper (Capabilities + Cadence = can it do work and run unattended). You can't have an AIOS without a second brain underneath. The gut check for the second-brain half: ask a fresh session about you and your work — do you get a **stranger's answer or a co-founder's answer?**

**An OS doesn't start with architecture. It starts with a default.** The first move isn't folder design — it's closing the other AI tabs and routing everything through one harness, so context and memory compound in one place.

## The four layers

### 1. Context — *does it know your business?*
The bedrock. Fed by everything: meeting transcripts, posts, video/LinkedIn transcripts, Slack/project threads, email. Done well, the OS recalls your own business faster than you can. **Context is king, not the model** — everyone has the same models, so generic fuel gives generic output; your context is the differentiator. Models are stateless: each session reloads global rules + `CLAUDE.md` + memory/skill files, or it's a beginner again.

**CLAUDE.md is a router, not a manual.** It points the agent at where rules, references, skills, and projects *live*; the content lives in those files. (This kit encodes that as the CLAUDE.md budget protocol.)

**"Architecture engineering" — the pulse check.** Organizing the file system is its own craft. The two-question test: *could I manually drill through the folders and find what I need? Can the agent find it just as fast?* If the agent searches 5 minutes for a file you could locate instantly, the architecture — not the model — is the bug. Amount of context is rarely the problem; findability is.
*Where it lives:* `context/`, the `references/` wiki, `memory/`, the `CLAUDE.md` files.

### 2. Connections — *what can it actually touch?*
Built by wiring APIs / CLIs / MCPs one at a time. **The tier-1 heuristic for what to connect:** audit yourself — what apps would you open in a normal week? What bookmarks are always there? Where do you go to talk to people? That's your tier-1 list; wire those first. Seven solid starters: revenue figures, customer data/communication, calendar, internal communication, tasks/project management, meetings, knowledge. Static data (your background, old transcripts) is Context; *constantly-changing* data is what earns a Connection.

**The risk lives in this layer.** More connections = more reach = more risk *and* cost.
- **Assume that if an agent *can* do something, it *will*.** Design as if it will.
- **Instructions ≠ capabilities — keys, not prompts.** "Never send emails" (an instruction) is far weaker than simply *not putting the send-email key on the keyring* (a capability). If the tool is in the harness, it can physically fire — no instruction reliably stops it. Real war story: an agent on Nate Herk's team picked up a to-do, interpreted it as "send these emails," and blasted a never-meant-to-ship discount code to ~150–200k inboxes. Nobody told it to send anything. The fix isn't a rule — it's not granting the capability: scoped keys (e.g. read-only), minimal reach. A prompt is never a permission layer. And when it slips: it's data, not failure — fix the key scope, write the case study, it never happens again. (This sharpens the [3Ms Intern Rule](3ms-framework.md).)
*Where it lives:* `connections.md`, CLI-first wiring (CLI > API > MCP).

### 3. Capabilities — *how do you do the work?*
Skills and instruction files that encode *how you* work — your style, your frameworks, your steps. That's true capability, vs. a model guessing.

**Two ways to build a skill:** *forward* — spot something you do on a cadence, build it with a skill-creator, iterate; or *reverse-engineer* — do the task once, then have the AI look back at the conversation (what tools, what steps, what produced the good output) and build the skill from that. A skill doesn't have to be a big SOP — if you keep retyping the same prompt, that's a skill (the kit's `/session-handoff` is exactly that).

**Every skill use is data — the update-the-skill ritual.** A skill is never finished: preferences drift, models change, endpoints move. After every run, say what worked and what didn't, then "update the skill." The skill that never receives feedback is the skill that quietly rots.
*Where it lives:* `.claude/skills/` and `.claude/agents/`. The [Bike Method](3ms-framework.md) governs how much trust a maturing skill earns.

### 4. Cadence — *does it run while your laptop is closed?*
The top layer: turning Context + Connections + Capabilities into things that happen on a schedule or event, unasked. Needs all three layers beneath it. **Phase trust up the Bike Method before arming anything autonomous** — and given the Connections risk, scope what a cadence can touch.

**A cadence that *iterates* is a loop** — it needs **both brakes** (an objective done-check, *not* iterate-until-done, **and** a numeric cap) plus a correctness check (functional > visual > different-lineage judgment > human-gate; route any irreversible step to a human gate or branch-only). Before arming any schedule/hook, a supervised Run-now must pass. (Loop-engineering doctrine: [[agent-loops]].)

**Cadence is earned, and it's never free:** as autonomy goes up, cost, risk, *and maintenance* go up together. Deployed ≠ done — every automation still needs an owner, visibility, and a does-it-move-the-needle check.
*Where it lives:* cloud routines (the only kind that truly run *while your laptop is closed*), plus local hooks, `/loop`, and ritual skills — these last are session/local-bound, so they only fire while the session or machine is up, not while it's asleep.

## How `/audit` scores it

`/audit` scores **each C out of 25 points, for 100 total**, then returns a scoreboard plus the top-3 leverage fixes ranked by impact. Roughly:

- **Context (25):** depth and freshness of `context/`, the wiki, and `CLAUDE.md`. Can a fresh session answer "what does this business do and who works here?"
- **Connections (25):** how many of your real week-to-week systems the AIOS can actually reach (vs. copy-paste), and whether keys are scoped safely.
- **Capabilities (25):** how much of *your* work is encoded as skills/agents that produce your-style output, vs. generic prompting.
- **Cadence (25):** how much runs on a schedule/event without you asking, and whether autonomy was phased up safely.

Run `/audit` early (e.g. Day 7) and then weekly to watch each layer climb. The score isn't the point — the ranked fixes are.

**Sources:** Framework by Nate Herk — see his public content for the full version. This page is an interpreted digest.
**Related:** [[3ms-framework]], [[power-skills]], [[wiki-protocol]], [[agent-loops]] · builder skills for the Cadence layer: `/routines-builder`, `/hooks-builder`
