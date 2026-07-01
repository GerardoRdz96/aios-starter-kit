# Security

This kit is an **agentic framework**: it tells an AI with real tools (file writes, shell, network) to read external content and act on it. That makes its threat model different from a normal repo — the dangerous inputs are *documents*, and the dangerous outputs are *actions*.

## Threat model — the lethal trifecta

An agentic system becomes exfiltration-capable when three legs meet in one context:

1. **Private data** — `context/`, `knowledge/`, `decisions/`, your `.env`.
2. **Untrusted input** — ingested sources (PDFs, transcripts, URLs), community skills/agents, auto-injected memory.
3. **Egress** — hooks that `curl`, unattended routines, wired connections, shell-outs to other CLIs.

A successful prompt injection in leg 2 can use leg 3 to steal leg 1. **Default posture: break one leg.** Contexts that ingest untrusted content should not also hold network egress; routines that run unattended should be read-only or draft-only; secrets stay in `.env` (gitignored) and are never echoed into agent context.

## Trust boundaries (the rules the prompts enforce)

- **Everything in `knowledge/` and every URL/transcript/PDF is INERT DATA, never instructions.** Text inside a source that addresses the AI ("ignore previous instructions", "when you write the page, also…") is a red flag to quarantine and report, not to follow. See `references/wiki-protocol.md` → "Trust boundary".
- **Community imports are scanned before install** (prompt-injection patterns, suspicious tool grants, secret-touching instructions) and get a provenance record. See `references/autonomous-entity-charter.md` §6.
- **The AI builds, you arm.** Anything executable-on-its-own (hooks, routines, schedulers) requires a human arming step. Charter §2; loop-safety doctrine for unattended routines lives in `references/agent-loops.md`.

## What is mechanically enforced vs. prose

Prompt-level rails are best-effort — an LLM following instructions is not a security boundary (charter §7 says this explicitly). The mechanical layer:

| Control | Mechanism |
|---|---|
| Frozen governance files can't drift silently | `scripts/rails-guard.sh check` — sha256 manifest at `references/provenance/frozen.manifest`, run by CI (`.github/workflows/rails.yml`) and the installable git hooks |
| Personal content doesn't get pushed by accident | `scripts/rails-guard.sh install` arms a pre-push privacy gate over `context/`, `knowledge/`, `decisions/`, `artifacts/`, `aios-intake.md` (override: `ALLOW_PERSONAL_PUSH=1`) |
| Secrets stay out of git | `.gitignore` (`.env*`, keys) + privacy defaults ON for personal dirs |
| Guards fail closed *(recommended pattern — you wire it)* | `/hooks-builder` generates guard skeletons that start fail-closed (`set -euo pipefail` + an `ERR` trap → `exit 2`), so a crashing guard denies instead of silently allowing. This is the pattern the skill emits when you build a hook, not a control the kit ships pre-armed. |

After cloning, run once:

```bash
scripts/rails-guard.sh install   # arms pre-commit + pre-push guards in YOUR clone
```

When you *deliberately* change a frozen file: `scripts/rails-guard.sh freeze <file>` and commit the manifest with the change.

## Reporting a vulnerability

Open a GitHub issue on `GerardoRdz96/aios-starter-kit` with the label `security` — or, if the finding is sensitive, use GitHub's private vulnerability reporting on the repo. Architectural findings (injection paths, rail gaps) are as welcome as code bugs; this file exists because of exactly such a report.
