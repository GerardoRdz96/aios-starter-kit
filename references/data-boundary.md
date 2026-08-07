# The data boundary — run two systems, not one

**The habit:** keep **one AIOS for sensitive work** and **one for everything else**. Separate
folders, separate connections, separate models.

**What it is:** defense in depth. Two folders make the safe path the default one and remove a
decision you would otherwise make dozens of times a week.

**What it is not:** isolation. Two directories under the same OS user are not a security
boundary. Either system can read the other's files, and both inherit the same shell
environment, keychain entries, CLI logins, MCP servers, plugins, model configuration,
transcripts and cross-session memory. Real separation needs a separate OS profile, a VM, a
managed device, or an environment your employer or client provides.

Treat this page as **hygiene that reduces the chance of a mistake**, and treat your
organization's policy as the thing that actually decides what you may process.

---

## Before any of this: authorization

**This template does not authorize you to process anything.** Before employer or client
material touches any AI tool, you need approval for the specific combination: the product,
the enterprise tenant, the account, the deployment, the model, the connectors, the retention
policy and the data classification. Some engagements prohibit local processing entirely.

If you cannot name who approved it, that is your answer. Ask your security or privacy owner.

---

## Why two, instead of one careful system

A single system plus a rule ("I will be careful with client data") depends on remembering,
every time, forever. Two systems make the low-risk path the one you are already standing in,
and a connection you never wired into the personal system is one less way to get it wrong.

That is a meaningful reduction in exposure. It is not a guarantee, and you should not describe
it to anyone as one.

---

## What goes where

| | **Work AIOS** | **General AIOS** |
|---|---|---|
| **Holds** | Employer information, client data, customer code and IP, anything under an NDA or an internal classification | Your own projects, learning, personal work, public information |
| **Models** | Only the ones your organization approves and provides | Whatever you like |
| **Connections** | Only approved, organization-managed tools | Anything you choose to wire |
| **Remote** | Only an approved remote in the correct tenant, if any | Your call |
| **Autonomy** | Conservative. Human review on anything that leaves the machine | Your call |

**Separate personal from work is the floor, not the ceiling.** If you serve more than one
client, one "work" folder can quietly commingle them, and different engagements often carry
different contractual controls, tenants, approved tools, residency rules and access lists.
Split per client or per engagement whenever policy or contract asks for it.

---

## Setting up the work one

It is the same template, but do **not** leave it pointed at the public repository.

```bash
git clone https://github.com/GerardoRdz96/aios-starter-kit ~/aios-work
cd ~/aios-work
git remote remove origin          # before ANY work material goes in
```

Then add an organization-approved remote in the correct tenant, or no remote at all. "A
remote I control" is the wrong test: your own private repository can still be prohibited.

Then, before anything else:

1. **Disable what is not approved, before the first launch.** `.claude/settings.json` in this
   kit pre-wires a plugin stack including cross-session memory and several third-party model
   routes. Remove every entry your organization has not approved *before* you open the folder
   and accept the install prompt.
2. **Write the restriction into `CLAUDE.md`**, at the top, in the imperative. Be clear with
   yourself about what this is: a **reminder that loads every session**, not an enforcement
   mechanism. This kit teaches that instructions are not a permission layer, and that applies
   here too. The enforcement is step 1, plus not having the credentials at all.
3. **Answer `/onboard` with this context** in the identity and purpose questions, so the
   scaffolded files say what this system is for. Note that `/onboard` does not currently ask
   about model or data restrictions, so the hard rule in step 2 is something you add by hand.
4. **Gitignore aggressively**, and know its limits. `.gitignore` keeps new files out of
   ordinary tracking. It does not untrack files Git already knows about, does not encrypt
   anything, and does nothing about a home directory syncing to iCloud or OneDrive, or about
   transcripts, caches, indexes, temp files and backups.
5. **Wire connections one at a time**, approved ones only, read-only first
   (`/printing-press` walks that).

---

## The failure mode this reduces

The dangerous case is not the obvious one. What actually happens is quieter: you are debugging
something for work in your personal system because it was already open, the wiki writes a page
about it because that is what the wiki does, and weeks later that page is context in a session
you have forgotten about, on a model your organization never approved.

Every step there was reasonable. Having a separate folder, with different tools in it, makes
the first step less likely and easier to notice.

---

## The question to ask

Not "whose information is this?" That one mishandles public third-party data, and it
mishandles your own sensitive health, financial and credential data.

Ask instead: **am I authorized to process this exact data, for this purpose, on this device,
in this account and tenant, with this tool?**

If you are not sure, stop and ask the person who owns that answer.

**Related:** [[four-cs-framework]] (Connections is where reach and risk both live) ·
[[autonomous-entity-charter]] (what an autonomous system is allowed to do) ·
`/printing-press` (wiring a connection into the right system)
