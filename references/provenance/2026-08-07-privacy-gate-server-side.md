# Provenance: privacy gate — server-side enforcement + placeholder baseline

- **What:** security fix across `.github/workflows/rails.yml` (privacy gate added to CI for
  push + pull_request), `scripts/rails-guard.sh` (new `privacy-range` and `baseline`
  subcommands, placeholder-aware `cmd_privacy`, non-clobbering `install`),
  `references/provenance/template-baseline.manifest` (new), plus honesty corrections in
  `SECURITY.md`, `README.md` (EN + ES) and `.claude/skills/routines-builder/reference.md`.
- **Type/Tier:** hardening of an existing Tier-S control · charter §7 ("keys, not prompts")
- **Why:** the privacy gate was **advisory in practice**. It existed, it was correct, and
  nothing ran it. `.github/workflows/rails.yml` invoked only `rails-guard.sh check`, never
  `privacy`; the pre-push hook that does run it is opt-in per clone and was not installed in
  the maintainer's own clone. So the control that keeps `context/`, `knowledge/`,
  `decisions/`, `artifacts/` and `aios-intake.md` off a public remote had **zero enforcement
  points active**, while `references/provenance/2026-06-11-security-audit-response.md` stated
  "CI arms automatically on push to GitHub" — true of the frozen-file check, not of this one.
- **Source:** self-built. Found while auditing a v2.3 release claim, not by an external report.
- **Builder:** direct edit, then adversarial self-testing (below).

## The design problem worth recording

A naive fix (run `privacy` in CI over the full history) **fails on this repository**, because
the template legitimately ships six placeholder files inside personal paths: `aios-intake.md`,
`aios-intake.md.template`, `context/about-me.md`, `context/about-work.md`,
`context/priorities.md`, `decisions/log.md`. A first push from the quickstart path
(`rm -rf .git && git init`) has no base commit, so the scan widens to full history and flags
all six — on a clone where the user has changed nothing.

That false positive is not cosmetic. A gate that fires on the happy path teaches people to
set `ALLOW_PERSONAL_PUSH=1` permanently, which disables it forever. **The fix is to make the
gate content-aware rather than path-aware:** `template-baseline.manifest` records the sha256
of each shipped placeholder, and a file whose content at the pushed tip still matches its
baseline is not personal content. The moment `/onboard` writes your facts into it, the hash
changes and the gate fires. A file that is absent at the tip is deliberately **not** treated
as pristine, so "added personal data, deleted it, then pushed" is still caught.

- **Reviewer verdict:** **NOT OBTAINED — cross-lineage review unavailable.** The No-Self-Review
  route (Codex) was hard-blocked by a provider usage limit for the whole work window;
  a direct probe returned "You've hit your usage limit... try again at 10:27 PM". This is a
  blocked route, recorded as such, not a skipped gate. **Owed:** a Codex adversarial pass over
  `scripts/rails-guard.sh` and `.github/workflows/rails.yml`, specifically hunting for a way
  to get personal content past the gate.
- **Validator verdict:** N/A — no third-party material imported.

## Test evidence — the gate was proven to BLOCK, not assumed to

Executed against a throwaway local bare remote (never `origin`), so a failure to block could
not expose anything. All test commits and the branch were deleted afterwards;
`context/about-me.md` was verified byte-identical to its baseline hash after cleanup.

| Case | Expected | Result |
|---|---|---|
| Incremental range, clean commits | pass | `exit 0` |
| Branch deletion (`after` = zeros) | pass, no scan | `exit 0` |
| Full history, pristine placeholders | pass | `exit 0` — "6 unmodified template placeholder(s) allowed" |
| Force-push sim (`before` unresolvable) | widen to full history | `exit 0`, scan widened |
| Unresolvable tip | **fail closed** | `exit 2` |
| **Real `git push` of a filled-in `context/about-me.md`** | **blocked** | **`exit 1`, remote received nothing** |
| CI push path over the same commit | blocked | `exit 2` |
| CI first-push path over the same commit | blocked | `exit 2` |
| Personal file added **then deleted** before push | blocked | `exit 2` |
| `install` over a foreign (husky-style) hook | refuse | `exit 2`, hook preserved |
| `install` re-run over its own hook | idempotent | `exit 0` |

- **Armed-by:** hooks armed in the maintainer's clone 2026-08-07 (`rails-guard.sh install`);
  CI enforcement ships with this commit and arms itself on push.
- **Post-ship verification:** **DONE.** CI run `31195386533` on commit `d224005` executed the
  step "Personal-content privacy gate (push)" with `BEFORE=51e1c27 AFTER=d224005` and returned
  `rails-guard: privacy gate OK`. The step ran; it was not skipped by its `if:` condition.
  That a non-zero exit turns the build red is separately evidenced by runs `28895709104` and
  `29374939455`, where the same script exiting 2 failed the same workflow.
- **Branch protection: deliberately NOT enabled** (owner's decision, 2026-08-07). Requiring
  `rails-guard` as a status check would block direct pushes to `main` and force a PR workflow
  on a single-maintainer repo. The trade accepted: **the local hook is the preventing layer**
  (armed in the maintainer's clone, blocks before data leaves the machine) and **CI is the
  detecting layer** for the cases the hook cannot cover — an unarmed clone, a push from a
  cloud routine, `git push --no-verify`, and contributor pull requests. A red privacy gate is
  therefore an incident to act on, not a merge blocker. Revisit if the repo gains
  co-maintainers, since detection-only scales badly across people.

## Honest limits

1. **CI detects; it does not prevent.** It runs after the remote has accepted the push. A red
   privacy gate means the content is already published and needs removing from history.
   Only the local hook stops data before it leaves the machine.
2. **`git push --no-verify` skips the hook.** CI is the reason that is no longer a silent win.
3. **`ALLOW_PERSONAL_PUSH=1` disables the HOOK only**, by design, for private forks. It is a
   local environment variable, so the CI run does not see it and still fails the build. Turning
   the gate off in both places means editing the workflow, which is a reviewable commit.
4. **Baselines are a maintainer tool.** Running `rails-guard.sh baseline` in a personal clone
   re-blesses filled-in files and switches the gate off for them. Documented in the script's
   own usage block.
