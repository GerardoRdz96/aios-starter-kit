#!/bin/bash
# rails-guard.sh — mechanical enforcement for the kit's prompt-level rails.
# Charter §7 ("keys, not prompts") implemented: frozen-file hash check + personal-content push gate.
#
# Subcommands:
#   check [--staged]      verify every file in the frozen manifest matches its sha256
#                         (--staged: also block commits that stage a frozen path without RAILS_OVERRIDE=1)
#   privacy <range>       block pushes whose commits touch personal paths (override: ALLOW_PERSONAL_PUSH=1)
#   privacy-range <before> <after>
#                         same gate, but resolves a CI push/PR event's two SHAs into a range.
#                         Handles branch creation and force-push (unresolvable <before>) by
#                         scanning the tip's full history — fail-closed, never silently narrower.
#   freeze <file>...      (re)record sha256 for files in the manifest — the deliberate-change path
#   baseline              (re)record sha256 of the placeholder files shipped inside personal
#                         paths, so the gate can tell "still a template" from "now your data".
#                         TEMPLATE MAINTAINERS ONLY — running it in your own clone re-blesses
#                         your filled-in files and switches the gate off for them.
#   install [--force]     arm pre-commit + pre-push hooks in this clone (--force overwrites
#                         hooks this script did not write)
#
# Exit codes: 0 ok · 2 violation (fail-closed: internal errors also exit 2)
set -euo pipefail
trap 'echo "rails-guard: internal error — denying (fail-closed)" >&2; exit 2' ERR

REPO="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$REPO/references/provenance/frozen.manifest"
# Baseline hashes of the placeholder files the template ships INSIDE personal paths.
# A file matching its baseline is still a placeholder, so it is not personal content.
# The moment /onboard writes your facts into it, the hash changes and the gate fires.
BASELINE="$REPO/references/provenance/template-baseline.manifest"

# Personal-content paths (privacy gate). The */README.md placeholders stay public.
PERSONAL=( "context/" "decisions/" "knowledge/" "artifacts/" "archives/" "aios-intake.md" )
PUBLIC_EXCEPTIONS=( "knowledge/README.md" "artifacts/README.md" "context/README.md" "archives/README.md" )

sha() { shasum -a 256 "$1" 2>/dev/null | awk '{print $1}'; }

is_exception() {
  local f="$1" e
  for e in "${PUBLIC_EXCEPTIONS[@]}"; do [ "$f" = "$e" ] && return 0; done
  return 1
}

is_personal() {
  local f="$1" p
  is_exception "$f" && return 1
  for p in "${PERSONAL[@]}"; do [[ "$f" == "$p"* ]] && return 0; done
  return 1
}

# True when $1's content AT COMMIT $2 still equals the placeholder the template shipped.
# Deliberately strict: a file that is absent at the tip (added, then deleted before the push)
# is NOT pristine, because the leak already happened in an earlier commit.
is_pristine_template() {
  local f="$1" tip="$2" want got
  [ -f "$BASELINE" ] || return 1
  want="$(awk -v p="$f" '$2 == p {print $1; exit}' "$BASELINE")"
  [ -n "$want" ] || return 1
  got="$(git -C "$REPO" show "$tip:$f" 2>/dev/null | shasum -a 256 | awk '{print $1}')" || return 1
  [ "$got" = "$want" ]
}

cmd_check() {
  local staged="${1:-}" bad=0
  [ -f "$MANIFEST" ] || { echo "rails-guard: no manifest at $MANIFEST — run 'freeze' first" >&2; exit 2; }
  while read -r want path; do
    [ -z "$path" ] && continue
    local got; got="$(sha "$REPO/$path" || true)"
    if [ "$got" != "$want" ]; then
      echo "FROZEN-FILE VIOLATION: $path (hash mismatch or missing)" >&2; bad=1
    fi
  done < "$MANIFEST"
  if [ "$staged" = "--staged" ] && [ "${RAILS_OVERRIDE:-0}" != "1" ]; then
    local f
    while IFS= read -r f; do
      if grep -q "  $f\$" "$MANIFEST"; then
        echo "FROZEN PATH STAGED: $f — deliberate change? run: scripts/rails-guard.sh freeze $f (then commit manifest too), or RAILS_OVERRIDE=1" >&2
        bad=1
      fi
    done < <(git -C "$REPO" diff --cached --name-only)
  fi
  [ "$bad" -eq 0 ] && echo "rails-guard: frozen manifest OK ($(grep -c . "$MANIFEST") files)" || exit 2
}

cmd_privacy() {
  local range="$1" bad=0 f commits files tip skipped=0
  [ "${ALLOW_PERSONAL_PUSH:-0}" = "1" ] && { echo "rails-guard: privacy gate overridden (ALLOW_PERSONAL_PUSH=1)"; return 0; }
  # Scan EVERY commit being pushed (not just the endpoint diff) so a personal file added and then
  # deleted before the push is still caught. Capture rev-list first so a bad range fails CLOSED —
  # a failure inside process substitution would not trip `set -e`.
  commits="$(git -C "$REPO" rev-list "$range" 2>/dev/null)" \
    || { echo "rails-guard: cannot resolve push range '$range' — denying (fail-closed)" >&2; exit 2; }
  files="$(printf '%s\n' "$commits" | while IFS= read -r c; do
             # --root so the INITIAL (root) commit lists its full file set (else additions
             # made in the first commit and never touched again are silently missed).
             [ -n "$c" ] && git -C "$REPO" diff-tree --root --no-commit-id --name-only -r "$c"
           done | sort -u)"
  # The tip of the range: "A..B" -> B, a bare "B" -> B. Used to read each file's CURRENT
  # content, which is what decides placeholder-vs-personal.
  tip="$(git -C "$REPO" rev-parse "${range##*..}" 2>/dev/null)" \
    || { echo "rails-guard: cannot resolve tip of '$range' — denying (fail-closed)" >&2; exit 2; }
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    if is_personal "$f"; then
      if is_pristine_template "$f" "$tip"; then skipped=$((skipped+1)); continue; fi
      echo "PERSONAL CONTENT IN PUSH: $f" >&2; bad=1
    fi
  done <<< "$files"
  if [ "$bad" -ne 0 ]; then
    echo "Push blocked — personal context/knowledge/decisions/artifacts changes detected." >&2
    echo "These paths hold YOUR facts. If this remote is public, that is a leak." >&2
    echo "If this push is intentional (a private fork): ALLOW_PERSONAL_PUSH=1 git push" >&2
    exit 2
  fi
  if [ "$skipped" -gt 0 ]; then
    echo "rails-guard: privacy gate OK ($skipped unmodified template placeholder(s) allowed)"
  else
    echo "rails-guard: privacy gate OK"
  fi
}

ZERO_SHA="0000000000000000000000000000000000000000"

# Resolve a CI event's (before, after) pair into a range, then run the privacy gate.
# The whole point of this wrapper is that a range we cannot trust must widen the scan,
# never narrow it — a gate that silently checks nothing is worse than no gate.
cmd_privacy_range() {
  local before="${1:-}" after="${2:-}"
  [ -n "$after" ] || { echo "usage: rails-guard.sh privacy-range <before-sha> <after-sha>" >&2; exit 2; }

  # Branch deletion: nothing was added, nothing to scan.
  if [ "$after" = "$ZERO_SHA" ]; then
    echo "rails-guard: branch deletion — no content to scan"; return 0
  fi
  git -C "$REPO" cat-file -e "${after}^{commit}" 2>/dev/null \
    || { echo "rails-guard: cannot resolve pushed tip '$after' — denying (fail-closed)" >&2; exit 2; }

  # Branch creation ($before is all-zeros) or a rewritten history ($before no longer exists
  # after a force-push): there is no honest incremental range, so scan the tip's ENTIRE
  # history. On a fresh clone-and-init — the quickstart path — this is the case that matters,
  # because every personal file the user ever committed is new to the remote.
  if [ "$before" = "$ZERO_SHA" ] || [ -z "$before" ] \
     || ! git -C "$REPO" cat-file -e "${before}^{commit}" 2>/dev/null; then
    echo "rails-guard: no usable base ('$before') — scanning full history of $after"
    cmd_privacy "$after"; return
  fi

  cmd_privacy "${before}..${after}"
}

cmd_freeze() {
  [ $# -ge 1 ] || { echo "usage: rails-guard.sh freeze <file>..." >&2; exit 2; }
  mkdir -p "$(dirname "$MANIFEST")"; touch "$MANIFEST"
  local f rel
  for f in "$@"; do
    rel="${f#"$REPO"/}"
    [ -f "$REPO/$rel" ] || { echo "no such file: $rel" >&2; exit 2; }
    grep -v "  $rel\$" "$MANIFEST" > "$MANIFEST.tmp" || true
    printf '%s  %s\n' "$(sha "$REPO/$rel")" "$rel" >> "$MANIFEST.tmp"
    mv "$MANIFEST.tmp" "$MANIFEST"
    echo "frozen: $rel"
  done
}

# Re-record the placeholder baseline. Maintainers of the TEMPLATE run this after deliberately
# editing a shipped placeholder. Cloners never need it: once a file holds your facts, you WANT
# the gate to fire on it, and re-baselining is exactly how you would switch it back off.
cmd_baseline() {
  local f tmp; tmp="$(mktemp)"
  while IFS= read -r f; do
    is_personal "$f" || continue
    printf '%s  %s\n' "$(sha "$REPO/$f")" "$f" >> "$tmp"
  done < <(git -C "$REPO" ls-files)
  mkdir -p "$(dirname "$BASELINE")"
  sort -k2 "$tmp" > "$BASELINE"; rm -f "$tmp"
  echo "rails-guard: template baseline recorded ($(grep -c . "$BASELINE") placeholder files)"
  cat "$BASELINE"
}

MARKER="# rails-guard-managed — safe to overwrite with: scripts/rails-guard.sh install"

cmd_install() {
  local hooks="$REPO/.git/hooks" force="${1:-}" h
  [ -d "$hooks" ] || { echo "not a git clone (no .git/hooks)" >&2; exit 2; }
  # Never silently destroy someone else's hook (husky, pre-commit, lefthook...). Losing an
  # existing guard while installing a guard would be the exact failure this script exists to
  # prevent, so refuse and let the human merge them.
  if [ "$force" != "--force" ]; then
    for h in pre-commit pre-push; do
      if [ -e "$hooks/$h" ] && ! grep -qF "$MARKER" "$hooks/$h" 2>/dev/null; then
        echo "rails-guard: $hooks/$h already exists and was not written by rails-guard." >&2
        echo "  Merge it by hand, or overwrite with: scripts/rails-guard.sh install --force" >&2
        exit 2
      fi
    done
  fi
  cat > "$hooks/pre-commit" <<EOF
#!/bin/bash
$MARKER
exec "\$(git rev-parse --show-toplevel)/scripts/rails-guard.sh" check --staged
EOF
  cat > "$hooks/pre-push" <<EOF
#!/bin/bash
$MARKER
EOF
  cat >> "$hooks/pre-push" <<'EOF'
set -euo pipefail
top="$(git rev-parse --show-toplevel)"
"$top/scripts/rails-guard.sh" check
while read -r _local_ref local_sha _remote_ref remote_sha; do
  # First push / new branch: remote_sha is all-zeros, so every reachable commit is being pushed —
  # pass the tip alone (rev-list walks all of its history). Otherwise scan only the new commits.
  if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
    range="$local_sha"
  else
    range="$remote_sha..$local_sha"
  fi
  "$top/scripts/rails-guard.sh" privacy "$range"
done
EOF
  chmod +x "$hooks/pre-commit" "$hooks/pre-push"
  echo "rails-guard: pre-commit + pre-push armed in this clone"
}

case "${1:-}" in
  check)         shift; cmd_check "${1:-}" ;;
  privacy)       shift; cmd_privacy "${1:-HEAD~1..HEAD}" ;;
  privacy-range) shift; cmd_privacy_range "${1:-}" "${2:-}" ;;
  freeze)        shift; cmd_freeze "$@" ;;
  baseline)      cmd_baseline ;;
  install)       shift; cmd_install "${1:-}" ;;
  *) sed -n '2,16p' "$0"; exit 2 ;;
esac
