#!/bin/bash
# rails-guard.sh — mechanical enforcement for the kit's prompt-level rails.
# Charter §7 ("keys, not prompts") implemented: frozen-file hash check + personal-content push gate.
#
# Subcommands:
#   check [--staged]      verify every file in the frozen manifest matches its sha256
#                         (--staged: also block commits that stage a frozen path without RAILS_OVERRIDE=1)
#   privacy <range>       block pushes whose commits touch personal paths (override: ALLOW_PERSONAL_PUSH=1)
#   freeze <file>...      (re)record sha256 for files in the manifest — the deliberate-change path
#   install               arm pre-commit + pre-push hooks in this clone
#
# Exit codes: 0 ok · 2 violation (fail-closed: internal errors also exit 2)
set -euo pipefail
trap 'echo "rails-guard: internal error — denying (fail-closed)" >&2; exit 2' ERR

REPO="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$REPO/references/provenance/frozen.manifest"

# Personal-content paths (privacy gate). knowledge/README.md + artifacts/README.md stay public.
PERSONAL=( "context/" "decisions/" "knowledge/" "artifacts/" "aios-intake.md" )
PUBLIC_EXCEPTIONS=( "knowledge/README.md" "artifacts/README.md" "context/README.md" )

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
  local range="$1" bad=0 f
  [ "${ALLOW_PERSONAL_PUSH:-0}" = "1" ] && { echo "rails-guard: privacy gate overridden (ALLOW_PERSONAL_PUSH=1)"; return 0; }
  while IFS= read -r f; do
    if is_personal "$f"; then
      echo "PERSONAL CONTENT IN PUSH: $f" >&2; bad=1
    fi
  done < <(git -C "$REPO" diff --name-only "$range" 2>/dev/null || git -C "$REPO" diff --name-only HEAD~1..HEAD)
  if [ "$bad" -ne 0 ]; then
    echo "Push blocked — personal context/knowledge/decisions/artifacts changes detected." >&2
    echo "If this push is intentional (private fork): ALLOW_PERSONAL_PUSH=1 git push" >&2
    exit 2
  fi
  echo "rails-guard: privacy gate OK"
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

cmd_install() {
  local hooks="$REPO/.git/hooks"
  [ -d "$hooks" ] || { echo "not a git clone (no .git/hooks)" >&2; exit 2; }
  cat > "$hooks/pre-commit" <<EOF
#!/bin/bash
exec "\$(git rev-parse --show-toplevel)/scripts/rails-guard.sh" check --staged
EOF
  cat > "$hooks/pre-push" <<'EOF'
#!/bin/bash
set -euo pipefail
top="$(git rev-parse --show-toplevel)"
"$top/scripts/rails-guard.sh" check
while read -r _local_ref local_sha _remote_ref remote_sha; do
  if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then range="$local_sha"; else range="$remote_sha..$local_sha"; fi
  "$top/scripts/rails-guard.sh" privacy "$range"
done
EOF
  chmod +x "$hooks/pre-commit" "$hooks/pre-push"
  echo "rails-guard: pre-commit + pre-push armed in this clone"
}

case "${1:-}" in
  check)   shift; cmd_check "${1:-}" ;;
  privacy) shift; cmd_privacy "${1:-HEAD~1..HEAD}" ;;
  freeze)  shift; cmd_freeze "$@" ;;
  install) cmd_install ;;
  *) sed -n '2,12p' "$0"; exit 2 ;;
esac
