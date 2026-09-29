# agent-foundry

A kit that generates project-tailored Claude Code agents. See `README.md` for what it does and `docs/customizing.md` for how the templates are built.

## This repo is public

Never put details from a private project into it: names, paths, board or record IDs, infrastructure facts, or anything from an agent's memory. When a lesson from a project belongs in a role template, write it in general terms.

## Before every commit

```bash
scripts/validate.sh
```

It checks every template and skill, and it scans for private details. It must pass. The owner's private terms live in `.private-terms`, which is git-ignored.

## Rules for changes

- **Role craft goes outside the `foundry:project` blocks. Anything that depends on the project goes inside one,** with a `{{FILL: ...}}` instruction that says what to cover and where to find it.
- **Keep block keys stable.** A renamed key makes a refresh fill the block again and drop what the owner wrote.
- **Raise `VERSION`** when a template or skill changes. Projects detect a refresh by comparing versions.
- **A new role needs four updates:** the template in `agents/`, the role list in `skills/foundry-init/SKILL.md`, the catalog in `docs/agent-catalog.md`, and the table in `README.md`.
- **A skill that reads the kit refers to it as `${CLAUDE_SKILL_DIR}/foundry/`.** The installer bundles the kit into every skill whose `SKILL.md` contains that path.
- **Only the dev template may launch agents.** Every other template lists its tools without `Agent` or sets `disallowedTools: Agent`. The validator enforces this.
- **Don't name a file `agents.md`.** On a case-insensitive filesystem it reads as `AGENTS.md`, and tools load it as instructions.
- **Test the installer in a sandbox:** `CLAUDE_CONFIG_DIR=/some/temp/dir ./install.sh`. Do not install into the real user directory to test.
- **Negative-test a new validator check.** Plant the problem and confirm the check fails.

## Testing a skill end to end

Install the skills into a throwaway project, then run the skill headless:

```bash
CLAUDE_CONFIG_DIR=/path/to/toy-project/.claude ./install.sh
cd /path/to/toy-project
claude -p "/foundry-init <answers to the interview questions>" --permission-mode acceptEdits
bash .claude/skills/foundry-init/foundry/check-project.sh .
```

Questions can't be asked in a headless run, so pass the answers as arguments.

A headless run is never allowed to write into `.claude/`, even with an explicit permission rule. The skill stages its output in `foundry-pending/`. Copy it into place in the throwaway project to validate it.
