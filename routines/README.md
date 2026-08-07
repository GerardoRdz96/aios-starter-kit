# routines/

Definitions for **recurring, unattended automations** — work that runs on a schedule or an
event without you starting it. A daily news scan, a weekly audit, a "watch this repo" job.

Build one with `/routines-builder`, which first decides the right mechanism (a scheduled
cloud routine, a hook, a `/loop`, or a ritual skill) and then walks a supervised test before
arming it — because routines run on their own, you want to see one run before trusting it.

Each routine lives as its own `<name>.md` here, describing what it does, when it fires, and
what it produces. None ship pre-built — they're personal by nature.

> Routines run **as you**, with your access. Scope their tools tightly and never hard-code
> secrets — use environment variables.

## The two kinds, and how to choose

There are two places a routine can run, and picking the wrong one is a common reason a
routine that "should work" never fires. The cloud option here means **Claude Code Routines**,
which is still a research preview, so check the
[current documentation](https://code.claude.com/docs/en/routines) before you rely on any
detail below.

| | **Local** (launchd, cron, a hook on your machine) | **Cloud** (Claude Code Routines) |
|---|---|---|
| **Needs** | Your computer powered on and awake | Your laptop can be closed, but you still need an eligible plan, Claude Code on the web enabled, a configured environment and repo access |
| **Runs on** | Your machine, as your user account | Managed infrastructure, in an isolated VM per run |
| **Can reach** | Your files, your CLIs, your desktop apps, your local models | One or more Git repos cloned fresh, selected connectors, and whatever network access you allow |
| **Delivers by** | Acting directly on your machine | Every run creates a session you can review; a branch appears only when the run actually changes a repo |
| **Minimum interval** | Depends on the mechanism you use | Exactly one hour |
| **Leaves behind** | Whatever you wrote to disk | The VM goes away, but setup snapshots are cached for about a week and session records follow your account's retention. Do not assume a run vanishes |

**Secrets, and this part matters.** The fresh clone has no `.env`, so a script that reads one
fails in the cloud. The fix is **not** to paste API keys into the environment's variables:
Anthropic's own documentation says those values are readable by anyone using that environment
and that it is not a secrets store, so credentials do not belong there. Prefer an official
connector, the scoped GitHub access the product provides, or a real secret manager the run
can call. Reserve environment variables for non-secret configuration.

**The choosing question is one line: does the work touch your machine?**

- Touches local files, local apps, local models, or your desktop → **local**.
- Only touches a repo and the internet → **cloud**, and you get to close the laptop.

A worked example of each: a routine that generates a video with a model installed on your
laptop has to be local, because the model is there. A routine that reviews new commits and
opens a pull request should be cloud, because nothing about that job needs your hardware and
you do not want it skipped on the days your machine is off.

**The trap in the cloud case** is the `.env` one. `.env` is gitignored, so the fresh clone
does not have it, and any script that reads a key from a file fails in a way that looks like
the routine is broken rather than like a missing credential. Say so explicitly in the routine
prompt: *"do not look for a `.env` file."* Then give the run a credential the proper way, per
the note above, rather than pasting a key into an environment variable and hoping.
