#!/usr/bin/env bash
#
# Validates a project that /foundry-init has set up.
#
# Usage: check-project.sh [project-dir]
#
# Fails on: template tokens left unfilled, invalid agent frontmatter, an agent
# name that does not match its filename, unbalanced foundry markers, invalid
# JSON, a manifest that lists an agent with no file, a missing brief at the
# idea stage, a missing or unapproved blueprint at the plan stage, and missing
# .gitignore entries.

set -uo pipefail

PROJECT="${1:-.}"
errors=0
warnings=0

# Messages show paths relative to the project.
short() { local m="$*"; printf '%s' "${m//"$PROJECT"\//}"; }
fail() { printf 'FAIL  %s\n' "$(short "$*")"; errors=$((errors + 1)); }
warn() { printf 'WARN  %s\n' "$(short "$*")"; warnings=$((warnings + 1)); }
pass() { printf 'ok    %s\n' "$(short "$*")"; }

if [ ! -d "$PROJECT" ]; then
  echo "Not a directory: $PROJECT" >&2
  exit 2
fi

# Matches {{TOKEN}} and {{FILL: ...}}. Does not match GitHub Actions ${{ expr }}.
TOKEN_PATTERN='\{\{(FILL|[A-Z][A-Z_]*\}\})'

check_tokens() {
  local file="$1"
  local hits
  hits="$(grep -nE "$TOKEN_PATTERN" "$file" 2>/dev/null || true)"
  if [ -n "$hits" ]; then
    fail "$file has unfilled template tokens:"
    printf '%s\n' "$hits" | sed 's/^/        /'
    return 1
  fi
  return 0
}

check_json() {
  local file="$1"
  if command -v python3 >/dev/null 2>&1; then
    if python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$file" 2>/dev/null; then
      pass "$file is valid JSON"
    else
      fail "$file is not valid JSON"
    fi
  elif command -v node >/dev/null 2>&1; then
    if node -e 'JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"))' "$file" 2>/dev/null; then
      pass "$file is valid JSON"
    else
      fail "$file is not valid JSON"
    fi
  else
    warn "$file not checked: neither python3 nor node is available"
  fi
}

# Prints the frontmatter block (between the first two --- lines), or nothing.
frontmatter() {
  awk '
    NR == 1 && $0 != "---" { exit }
    NR == 1 { next }
    $0 == "---" { closed = 1; exit }
    { print }
    END { if (!closed) exit 1 }
  ' "$1"
}

check_agent() {
  local file="$1"
  local base fm name before
  base="$(basename "$file" .md)"
  before="$errors"

  if [ "$(head -n 1 "$file")" != "---" ]; then
    fail "$file does not start with a frontmatter block (---)"
    return
  fi

  if ! fm="$(frontmatter "$file")"; then
    fail "$file has a frontmatter block that is never closed"
    return
  fi

  name="$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -n 1 | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'\$//")"

  if [ -z "$name" ]; then
    fail "$file has no name in its frontmatter"
  elif [ "$name" != "$base" ]; then
    fail "$file: name '$name' does not match the filename '$base'"
  elif ! printf '%s' "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    fail "$file: name '$name' must be lowercase letters, numbers, and hyphens"
  fi

  if ! printf '%s\n' "$fm" | grep -qE '^description:[[:space:]]*[^[:space:]]'; then
    fail "$file has no description in its frontmatter"
  fi

  check_tokens "$file"

  if grep -q '<!-- agent-foundry: role=' "$file"; then
    local opens closes
    opens="$(grep -c '<!-- foundry:project ' "$file" || true)"
    closes="$(grep -c '<!-- /foundry:project -->' "$file" || true)"
    if [ "$opens" != "$closes" ]; then
      fail "$file has unbalanced foundry:project markers ($opens opened, $closes closed)"
    fi
    if grep -q 'TODO(owner)' "$file"; then
      warn "$file has TODO(owner) gaps for the owner to fill"
    fi
  fi

  [ "$errors" -eq "$before" ] && pass "$file"
}

echo "Checking $PROJECT"
echo

# Agents
agent_count=0
if [ -d "$PROJECT/.claude/agents" ]; then
  for f in "$PROJECT"/.claude/agents/*.md; do
    [ -e "$f" ] || continue
    check_agent "$f"
    agent_count=$((agent_count + 1))
  done
fi
[ "$agent_count" -eq 0 ] && fail "no agents found in $PROJECT/.claude/agents/"

# Duplicate names
if [ "$agent_count" -gt 0 ]; then
  dupes="$(for f in "$PROJECT"/.claude/agents/*.md; do frontmatter "$f" | sed -n 's/^name:[[:space:]]*//p' | head -n 1 | tr -d '"'"'"; done | sort | uniq -d)"
  [ -n "$dupes" ] && fail "duplicate agent names: $(printf '%s' "$dupes" | tr '\n' ' ')"
fi

# CLAUDE.md
if [ -f "$PROJECT/CLAUDE.md" ]; then
  before="$errors"
  check_tokens "$PROJECT/CLAUDE.md"
  if grep -qE '<!-- (include if:|/include)' "$PROJECT/CLAUDE.md"; then
    fail "$PROJECT/CLAUDE.md still has template include markers"
  fi
  if [ -f "$PROJECT/docs/plan/BLUEPRINT.md" ] && ! grep -q 'docs/plan/BLUEPRINT.md' "$PROJECT/CLAUDE.md"; then
    fail "$PROJECT/CLAUDE.md does not mention docs/plan/BLUEPRINT.md, so agents will not know to build to it"
  fi
  [ "$errors" -eq "$before" ] && pass "$PROJECT/CLAUDE.md"
else
  fail "$PROJECT/CLAUDE.md is missing"
fi

# Other generated files
for f in docs/CURRENT-STATE.md docs/idea/BRIEF.md docs/plan/BLUEPRINT.md docs/plan/DECISIONS.md .github/pull_request_template.md .github/workflows/ci.yml; do
  if [ -f "$PROJECT/$f" ]; then
    before="$errors"
    check_tokens "$PROJECT/$f"
    [ "$errors" -eq "$before" ] && pass "$PROJECT/$f"
  fi
done
for f in "$PROJECT"/docs/idea/rounds/*.md; do
  [ -e "$f" ] || continue
  before="$errors"
  check_tokens "$f"
  [ "$errors" -eq "$before" ] && pass "$f"
done

# Stage
stage=""
if [ -f "$PROJECT/.claude/foundry.json" ] && command -v python3 >/dev/null 2>&1; then
  stage="$(python3 -c 'import json,sys
try:
    print(json.load(open(sys.argv[1])).get("stage",""))
except Exception:
    pass' "$PROJECT/.claude/foundry.json" 2>/dev/null)"
fi
case "$stage" in
  idea)
    if [ -f "$PROJECT/docs/idea/BRIEF.md" ]; then
      pass "stage is idea and the brief exists"
    else
      fail "stage is idea but docs/idea/BRIEF.md is missing"
    fi
    ;;
  plan)
    if [ ! -f "$PROJECT/docs/plan/BLUEPRINT.md" ]; then
      fail "stage is plan but docs/plan/BLUEPRINT.md is missing"
    elif grep -qiE '^- \*\*Status:\*\* approved' "$PROJECT/docs/plan/BLUEPRINT.md"; then
      pass "stage is plan and the blueprint is approved"
    else
      fail "stage is plan but the blueprint is not approved. Its Status line must start with 'approved'."
    fi
    ;;
  build) pass "stage is build" ;;
  "")    warn ".claude/foundry.json does not record a stage" ;;
  *)     fail ".claude/foundry.json has an unknown stage: '$stage'" ;;
esac

# Every agent in the manifest must exist, or its memory and routing point nowhere
if [ -f "$PROJECT/.claude/foundry.json" ] && command -v python3 >/dev/null 2>&1; then
  missing="$(python3 -c 'import json,sys,os
try:
    d=json.load(open(sys.argv[1]))
except Exception:
    sys.exit(0)
names=list((d.get("agents") or {}).keys())+list(d.get("adopted") or [])
for n in sorted(set(names)):
    if not os.path.isfile(os.path.join(sys.argv[2],".claude","agents",n+".md")):
        print(n)' "$PROJECT/.claude/foundry.json" "$PROJECT" 2>/dev/null)"
  if [ -n "$missing" ]; then
    fail "the manifest lists agents that have no file: $(printf '%s' "$missing" | tr '\n' ' ')"
  fi
fi

# JSON
for f in .claude/settings.json .claude/foundry.json; do
  if [ -f "$PROJECT/$f" ]; then
    check_json "$PROJECT/$f"
  else
    fail "$PROJECT/$f is missing"
  fi
done

# Secrets must not reach shared settings
if [ -f "$PROJECT/.claude/settings.json" ]; then
  if grep -qiE '(password|secret|token|api[_-]?key)[^"]*=|://[^/"[:space:]]+:[^@"[:space:]]+@' "$PROJECT/.claude/settings.json"; then
    fail "$PROJECT/.claude/settings.json looks like it contains a credential. This file is committed."
  fi
fi

# .gitignore
if [ -f "$PROJECT/.gitignore" ]; then
  for entry in '.claude/settings.local.json' '.claude/agent-memory/' '.claude/worktrees/'; do
    if grep -qxF "$entry" "$PROJECT/.gitignore"; then
      pass ".gitignore has $entry"
    else
      fail ".gitignore is missing $entry"
    fi
  done
else
  fail "$PROJECT/.gitignore is missing"
fi

echo
if [ "$errors" -gt 0 ]; then
  echo "$errors problem(s), $warnings warning(s)."
  exit 1
fi
echo "All checks passed. $warnings warning(s)."
