#!/usr/bin/env bash
# Seed the aios-starter-kit "Community builders" campaign: create the labels + a batch of
# small, non-competing `good first issue`s designed to attract 20+ external contributors.
#
# WHY: the Claude for OSS "Community builders" bar = 20 unique external contributors with
# merged PRs on one repo in 12 months. Many tiny, parallel tasks (each one file) + the
# SHOWCASE.md gallery are the proven mechanic for reaching that.
#
# USAGE (run after reviewing):  bash scripts/seed-good-first-issues.sh
# Requires: gh (authenticated as the repo owner). Idempotent labels; re-running creates dupes
# of issues, so run once.
set -euo pipefail
REPO="GerardoRdz96/aios-starter-kit"

echo "== creating labels =="
gh label create "good first issue" --repo "$REPO" --color 7057ff --description "Small, self-contained, great for a first PR" --force
gh label create "translation"      --repo "$REPO" --color 0e8a16 --description "Translate a section to another language" --force
gh label create "recipe"           --repo "$REPO" --color 1d76db --description "Add a skill / connection / example recipe" --force
gh label create "docs"             --repo "$REPO" --color fbca04 --description "Docs, clarity, typos" --force
gh label create "help wanted"      --repo "$REPO" --color 008672 --description "Maintainer would love help here" --force

mk() { # title | extra-label | body
  gh issue create --repo "$REPO" --title "$1" --label "good first issue" --label "help wanted" --label "$2" --body "$3"
  sleep 1
}

echo "== creating good-first-issues =="

# --- Translations (one language/section per issue; many contributors can each take one) ---
mk "Translate the 'What is an Agentic OS?' section to Portuguese" translation \
"Port the **What is an Agentic OS?** section of \`README.md\` to Portuguese, keeping the bilingual side-by-side format the rest of the README uses. One file, one section. New to OSS? Perfect starter."
mk "Translate the Quickstart to French" translation \
"Add a French version of the **Quickstart / Inicio rápido** section in \`README.md\`, matching the existing bilingual style."
mk "Translate the Quickstart to German" translation \
"Add a German version of the **Quickstart** section in \`README.md\`."
mk "Translate the class intro (class/README.md) to Portuguese" translation \
"Port the intro of \`class/README.md\` to Portuguese. Great for Lusophone learners."
mk "Translate the 'A note on privacy' section to Italian" translation \
"Add an Italian version of the **A note on privacy** section in \`README.md\`."
mk "Add a Japanese translation of 'What's inside'" translation \
"Translate the **What's inside / Qué incluye** section of \`README.md\` to Japanese."
mk "Add a Hindi translation of the Quickstart" translation \
"Add a Hindi version of the **Quickstart** section in \`README.md\`."

# --- Recipes (skills / connections / examples — each additive, non-competing) ---
mk "Add a 'capture-idea' skill template" recipe \
"Add a small skill under \`.claude/skills/capture-idea/SKILL.md\` that captures a quick idea into \`pending.md\`. Keep it minimal and documented; follow the pattern of the skills already shipped."
mk "Add a 'weekly-review' skill template" recipe \
"Add a \`.claude/skills/weekly-review/SKILL.md\` that walks the user through a short weekly reflection and appends to \`decisions/log.md\`."
mk "Add a GitHub CLI connection recipe to connections.md" recipe \
"Add a CLI-first recipe row for the \`gh\` GitHub CLI to \`connections.md\`, following the existing table format (CLI > API > MCP)."
mk "Add a calendar-CLI connection recipe to connections.md" recipe \
"Add a CLI-first recipe for a calendar tool (e.g. \`gcalcli\`) to \`connections.md\`."
mk "Add an example knowledge/ source showing the ingest step" recipe \
"Add a small example file under \`knowledge/\` (e.g. a short article) plus a note in the README showing how the wiki 'ingest' loop turns it into a \`references/\` page."
mk "Add an example decisions/log.md entry" recipe \
"Add one illustrative entry to \`decisions/log.md\` demonstrating the decision-log format for new users."
mk "Add a sample daily-digest routine" recipe \
"Add an example under \`routines/\` describing a simple daily-digest routine, following the existing routine docs."

# --- Docs / accessibility / meta ---
mk "Add a Troubleshooting section to the README" docs \
"Add a short **Troubleshooting** section covering the 2-3 most common first-run issues (Claude Code not found, permissions, onboarding wizard)."
mk "Add a table of contents to the README" docs \
"Add a linked table of contents near the top of \`README.md\`."
mk "Add an FAQ.md" docs \
"Create \`FAQ.md\` with 5-8 common questions (What is this? Do I need to pay? Is my data private? Can I use it with Cursor/other tools?) and link it from the README."
mk "Improve alt text on class/images for accessibility" docs \
"Review the images embedded in \`README.md\` and \`class/\` and improve their alt text so screen readers describe them well."
mk "Add a CODE_OF_CONDUCT.md (Contributor Covenant)" docs \
"Add a standard \`CODE_OF_CONDUCT.md\` using the Contributor Covenant v2.1 and link it from \`CONTRIBUTING.md\`."
mk "Add 'PRs welcome' + license badges to the README top" docs \
"Add a small badge row (License: MIT, PRs welcome, Claude Code) near the top of \`README.md\`, matching the polish of sibling repos."
mk "Add a '10-minute tour' checklist to class/" docs \
"Add a short checklist to \`class/\` that walks a brand-new user through their first 10 minutes with the kit."

echo "== done. Issues created and labeled. =="
echo "Next: promote the repo (Penguin Alley post, LinkedIn, dev communities) pointing people at the 'good first issue' list + SHOWCASE.md."
