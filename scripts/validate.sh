#!/usr/bin/env bash
#
# Validates the agent-foundry kit itself. Run before committing.
#
# Usage: scripts/validate.sh
#
# Checks that every agent template and skill is well formed, and that nothing
# private has leaked into this public repo.
#
# To block your own project names and other private terms, list them one per
# line in a file named .private-terms at the repo root. That file is
# git-ignored, so the terms themselves never get published.

set -uo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$KIT_DIR" || exit 2

errors=0
fail() { printf 'FAIL  %s\n' "$*"; errors=$((errors + 1)); }
pass() { printf 'ok    %s\n' "$*"; }

VALID_COLORS="red blue green yellow purple orange pink cyan"
VALID_MEMORY="user project local"

frontmatter() {
  awk '
    NR == 1 && $0 != "---" { exit }
    NR == 1 { next }
    $0 == "---" { closed = 1; exit }
    { print }
    END { if (!closed) exit 1 }
  ' "$1"
}

field() {
  printf '%s\n' "$1" | sed -n "s/^$2:[[:space:]]*//p" | head -n 1
}

in_list() {
  local needle="$1"; shift
  local item
  for item in "$@"; do [ "$item" = "$needle" ] && return 0; done
  return 1
}

echo "Agent templates"
for f in agents/*.md; do
  before="$errors"
  role="$(basename "$f" .md)"

  if ! fm="$(frontmatter "$f")" || [ -z "$fm" ]; then
    fail "$f has no valid frontmatter block"
    continue
  fi

  name="$(field "$fm" name)"
  case "$name" in
    "{{SLUG}}-$role") ;;
    "{{SLUG}}-{{SPECIALIST_SLUG}}") [ "$role" = "specialist" ] || fail "$f: unexpected name '$name'" ;;
    *) fail "$f: name should be '{{SLUG}}-$role' but is '$name'" ;;
  esac

  desc="$(field "$fm" description)"
  case "$desc" in
    \"*\") ;;
    *) fail "$f: description must be one double-quoted line" ;;
  esac

  color="$(field "$fm" color)"
  # shellcheck disable=SC2086
  in_list "$color" $VALID_COLORS || fail "$f: color '$color' is not one of: $VALID_COLORS"

  memory="$(field "$fm" memory)"
  # shellcheck disable=SC2086
  in_list "$memory" $VALID_MEMORY || fail "$f: memory '$memory' is not one of: $VALID_MEMORY"

  [ -n "$(field "$fm" model)" ] || fail "$f: no model set"

  grep -q "<!-- agent-foundry: role=$role -->" "$f" || fail "$f: missing the line <!-- agent-foundry: role=$role -->"

  opens="$(grep -c '<!-- foundry:project ' "$f" || true)"
  closes="$(grep -c '<!-- /foundry:project -->' "$f" || true)"
  [ "$opens" = "$closes" ] || fail "$f: unbalanced foundry:project markers ($opens opened, $closes closed)"
  [ "$opens" -gt 0 ] || fail "$f: has no foundry:project block, so nothing in it is tailored to a project"

  dupkeys="$(grep -o '<!-- foundry:project [a-z-]* -->' "$f" | sort | uniq -d)"
  [ -z "$dupkeys" ] || fail "$f: duplicate foundry:project keys: $dupkeys"

  grep -q '^## What to remember' "$f" || fail "$f: missing the 'What to remember' section"

  [ "$errors" -eq "$before" ] && pass "$f"
done

echo
echo "Skills"
for d in skills/*/; do
  name="$(basename "$d")"
  f="${d}SKILL.md"
  before="$errors"

  if [ ! -f "$f" ]; then
    fail "$d has no SKILL.md"
    continue
  fi
  if ! fm="$(frontmatter "$f")" || [ -z "$fm" ]; then
    fail "$f has no valid frontmatter block"
    continue
  fi
  [ "$(field "$fm" name)" = "$name" ] || fail "$f: name does not match its directory '$name'"
  [ -n "$(field "$fm" description)" ] || fail "$f: no description"

  [ "$errors" -eq "$before" ] && pass "$f"
done

echo
echo "Templates"
for f in templates/settings.json; do
  if python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$f" 2>/dev/null; then
    pass "$f is valid JSON"
  else
    fail "$f is not valid JSON"
  fi
done
for f in templates/CLAUDE.md templates/CURRENT-STATE.md templates/github/pull_request_template.md templates/github/workflows/ci.yml; do
  [ -f "$f" ] && pass "$f exists" || fail "$f is missing"
done
inc_open="$(grep -c '<!-- include if:' templates/CLAUDE.md || true)"
inc_close="$(grep -c '<!-- /include -->' templates/CLAUDE.md || true)"
[ "$inc_open" = "$inc_close" ] || fail "templates/CLAUDE.md: unbalanced include markers ($inc_open opened, $inc_close closed)"

echo
echo "Scripts"
for f in install.sh scripts/check-project.sh scripts/validate.sh; do
  if bash -n "$f" 2>/dev/null; then
    pass "$f parses"
  else
    fail "$f has a syntax error"
  fi
  [ -x "$f" ] || fail "$f is not executable"
done

echo
echo "Privacy"
before="$errors"

# Tracked and untracked files that would be published, minus git-ignored ones.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  files="$(git ls-files --cached --others --exclude-standard)"
else
  files="$(find . -type f -not -path './.git/*' | sed 's|^\./||')"
fi

scan() {
  local label="$1" pattern="$2" flags="$3" hits
  # shellcheck disable=SC2086
  hits="$(printf '%s\n' "$files" | grep -v '^scripts/validate.sh$' | tr '\n' '\0' | xargs -0 grep -nE $flags -- "$pattern" 2>/dev/null || true)"
  if [ -n "$hits" ]; then
    fail "$label:"
    printf '%s\n' "$hits" | sed 's/^/        /'
  fi
}

scan "absolute home directory path" '/(Users|home)/[A-Za-z0-9._-]+/' ""
scan "email address" '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.(com|net|org|io|dev|co)\b' ""
scan "Airtable record, table, base, or field ID" '\b(app|tbl|fld|rec)[A-Za-z0-9]{14}\b' ""
scan "credential in a URL" '://[^/"[:space:]]+:[^@"[:space:]]+@' ""
scan "secret-looking token" '\b(sk|pk|rk)_(live|test)_[A-Za-z0-9]{8,}|\bgh[pousr]_[A-Za-z0-9]{20,}|\bAKIA[A-Z0-9]{16}\b' ""

if [ -f .private-terms ]; then
  while IFS= read -r term || [ -n "$term" ]; do
    case "$term" in ""|\#*) continue ;; esac
    scan "private term listed in .private-terms" "$term" "-i"
  done < .private-terms
  git check-ignore -q .private-terms 2>/dev/null || fail ".private-terms is not git-ignored. Add it to .gitignore before committing."
else
  echo "note  no .private-terms file, so only the built-in patterns were checked"
fi

[ "$errors" -eq "$before" ] && pass "nothing private found"

echo
if [ "$errors" -gt 0 ]; then
  echo "$errors problem(s)."
  exit 1
fi
echo "All checks passed."
