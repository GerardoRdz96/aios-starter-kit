#!/usr/bin/env bash
# scaffold.sh — deterministic Day-1 scaffold steps for /onboard.
# The skill RUNS this script; the model keeps the judgment work (the interview
# and writing the context files). Fragile, must-be-exact operations live here.
#
# Usage (run from anywhere; paths resolve against the kit root):
#   scaffold.sh init                      Create the working aios-intake.md from the template if missing.
#   scaffold.sh backup                    Back up files the scaffold overwrites to archives/intake-<timestamp>/.
#   scaffold.sh rename <new-name> [old]   Kit-wide whole-word rename of the AIOS name. [old] defaults to Sage;
#                                         pass the current name when re-running after an earlier rename.
#   scaffold.sh reset                     Copy the template back over aios-intake.md (clears personal data).
#
# Add --dry-run anywhere to print what would happen without touching files.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
TEMPLATE="$ROOT/aios-intake.md.template"
INTAKE="$ROOT/aios-intake.md"

DRY=0
ARGS=()
for a in "$@"; do
  if [ "$a" = "--dry-run" ]; then DRY=1; else ARGS+=("$a"); fi
done
set -- "${ARGS[@]+"${ARGS[@]}"}"

say() { echo "[scaffold] $*"; }
run() {
  if [ "$DRY" -eq 1 ]; then say "DRY-RUN: $*"; else "$@"; fi
}

cmd="${1:-}"
case "$cmd" in

  init)
    if [ -f "$INTAKE" ]; then
      say "aios-intake.md already exists — nothing to do."
    else
      [ -f "$TEMPLATE" ] || { say "ERROR: template not found at $TEMPLATE"; exit 1; }
      run cp "$TEMPLATE" "$INTAKE"
      say "created aios-intake.md from the template."
    fi
    ;;

  backup)
    ts="$(date +%Y-%m-%d-%H%M)"
    dest="$ROOT/archives/intake-$ts"
    files=(
      "context/about-me.md"
      "context/about-work.md"
      "context/priorities.md"
      "references/voice.md"
      "connections.md"
      "CLAUDE.md"
      "aios-intake.md"
    )
    found=0
    for f in "${files[@]}"; do
      [ -f "$ROOT/$f" ] && found=1
    done
    if [ "$found" -eq 0 ]; then
      say "nothing to back up."
      exit 0
    fi
    run mkdir -p "$dest"
    for f in "${files[@]}"; do
      if [ -f "$ROOT/$f" ]; then
        run mkdir -p "$dest/$(dirname "$f")"
        run cp "$ROOT/$f" "$dest/$f"
        [ "$DRY" -eq 1 ] || say "backed up $f"
      fi
    done
    say "backup complete -> archives/intake-$ts/"
    ;;

  rename)
    new="${2:-}"
    old="${3:-Sage}"
    if [ -z "$new" ]; then
      say "ERROR: usage: scaffold.sh rename <new-name> [old-name]"
      exit 1
    fi
    if [ "$new" = "$old" ]; then
      say "new name equals current name ($old) — nothing to do."
      exit 0
    fi
    # Whole-word, kit-wide rename in text files. Excludes VCS internals, archives
    # (history must stay intact), raw knowledge drops, and this script's own folder.
    files="$(grep -rlIw --exclude-dir=.git --exclude-dir=archives --exclude-dir=knowledge \
      --exclude-dir=node_modules "$old" "$ROOT" 2>/dev/null | grep -v "/.claude/skills/onboard/scripts/" || true)"
    if [ -z "$files" ]; then
      say "no occurrences of '$old' found — nothing to rename."
      exit 0
    fi
    count=0
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      if [ "$DRY" -eq 1 ]; then
        say "DRY-RUN: would rename '$old' -> '$new' in ${f#$ROOT/}"
      else
        OLD="$old" NEW="$new" perl -pi -e 's/\b\Q$ENV{OLD}\E\b/$ENV{NEW}/g' "$f"
        say "renamed in ${f#$ROOT/}"
      fi
      count=$((count + 1))
    done <<< "$files"
    say "rename '$old' -> '$new' touched $count file(s)."
    ;;

  reset)
    [ -f "$TEMPLATE" ] || { say "ERROR: template not found at $TEMPLATE"; exit 1; }
    run cp "$TEMPLATE" "$INTAKE"
    say "aios-intake.md reset to placeholders (answers live in context/)."
    ;;

  *)
    sed -n '2,14p' "$0"
    exit 1
    ;;
esac
