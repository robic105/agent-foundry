#!/usr/bin/env bash
#
# Installs agent-foundry's skills into your Claude Code user directory so that
# /idea, /blueprint, /scaffold, /foundry-init, /kickoff, /ship, and /wrap-up
# are available in every project.
#
# Usage:
#   ./install.sh              install or update
#   ./install.sh --dry-run    show what would happen, change nothing
#   ./install.sh --force      replace same-named skills that foundry did not install
#   ./install.sh --uninstall  remove everything foundry installed
#
# Installs into $CLAUDE_CONFIG_DIR if set, otherwise ~/.claude.
# Only touches skill directories it owns, which it marks with a .agent-foundry file.

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SKILLS_DIR="$CLAUDE_HOME/skills"
MARKER=".agent-foundry"

MODE="install"
DRY_RUN=0
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY_RUN=1 ;;
    --force)     FORCE=1 ;;
    --uninstall) MODE="uninstall" ;;
    -h|--help)
      sed -n '2,14p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "Run ./install.sh --help for usage." >&2
      exit 2
      ;;
  esac
done

VERSION="$(tr -d '[:space:]' < "$KIT_DIR/VERSION")"

say() { printf '%s\n' "$*"; }

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    say "  would run: $*"
  else
    "$@"
  fi
}

# Refuse to remove anything that is not a plain skill directory under SKILLS_DIR.
remove_skill_dir() {
  local name="$1"
  case "$name" in
    ""|.|..|*/*) echo "Refusing to remove unsafe name: '$name'" >&2; exit 1 ;;
  esac
  run rm -rf "$SKILLS_DIR/$name"
}

owned_by_foundry() {
  [ -f "$SKILLS_DIR/$1/$MARKER" ]
}

skill_names() {
  local d
  for d in "$KIT_DIR"/skills/*/; do
    [ -f "$d/SKILL.md" ] && basename "$d"
  done
}

if [ "$MODE" = "uninstall" ]; then
  say "Removing agent-foundry skills from $SKILLS_DIR"
  removed=0
  for name in $(skill_names); do
    if owned_by_foundry "$name"; then
      remove_skill_dir "$name"
      say "  removed: $name"
      removed=$((removed + 1))
    elif [ -e "$SKILLS_DIR/$name" ]; then
      say "  left alone: $name (not installed by agent-foundry)"
    fi
  done
  say "Done. Removed $removed skill(s). Agents already generated inside your projects are untouched."
  exit 0
fi

say "Installing agent-foundry $VERSION into $SKILLS_DIR"
[ "$DRY_RUN" -eq 1 ] && say "(dry run: nothing will change)"

run mkdir -p "$SKILLS_DIR"

installed=0
skipped=0

for name in $(skill_names); do
  target="$SKILLS_DIR/$name"

  if [ -e "$target" ] && ! owned_by_foundry "$name" && [ "$FORCE" -ne 1 ]; then
    say "  skipped: $name (a skill with this name already exists and was not installed by agent-foundry; use --force to replace it)"
    skipped=$((skipped + 1))
    continue
  fi

  [ -e "$target" ] && remove_skill_dir "$name"
  run cp -R "$KIT_DIR/skills/$name" "$target"

  if grep -q 'CLAUDE_SKILL_DIR}/foundry/' "$KIT_DIR/skills/$name/SKILL.md"; then
    # This skill reads the kit. Bundle it so the skill can find it from any project.
    run mkdir -p "$target/foundry"
    run cp -R "$KIT_DIR/agents" "$target/foundry/agents"
    run cp -R "$KIT_DIR/templates" "$target/foundry/templates"
    run cp "$KIT_DIR/VERSION" "$target/foundry/VERSION"
    run cp "$KIT_DIR/scripts/check-project.sh" "$target/foundry/check-project.sh"
  fi

  if [ "$DRY_RUN" -ne 1 ]; then
    printf '%s\n' "$VERSION" > "$target/$MARKER"
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    say "  would install: /$name"
  else
    say "  installed: /$name"
  fi
  installed=$((installed + 1))
done

say ""
if [ "$DRY_RUN" -eq 1 ]; then
  say "Would install $installed skill(s) and skip $skipped. Nothing was changed."
  exit 0
fi
say "Installed $installed skill(s), skipped $skipped."
say ""
say "Next:"
say "  1. Start a new Claude Code session in any project."
say "  2. Type /foundry-init to generate that project's agents."
say ""
say "To update later: git pull, then run ./install.sh again."
