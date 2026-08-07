# Routines Builder Reference

Technical reference for Claude Code **Routines** and the other cadence mechanisms, plus the `/schedule` skill. Routines are a **research preview** — limits and surface may change; re-check the official docs.

Source: https://code.claude.com/docs (Claude Code on the web / Routines)

---

## What a Routine Is

A saved Claude Code task that runs on **Anthropic's cloud**, even with your laptop closed. Configure a prompt once; it fires on a schedule, an API call, or a GitHub event. Available on Pro/Max/Team/Enterprise with Claude Code on the web enabled.

- A routine = **prompt + GitHub repo(s) + triggers + connectors**.
- Each run **clones the repo fresh** in an isolated cloud env, works, then **destroys the env**.
- Changes push to a **`claude/`-prefixed branch**; every run creates a **claude.ai session** to review.
- **Actions happen AS you** — commits carry your GitHub user; connector posts use your accounts.
- The fresh clone **reads `CLAUDE.md` automatically** every run.

**Mental model:** a contractor who clones your repo, works on a `claude/` branch, pushes, and leaves — you review and decide what to merge.

---

## The 3 Trigger Types

| Trigger | Fires on | Example |
|---|---|---|
| **Schedule** | cron presets or natural language; **min interval 1 hour** | "Every weeknight 9pm, triage new issues" |
| **API** | POST to a dedicated endpoint with a bearer token | "Alert webhook → diagnose, open fix PR" |
| **GitHub** | repo events (18+: PRs, pushes, issues, releases, check/workflow runs, discussions, merge queue) | "On every new PR, run my review checklist" |

Triggers combine on one routine (nightly **and** on every PR). PR filters: author, title, body, base/head branch, labels, draft, merged, from-fork.

---

## Setup Fields

Name · **Prompt (this IS the routine)** · Model · Repository · Cloud environment · Cadence · Connectors · Permissions (**fully autonomous — no permission prompts**).

---

## Environments — the big gotcha

The fresh clone has **no `.env`** (it's `.gitignored`). Configure at claude.ai **before** creating the routine:

- **Environment variables** — non-secret configuration only. Anthropic's documentation says
  these values are readable by anyone using the environment and that it is not a secrets
  store, so **credentials do not belong here**. For anything secret, prefer an official
  connector, the scoped GitHub access the product provides, or a real secret manager the
  run can call.
- **Network access** — what the run can reach (below).
- **Setup script** — install commands before each session (`npm install`, `pip install`).

**The `.env` trap:** scripts that read keys from `.env` fail in a routine. Fix: tell the prompt *"the API key is an environment variable — use it directly, don't look for a `.env`"*, and have scripts read `os.environ["KEY"]`. **Never commit `.env`** to "solve" this — history persists and exposes collaborators.

### Network access modes
- **Trusted (default)** — whitelist: GitHub, Anthropic, configured connectors only.
- **Full** — any outbound request. Needed for external APIs. Trusted blocks these.
- **None** — no network. **Custom** — specific domains.
- **Risk of Full:** if the run reads malicious content (crafted PR, bad dependency) it could be tricked into exfiltrating data; Trusted would block the outbound call. Low risk for private repos with controlled inputs; matters most with untrusted input (public PRs).

---

## Connectors (not local MCP)

Routines **can't use local MCP servers** — they use **Connectors**, Anthropic's cloud-managed integrations: **Slack, Linear, Jira, Google Drive, GitHub (built-in)**. Each authenticates as you. For a notification, a Slack connector beats a custom API call.

---

## What Won't Work

- **Persistent browser sessions** (Playwright/Puppeteer needing login cookies) — env destroyed each run. Workaround: hit an API endpoint with header auth.
- **Local-only services** — no localhost DBs/APIs.
- **Resource-heavy work** — each run gets **4 vCPU / 16 GB RAM / 30 GB disk**; exceed memory → killed.
- **Stateful workflows** — nothing carries between runs (workaround: leave a memory trail in a committed log/doc).
- **Rule of thumb:** if it's local, or unreachable via a GitHub repo or an API, it won't work.
- **Exception:** codebase changes/reviews persist via the `claude/` branch and session output.

---

## Limits & Cost

- **Daily run cap:** Pro 5 · Max 15 · Team 25 · Enterprise 25 (metered overage if enabled).
- **Min schedule interval: 1 hour.** Per-run resources as above.
- **Tokens draw from your normal subscription usage** — complex routines burn fast.

---

## Security Checklist

- Routines push only to `claude/`-prefixed branches by default — don't enable unrestricted pushes unless required. Pair with **branch protection on `main`** so a routine can never land unreviewed changes server-side.
- Each routine has its own **bearer token**, shown once; regenerate/revoke anytime. A leaked token lets someone spam runs and burn your daily cap — revoke immediately. Never paste tokens into routine prompts or repo files — they live in the cloud environment's env vars only.
- **Everything runs as you** — test thoroughly before connecting comms tools (a 3am garbage Slack post carries your name).
- **Unattended + external content = read-only/draft-only.** A routine that ingests external content (feeds, web, transcripts) runs unattended — nobody is there to catch a prompt injection. Such routines may DRAFT wiki pages/PRs but never directly edit config, hooks, skills, or scripts; and keep their tool/egress surface to the minimum the job needs (no open-ended network if the job is summarize-and-file). See `SECURITY.md` (lethal trifecta).
- **Cloud routines bypass your local `rails-guard.sh` privacy gate.** That pre-push guard (over `context/`/`knowledge/`/`decisions/`/`artifacts/`) is a git hook on *your* machine — a routine pushes from Anthropic's cloud, so it never fires. Don't lean on it to stop a routine leaking personal dirs: keep those *out of the routine's repo scope*, and rely on **branch protection on `main`** as the server-side backstop.

---

## Writing Good Routine Prompts

One-shot — you're not there to answer questions. Be specific ("scan `src/tests/` for tests that failed in the last 5 CI runs, find root cause, open a fix PR each" not "fix flaky tests") · name files/dirs · state what success looks like · set boundaries ("only modify `src/utils/`, don't touch the API layer") · include output format ("push to `claude/...`, open a draft PR with a summary") · say what to do on failure ("if X fails, log and stop"). Put **stable** rules in `CLAUDE.md`, **run-specific** ones in the prompt.

---

## Pre-flight Checklist (the hard gate before arming)

1. **"Run now"** and watch the session live.
2. Verify API keys are in cloud env vars (not `.env`).
3. Confirm network mode (Trusted vs Full).
4. Tell the prompt where to find env vars.
5. Tell the prompt what to do when it hits a wall.
6. Confirm `CLAUDE.md` isn't dragging in irrelevant context.
7. Test the **failure path**, not just the happy path — no automatic retries, so build a fallback into the prompt.

---

## Why Routines Beat n8n/Zapier/cron

A fixed pipeline dies at the first failed step. A routine injects your prompt into a **full Claude Code agentic loop**: it **self-corrects** on errors and does **context-aware problem solving** (reads codebase, test output, adapts). A plain cloud script keeps the Workflow and Tools but loses the **Agent** — routines keep all three.

---

## Mechanism Comparison (cadence)

| | Cloud Routine | Hook | `/loop` | Ritual skill |
|---|---|---|---|---|
| Runs on | Anthropic cloud | your machine | your machine | your machine |
| Machine on? | No | Yes (at event) | Yes | Yes |
| Open session? | No | No | Yes | Yes (you trigger) |
| Local file access | No (fresh clone) | Yes | Yes | Yes |
| Min interval | 1 hour | event-driven | 1 min | manual |
| Permission prompts | None (autonomous) | n/a | inherits session | inherits session |
| `/aios-audit` counts it? | Yes (documented) | Yes (hooks key) | — | Yes (`daily-*`/`weekly-*` name) |

Desktop scheduled tasks do **not** migrate to routines — recreate manually.

---

## How to Create One Here

- **Terminal path = the `/schedule` skill** (manages scheduled remote agents = routines). routines-builder delegates creation/arming to it rather than reimplementing.
- **Environment setup (env vars, network mode, setup script) is a claude.ai web action** — not scriptable from the CLI. Flag these as manual steps for the user and pause until confirmed.
- Local cadence alternatives: `/hooks-builder` for `.claude/settings.json` hooks; `/loop` for in-session polling; `/skill-builder` for a `weekly-*` ritual skill.

---

## Notes

- **Your AIOS can run itself**: if it's a private GitHub repo, a routine can run weekly rituals (`/aios-audit`, decisions housekeeping) and land them as a reviewable `claude/` branch + PR.
- **Local-tool caveat:** no local MCP means tools without an API or a cloud Connector won't ride along. External APIs need **Full** network.
- **Everything posts as you** — branch/draft output (or a per-run human gate) is the permanent rule for any send/post/delete/pay/deploy; test before wiring Slack/comms.

---

## Related Documentation

- **`/schedule` skill** (create/list/run scheduled remote agents)
- **Hooks:** https://code.claude.com/docs/en/hooks
- **Routines / Claude Code on the web:** https://code.claude.com/docs
