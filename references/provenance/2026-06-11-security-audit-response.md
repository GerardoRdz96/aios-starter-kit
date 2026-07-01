# Provenance — security audit response (external report → kit v2.2)

- **What:** response to an external security review of kit v2.1 (8 findings, V1–V8). Headline: no leaked secrets, no vulnerable traditional code; the gaps are agentic-architecture — ingestion has no trust boundary, the lethal trifecta is assembled by design, and rails live in prose.
- **Why:** report provided by an external reviewer, 2026-06-11; every finding verified against the repo before acting.
- **Builder:** the kit's AIOS (a Claude Code session, 2026-06-11), fixes implemented surgically per the report's own priority call.
- **Response map:**

| Finding | Action |
|---|---|
| V1 🔴 ingestion prompt injection | Trust-boundary section in `references/wiki-protocol.md` (inert data, quarantine protocol, scan extension); data-not-instructions constraints in `scribe.md` + `warden.md`; ingestion discipline added to charter §6 |
| V2 🔴 lethal trifecta | Threat model + break-one-leg posture in new `SECURITY.md`; smallest-context rule in wiki-protocol; routine egress rule (V6) |
| V3 🟠 prose rails | **`scripts/rails-guard.sh`** (sha256 frozen manifest, fail-closed, pre-commit/pre-push installable) + `.github/workflows/rails.yml` CI; charter §7 item 1 marked SHIPPED |
| V4 🟡 gitignore opt-in | Privacy ignores now ON by default (context/knowledge/decisions/artifacts, README exceptions); pre-push personal-content gate in rails-guard; README quickstart step 3 |
| V5 🟡 fail-open hooks | hooks-builder reference: guard skeletons fail-closed by DEFAULT; arm hooks in gitignored `settings.local.json` |
| V6 🟡 unattended routines | routines-builder security checklist: ingesting routines = draft-only, minimal egress, tokens only in cloud env vars, branch protection on main |
| V7 🟡 third-party skills + auto-memory | power-skills supply-chain discipline: scan-before-install, pin/snapshot versions, auto-injected memory = untrusted input |
| V8 🟢 no SECURITY.md | `SECURITY.md` added (threat model, enforced-vs-prose table, disclosure path) |

- **Validator verdict:** guard script tested 7 scenarios locally (freeze/check OK, tamper → exit 2, staged-frozen block, privacy block, ALLOW_PERSONAL_PUSH override, README exceptions, restore OK).
- **Open (not closed by this patch):** section-level CLAUDE.md content guard (§7 item 2), validator-as-gate in builders (§7 item 3), wiki lint in CI.
- **Armed-by:** guards are install-on-clone (`scripts/rails-guard.sh install`) — the human arms them, per "the AI builds, you arm". CI arms automatically on push to GitHub.
