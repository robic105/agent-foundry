---
name: foundry-init
description: Set up or update agent-foundry in the current project. Surveys the repo, asks a few questions, then generates project-tailored agents into .claude/agents/ along with CLAUDE.md, baseline permissions, and GitHub templates. Also adopts existing hand-written agents, sets up a planning team for an idea with no code, re-surveys after the code changes, and refreshes agents from a newer foundry version. Use when the user types /foundry-init.
disable-model-invocation: true
---

# Foundry Init

Generate a tailored agent team for this project from the agent-foundry templates.

The kit is bundled next to this file:

```
${CLAUDE_SKILL_DIR}/foundry/VERSION
${CLAUDE_SKILL_DIR}/foundry/agents/            role templates
${CLAUDE_SKILL_DIR}/foundry/templates/         CLAUDE.md, settings.json, CURRENT-STATE.md, idea/, github/
${CLAUDE_SKILL_DIR}/foundry/check-project.sh   validator
```

If `${CLAUDE_SKILL_DIR}/foundry/` is missing, stop and tell the user to run `./install.sh` from their agent-foundry checkout.

Arguments: `$ARGUMENTS`

The arguments may name a mode (`adopt`, `resurvey`, `refresh`, `add <roles>`) or carry answers to the interview.

## Rules for this skill

- **Fill from the real code.** A template left generic defeats the purpose. Every filled section names this project's files, commands, and surfaces.
- **Never invent.** If the survey and the interview can't answer something, write what is known and mark the gap `TODO(owner): <the question>`. Report every such gap at the end.
- **Never overwrite silently.** If a target file exists, merge or ask. Show what would change first.
- **Never rename an agent.** An agent's memory lives in a folder named after the agent. A renamed agent starts with no memory.
- **Never copy secrets.** Do not read `.env` files for values. Do not copy anything from `.claude/settings.local.json`.
- **Do not commit or push.** Leave the changes in the working tree for the owner to review.
- **Date what you observed.** A statement about the code's current state, such as a bug or a missing file, goes stale. Label it "observed at init (YYYY-MM-DD)" and tell the agent to re-check it before relying on it.
- **Label proposals.** A rule you are suggesting, as opposed to one you found in the repo or heard from the owner, is marked as proposed and unconfirmed.
- **If a write into `.claude/` is denied, do not work around it.** Claude Code protects that directory, and an unattended session may not be allowed to write there. Put the finished files in `foundry-pending/`, using this layout: `foundry-pending/agents/<name>.md`, `foundry-pending/settings.json`, and `foundry-pending/foundry.json`. Do not create a folder named `.claude` inside it, because that path is protected too. Write a `foundry-pending/README.md` that maps each file to its destination, and give the owner the exact commands to move them. For an adopted agent, give the command that shows the diff against the existing file first. Report the run as incomplete.

## Step 1: Preflight

1. Confirm the working directory is the project root. If it is not a git repository, say so and offer `git init`.
2. Read `.claude/foundry.json` if it exists. It records what a previous run installed.
3. List `.claude/agents/*.md`. An agent with an `<!-- agent-foundry: role=... -->` line is a foundry agent. Any other is hand-written.
4. Determine the **stage** from the repo:

   | Stage | The repo has |
   |---|---|
   | **idea** | No source code. It may hold a brief at `docs/idea/BRIEF.md`. |
   | **plan** | No source code, and a blueprint at `docs/plan/BLUEPRINT.md` with the status "approved" |
   | **build** | Source code |

   The **idea** and **plan** stages are both handled by the "Idea stage" section.
5. Decide what applies and tell the user. More than one can apply in the same run.

| Situation | What to do |
|---|---|
| No manifest, stage is build | **Fresh** setup: Steps 2 to 7 |
| No manifest, stage is idea or plan | **Planning team:** see "Idea stage" |
| Hand-written agents exist | Offer **Adopt** for each one that does a foundry role: see "Adopt mode" |
| Manifest says idea or plan, and the repo now has code | **Graduate:** see "Graduating to build" |
| No code, and the owner wants to start building | Recommend `/blueprint` to plan the build, then `/scaffold` to build the first milestone. Then run this skill again. |
| Manifest exists, owner wants more agents | **Add:** generate only the new ones, reusing the recorded project facts |
| Manifest exists, and the code has moved on since `surveyed` | **Re-survey:** see "Re-survey mode" |
| Manifest exists, bundled VERSION is newer than `foundryVersion` | **Refresh:** see "Refresh mode" |

6. Hand-written agents are never modified without the owner's go-ahead. When one does a role the owner selects, offer three choices and recommend the first:
   - **Adopt it:** convert it in place. It keeps its name, its memory, and its project content.
   - **Keep it as it is:** skip this role.
   - **Generate a second agent beside it** under a different name. Warn that the new agent starts with no memory.

## Step 2: Survey the repo

Read before asking. When there is no code, read `docs/idea/BRIEF.md`, the files in `docs/idea/rounds/`, and the files in `docs/plan/` in its place. At every stage, read `docs/plan/BLUEPRINT.md` and `docs/plan/DECISIONS.md` if they exist. They record the stack, the structure, and the workflow the owner chose. At the build stage, also find:

- **Stack:** languages, frameworks, package manager, database, auth, payments, storage, hosting
- **Commands:** install, dev, build, typecheck, lint, test, taken from the package manifest and CI
- **Workflow evidence:** branches (`git branch -a`), CI triggers, deploy workflows, protected-branch hints
- **Environments:** URLs, health endpoints, deploy targets
- **Protected surfaces:** code that runs on every request, public render paths, payment and auth handlers, migrations, stores holding the only copy of data
- **Risk surfaces:** the items listed in the security template's risk-map instructions
- **Brand and UI:** theme configuration, design tokens, fonts, component directories, marketing copy
- **Existing documents:** README, CLAUDE.md, architecture notes, specs, runbooks
- **Existing agents:** what each hand-written agent does, from its description and body
- **Tests:** frameworks, layout, and whether the suite currently passes

## Step 3: Interview

Ask only what the survey could not answer. Use AskUserQuestion, at most four questions per call, and offer what the survey found as the recommended option.

1. **Identity:** project name, slug (lowercase kebab-case, used as the agent name prefix), a one-sentence description, and who runs the project. If hand-written agents share a name prefix, offer that prefix as the slug.
2. **Agents:** which roles to install. Multi-select.
   - At the build stage, recommend the core five (dev, code-review, security, ux, pm). Offer architect, qa, devops, tracker, social.
   - At the idea stage, recommend pm and architect, plus ux if people will use an interface. Offer social and tracker.
   - Drop ux and social from the recommendation if the project has no user interface or no audience.
3. **Stack**, only when the repo has no code and neither the brief nor the blueprint says: what the owner plans to build with. "Not decided" is a valid answer and is the default.
4. **Workflow**, at the build stage only, and only if the blueprint does not record one: one of
   - *Staging-first:* work on `staging`, push deploys to a staging environment, production ships through a `staging → main` pull request
   - *Feature branches:* branch from `main`, one pull request per change
   - *Trunk:* commit to `main`, for solo prototypes with no users
5. **Tracker backend**, if tracker was selected: Airtable, GitHub Issues or Projects, or a markdown file. For Airtable, ask for the base name, then read the schema through the Airtable tools.
6. **User and brand**, if ux or social was selected and neither the repo nor the brief answers it: who the user is and in what moment, and how the brand should feel.
7. **Domain specialists:** ask whether the project needs an expert in its own domain, such as a hardware technician, an experience director, or a data-quality reviewer. For each one, ask for its role, the source files it must ground in, the standard it holds, and whether it is read-only.

**Non-interactive runs.** If AskUserQuestion is unavailable, take answers from the arguments, use the recommended default for anything missing, and list every assumption in the final report.

## Step 4: Generate the agents

For each selected role, read `${CLAUDE_SKILL_DIR}/foundry/agents/<role>.md` and write `.claude/agents/<slug>-<role>.md`:

1. Replace the tokens everywhere, including frontmatter:

   | Token | Value |
   |---|---|
   | `{{PROJECT_NAME}}` | display name |
   | `{{SLUG}}` | agent name prefix |
   | `{{ONE_LINER}}` | one sentence ending in a period |
   | `{{STACK}}` | full stack summary, or "not chosen yet" |
   | `{{STACK_SHORT}}` | the three or four main technologies |
   | `{{OWNER}}` | who runs the project |
   | `{{SPECIALIST_SLUG}}` | specialists only |

2. Replace every `{{FILL: ...}}` with real content. The text after `FILL:` is an instruction to you, not text to keep.
3. Keep the `<!-- foundry:project <key> -->` and `<!-- /foundry:project -->` markers and the `<!-- agent-foundry: role=... -->` line. The other modes depend on them.
4. Refer to other agents by their real names. If a role is filled by an adopted or hand-written agent, use that agent's name. Remove references to roles that no agent fills. If no agent does UX, remove the dev agent's UX step.
5. Keep the frontmatter valid: `name` matches the filename without `.md`, and `description` stays a single quoted line. Keep `disallowedTools` where the template sets it.
6. Keep each agent's protected surfaces consistent with the others and with CLAUDE.md. Write the list once, then reuse it.

## Step 5: Project files

Templates are in `${CLAUDE_SKILL_DIR}/foundry/templates/`.

| Target | Rule |
|---|---|
| `CLAUDE.md` | If absent, create from the template. If present, keep all existing content and add the foundry sections that are missing. Handle `include if` blocks as described below. List every agent in the team table, hand-written ones included. |
| `.claude/settings.json` | If absent, create from the template. If present, merge: union the `allow`, `ask`, and `deny` lists and never remove an existing rule. Add each `env` entry from the template only if the key is absent. Add the project's own read-only commands to `allow`, such as its test, lint, and typecheck commands. Add the project's deploy and database migration commands to `ask`. Never write a command that contains a credential or a connection string. |
| `.gitignore` | Ensure it contains `.claude/settings.local.json`, `.claude/agent-memory/`, and `.claude/worktrees/`. Append only what is missing. |
| `.github/pull_request_template.md` | Build stage only. Copy if absent. |
| `.github/ISSUE_TEMPLATE/*` | Build stage only. Copy if absent. |
| `.github/workflows/ci.yml` | Build stage only, and only if no workflow runs checks on pull requests. A workflow that only deploys does not count. Keep the job that matches the stack, delete the other, and set real commands. If the project's checks are known to fail today, say so in the report. |
| `docs/CURRENT-STATE.md` | Build stage only, and only if no agent does tracking. Fill it with an honest snapshot. |

**`include if` blocks.** `templates/CLAUDE.md` wraps optional sections in `<!-- include if: <condition> -->` and `<!-- /include -->`. Keep the content when the condition holds and delete the whole block when it does not. Remove the markers themselves in both cases.

| Condition | Holds when |
|---|---|
| A role, such as `tracker` or `ux` | Any agent fills that role, adopted agents included |
| `idea` | The stage is idea or plan, which means there is no code |
| `build` | The stage is build |
| `blueprint` | `docs/plan/BLUEPRINT.md` exists, at any stage |

Then write `.claude/foundry.json`:

```json
{
  "foundryVersion": "<contents of VERSION>",
  "initialized": "<YYYY-MM-DD>",
  "surveyed": "<YYYY-MM-DD>",
  "stage": "idea | plan | build",
  "project": { "name": "", "slug": "", "oneLiner": "", "owner": "" },
  "workflow": "staging-first | feature-branches | trunk | undecided",
  "tracker": "airtable | github | markdown | none",
  "agents": { "<agent name>": "<role>" },
  "adopted": ["<agent name>"]
}
```

`agents` lists every foundry agent, adopted ones included, keyed by its real name.

## Step 6: Validate

Run the validator and fix everything it reports:

```bash
bash "${CLAUDE_SKILL_DIR}/foundry/check-project.sh" .
```

It fails on leftover `{{` tokens, invalid frontmatter, a name that does not match its filename, unbalanced markers, invalid JSON, a missing brief at the idea stage, and a missing blueprint at the plan stage.

## Step 7: Report

```
agent-foundry <version>: <what ran> for <project name> (stage: <idea | plan | build>)

Agents:  <list with one-line purpose each, marked generated / adopted / left as written>
Files:   <created / merged / skipped, with the reason for each skip>
Assumed: <every default taken without asking>
Gaps:    <every TODO(owner) and which file it is in>
Found:   <problems noticed during the survey: no tests, secrets in tracked files, no CI on pull requests, config that contradicts the code>

Next:
1. Review the agents in .claude/agents/ and correct anything wrong.
2. Start a new Claude Code session so the agents load.
3. Run /kickoff.
```

## Idea stage

Use this when the repo has no code, at the idea stage or the plan stage. It sets up a planning team.

1. If `docs/idea/BRIEF.md` is missing, recommend running `/idea` first, because the brief is what the agents will ground in. If the owner wants to continue without one, run the interview in Step 3, then write a brief from the answers using `templates/idea/BRIEF.md`.
2. Take identity, user, and brand from the brief. Ask only what it does not answer.
3. Generate the selected agents as in Step 4, with these rules:
   - Where a fill instruction asks for facts from code, write that nothing is built yet, with the date, and point to `docs/idea/BRIEF.md`. That is a fact and not a gap, so it is not a `TODO(owner)`.
   - At the plan stage, fill from the blueprint as well: the chosen stack, the planned structure, and the milestones. Label each as planned and not yet built.
   - Use `TODO(owner)` only for something the owner could answer today.
   - Carry the brief's open questions into the agent whose role they concern.
4. Write the project files as in Step 5. The stage is `idea` or `plan`. The workflow comes from the blueprint, or is `undecided`.
5. Validate and report. The next steps in the report are:
   1. Review the agents.
   2. Start a new session so the agents load.
   3. Run `/idea` to keep developing the idea with the team, or `/blueprint` to plan how it gets built.

## Graduating to build

Use this when the manifest says `idea` or `plan` and the repo now has code.

1. If there is no code yet, do not graduate. Recommend `/blueprint` and then `/scaffold`, and stop. Building agents generated without code have little to ground in.
2. Survey the code as in Step 2. Compare it with the blueprint if there is one, and report where they differ under "Found". Do not change either.
3. Take the workflow and the stack from the blueprint. Ask only for what the blueprint and the code leave unanswered.
4. Offer the building agents: dev, code-review, security, qa, devops. Generate the ones selected.
5. Re-survey the planning agents, as in "Re-survey mode", so their blocks describe what is now built.
6. Update `CLAUDE.md`: remove the "Stage: idea" section and add the build sections.
7. Add the build-stage project files from Step 5.
8. In the brief, set the Stage line to `build`. Change nothing else in it. Keep the brief. It stays the record of what the product is for.
9. Check the recorded one-line description against the brief's Decided table and the code. If a decision changed what the product does, propose a new description and use it only if the owner agrees.
10. Set `stage` to `build` in the manifest, then validate and report.

## Adopt mode

Use this to bring a hand-written agent into the foundry while keeping what makes it valuable: its name, its memory, and what the owner wrote about the project.

**Before you start:** run `git status` on the agent file. If it has uncommitted changes, stop and ask the owner to commit or stash them. Git history is the backup.

For each agent, one at a time:

1. **Match it to a role** by what it does, not by its name. Confirm the match with the owner. An agent that matches no standard role can be adopted as a `specialist` or left as it is. Recommend leaving it.

2. **Build the new file** from the role's template.

   *Frontmatter:*
   - `name`: keep it exactly.
   - `description`, `model`, `tools`: keep the owner's.
   - `color`: keep it if it is one of red, blue, green, yellow, purple, orange, pink, cyan. Otherwise use the template's and say so.
   - `memory`: keep the owner's setting. If there is none, use the template's and say so.
   - `disallowedTools`: add the template's if the agent has none.

   *Body:*
   - **Project content goes into the project blocks.** Move the owner's text into the block it belongs to. Move it, do not paraphrase it. The owner chose those words.
   - **Project content that fits no block** goes into an added block with the key `notes`, placed before "What to remember".
   - **Role craft the template also covers:** the template's version replaces it.
   - **Role craft the template lacks:** keep it in the `notes` block, and list it in the report as something the kit's template could gain.
   - **Memory boilerplate is dropped.** That means the description of memory types, the instructions for saving a memory, and any hardcoded path to a memory folder. Claude Code supplies all of that when `memory` is set. Keep the agent's own guidance on what is worth remembering, under "What to remember".
   - Add the `<!-- agent-foundry: role=<role> -->` line.

3. **Account for every line.** Nothing from the old file disappears without being named. Give the owner a table:

   | Old content | Outcome |
   |---|---|
   | "The founder's workflow" section | Moved to block `workflow`, unchanged |
   | "How you work" steps 1 to 5 | Replaced by the template's role craft |
   | Memory types and save instructions | Dropped: Claude Code supplies this |

4. **Check the carried content against the code.** If a statement in a project block contradicts what the repo shows today, report it. Do not change it.

5. **Show the diff and the table, and write only after a go-ahead** for that agent.

6. **Confirm the memory is still attached:** the folder `.claude/agent-memory/<name>/` is untouched and the name has not changed.

Then record each adopted agent in the manifest under `agents` and `adopted`, and update the team table in `CLAUDE.md`.

## Re-survey mode

Use this when the code has moved on and the agents' project blocks no longer describe it. Signs: a block says nothing is built while code exists, a `TODO(owner)` that the code now answers, or the owner asks.

1. Survey the repo as in Step 2.
2. For each foundry agent and each of its project blocks, draft an updated block:
   - Update facts that come from the code: paths, commands, surfaces, the stack.
   - Keep what the owner wrote or confirmed. When you cannot tell whether the owner wrote a statement, keep it.
   - Remove an "observed at init" item only if it is no longer true, and list each one you remove.
   - Resolve a `TODO(owner)` only when the code answers it.
3. Update the same facts in `CLAUDE.md`.
4. Show a diff for each file and get a go-ahead before writing it.
5. Set `surveyed` in the manifest to today, then validate.

## Refresh mode

Use this when the bundled VERSION is newer than `foundryVersion` in the manifest.

For each agent listed in the manifest:

1. Read the existing agent file and the new template for its role.
2. Start from the new template. For each `<!-- foundry:project <key> -->` block, carry over the existing file's block with the same key, unchanged.
3. If the existing file has a block the new template lacks, such as `notes`, keep it in the same position.
4. If the new template has a block key the existing file lacks, fill it as in Step 4.
5. For an adopted agent, keep its frontmatter as it is.
6. If the owner edited text outside the project blocks, show those edits and ask whether to keep them.
7. Show a diff summary and get a go-ahead before writing each file.

Merge any new `env` entries and permission rules from the template into `.claude/settings.json`, following the merge rule in Step 5. Then update `foundryVersion` in the manifest and run the validator.
