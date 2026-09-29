---
name: foundry-init
description: Set up agent-foundry in the current project. Surveys the repo, asks a few questions, then generates project-tailored agents into .claude/agents/ along with CLAUDE.md, baseline permissions, and GitHub templates. Re-run it to add agents or refresh existing ones from a newer foundry version. Use when the user types /foundry-init or starts a new project.
disable-model-invocation: true
---

# Foundry Init

Generate a tailored agent team for this project from the agent-foundry templates.

The kit is bundled next to this file:

```
${CLAUDE_SKILL_DIR}/foundry/VERSION
${CLAUDE_SKILL_DIR}/foundry/agents/            role templates
${CLAUDE_SKILL_DIR}/foundry/templates/         CLAUDE.md, settings.json, CURRENT-STATE.md, github/
${CLAUDE_SKILL_DIR}/foundry/check-project.sh   validator
```

If `${CLAUDE_SKILL_DIR}/foundry/` is missing, stop and tell the user to run `./install.sh` from their agent-foundry checkout.

Arguments: `$ARGUMENTS`

## Rules for this skill

- **Fill from the real code.** A template left generic defeats the purpose. Every filled section names this project's files, commands, and surfaces.
- **Never invent.** If the survey and the interview can't answer something, write what is known and mark the gap `TODO(owner): <the question>`. Report every such gap at the end.
- **Never overwrite silently.** If a target file exists, merge or ask. Show what would change first.
- **Never copy secrets.** Do not read `.env` files for values. Do not copy anything from `.claude/settings.local.json`.
- **Do not commit or push.** Leave the changes in the working tree for the owner to review.
- **Date what you observed.** A statement about the code's current state, such as a bug or a missing file, goes stale. Label it "observed at init (YYYY-MM-DD)" and tell the agent to re-check it before relying on it.
- **Label proposals.** A rule you are suggesting, as opposed to one you found in the repo or heard from the owner, is marked as proposed and unconfirmed.
- **If a write into `.claude/` is denied, do not work around it.** Claude Code protects that directory, and an unattended session may not be allowed to write there. Put the finished files in `foundry-pending/` with the same layout, write a `foundry-pending/README.md` that maps each file to its destination, and give the owner the exact commands to move them. Report the run as incomplete.

## Step 1: Preflight

1. Confirm the working directory is the project root. If it is not a git repository, say so and offer `git init`.
2. Read `.claude/foundry.json` if it exists. It records what a previous run installed.
3. List `.claude/agents/*.md`. Note which carry an `<!-- agent-foundry: role=... -->` line and which are hand-written.
4. Choose the mode and tell the user which one applies:
   - **Fresh:** no foundry manifest. Full setup.
   - **Add:** a manifest exists and the user wants more agents. Generate only the new ones, reusing the recorded project facts.
   - **Refresh:** a manifest exists and the bundled VERSION is newer than the recorded one. See "Refresh mode" below.
5. Hand-written agents are never modified. If one covers a role the user selects, ask whether to keep it or generate a foundry version beside it under a different name.

## Step 2: Survey the repo

Read before asking. Skip this step for an empty repo. Find:

- **Stack:** languages, frameworks, package manager, database, auth, payments, storage, hosting
- **Commands:** install, dev, build, typecheck, lint, test, taken from the package manifest and CI
- **Workflow evidence:** branches (`git branch -a`), CI triggers, deploy workflows, protected-branch hints
- **Environments:** URLs, health endpoints, deploy targets
- **Protected surfaces:** code that runs on every request, public render paths, payment and auth handlers, migrations, stores holding the only copy of data
- **Risk surfaces:** the items listed in the security template's risk-map instructions
- **Brand and UI:** theme configuration, design tokens, fonts, component directories, marketing copy
- **Existing documents:** README, CLAUDE.md, architecture notes, specs, runbooks
- **Tests:** frameworks, layout, and whether the suite currently passes

## Step 3: Interview

Ask only what the survey could not answer. Use AskUserQuestion, at most four questions per call, and offer what the survey found as the recommended option.

1. **Identity:** project name, slug (lowercase kebab-case, used as the agent name prefix), a one-sentence description, and who runs the project.
2. **Agents:** which roles to install. Multi-select. Recommend the core five (dev, code-review, security, ux, pm). Offer architect, qa, devops, tracker, social. Drop ux and social from the recommendation if the project has no user interface or no audience.
3. **Workflow:** one of
   - *Staging-first:* work on `staging`, push deploys to a staging environment, production ships through a `staging → main` pull request
   - *Feature branches:* branch from `main`, one pull request per change
   - *Trunk:* commit to `main`, for solo prototypes with no users
4. **Tracker backend**, if tracker was selected: Airtable, GitHub Issues or Projects, or a markdown file. For Airtable, ask for the base name, then read the schema through the Airtable tools.
5. **User and brand**, if ux or social was selected and the repo does not answer it: who the user is and in what moment, and how the brand should feel.
6. **Domain specialists:** ask whether the project needs an expert in its own domain, such as a hardware technician, an experience director, or a data-quality reviewer. For each one, ask for its role, the source files it must ground in, the standard it holds, and whether it is read-only.

**Non-interactive runs.** If AskUserQuestion is unavailable, take answers from the arguments, use the recommended default for anything missing, and list every assumption in the final report.

## Step 4: Generate the agents

For each selected role, read `${CLAUDE_SKILL_DIR}/foundry/agents/<role>.md` and write `.claude/agents/<slug>-<role>.md`:

1. Replace the tokens everywhere, including frontmatter:

   | Token | Value |
   |---|---|
   | `{{PROJECT_NAME}}` | display name |
   | `{{SLUG}}` | agent name prefix |
   | `{{ONE_LINER}}` | one sentence ending in a period |
   | `{{STACK}}` | full stack summary |
   | `{{STACK_SHORT}}` | the three or four main technologies |
   | `{{OWNER}}` | who runs the project |
   | `{{SPECIALIST_SLUG}}` | specialists only |

2. Replace every `{{FILL: ...}}` with real content. The text after `FILL:` is an instruction to you, not text to keep.
3. Keep the `<!-- foundry:project <key> -->` and `<!-- /foundry:project -->` markers and the `<!-- agent-foundry: role=... -->` line. Refresh mode depends on them.
4. Remove references to agents that are not installed. If ux is not installed, remove the dev agent's UX step. Apply the same rule to tracker, pm, qa, and the others.
5. Keep the frontmatter valid: `name` matches the filename without `.md`, and `description` stays a single quoted line.
6. Keep each agent's protected surfaces consistent with the others and with CLAUDE.md. Write the list once, then reuse it.

## Step 5: Project files

Templates are in `${CLAUDE_SKILL_DIR}/foundry/templates/`.

| Target | Rule |
|---|---|
| `CLAUDE.md` | If absent, create from the template. If present, keep all existing content and add the foundry sections that are missing. For each `<!-- include if: <role> -->` block, keep the content if that role is installed and delete the whole block if it is not. Remove the include markers themselves in both cases. |
| `.claude/settings.json` | If absent, create from the template. If present, merge: union the `allow`, `ask`, and `deny` lists and never remove an existing rule. Add the project's own read-only commands to `allow`, such as its test, lint, and typecheck commands. Add the project's deploy and database migration commands to `ask`. Never write a command that contains a credential or a connection string. |
| `.gitignore` | Ensure it contains `.claude/settings.local.json`, `.claude/agent-memory/`, and `.claude/worktrees/`. Append only what is missing. |
| `.github/pull_request_template.md` | Copy if absent. |
| `.github/ISSUE_TEMPLATE/*` | Copy if absent. |
| `.github/workflows/ci.yml` | Only if the repo has no CI workflow. Keep the job that matches the stack, delete the other, and set real commands. |
| `docs/CURRENT-STATE.md` | Only if tracker was NOT selected. Fill it with an honest snapshot. |

Then write `.claude/foundry.json`:

```json
{
  "foundryVersion": "<contents of VERSION>",
  "initialized": "<YYYY-MM-DD>",
  "project": { "name": "", "slug": "", "oneLiner": "", "owner": "" },
  "workflow": "staging-first | feature-branches | trunk",
  "tracker": "airtable | github | markdown | none",
  "agents": { "<slug>-dev": "dev", "<slug>-ux": "ux" }
}
```

## Step 6: Validate

Run the validator and fix everything it reports:

```bash
bash "${CLAUDE_SKILL_DIR}/foundry/check-project.sh" .
```

It fails on leftover `{{` tokens, invalid frontmatter, a name that does not match its filename, unbalanced markers, and invalid JSON.

## Step 7: Report

```
agent-foundry <version>: <fresh | add | refresh> for <project name>

Agents:  <list with one-line purpose each>
Files:   <created / merged / skipped, with the reason for each skip>
Assumed: <every default taken without asking>
Gaps:    <every TODO(owner) and which file it is in>
Found:   <problems noticed during the survey: no tests, secrets in tracked files, no CI on pull requests, config that contradicts the code>

Next:
1. Review the generated agents in .claude/agents/ and correct anything wrong.
2. Start a new Claude Code session so the agents load.
3. Run /kickoff.
```

## Refresh mode

Use this when the bundled VERSION is newer than `foundryVersion` in the manifest.

For each agent listed in the manifest:

1. Read the existing agent file and the new template for its role.
2. Start from the new template. For each `<!-- foundry:project <key> -->` block, carry over the existing file's block with the same key, unchanged.
3. If the new template has a block key the existing file lacks, fill it as in Step 4.
4. If the owner edited text outside the project blocks, show those edits and ask whether to keep them.
5. Show a diff summary and get a go-ahead before writing each file.

Then update `foundryVersion` in the manifest and run the validator.
