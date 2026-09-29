# Customizing

There are two places to make a change, and they have different reach.

| You want to change | Edit | Reach |
|---|---|---|
| How a role works in every project | `agents/<role>.md` in this repo | Every project, after install and refresh |
| How a role works in one project | `.claude/agents/<slug>-<role>.md` in that project | That project only |

## How a template is built

```markdown
---
name: {{SLUG}}-code-review
description: "Use this agent to review a diff..."
tools: Read, Grep, Glob, Bash
model: opus
color: purple
memory: project
---

<!-- agent-foundry: role=code-review -->

You are a meticulous code reviewer for {{PROJECT_NAME}} ({{STACK}}).

## Review angles (run them all)
...role craft, the same in every project...

<!-- foundry:project blast-radius -->
## Blast-radius lens (weight these highest)

{{FILL: The specific paths where a mistake reaches every user...}}
<!-- /foundry:project -->
```

### Tokens

Simple values, replaced everywhere they appear.

| Token | Example |
|---|---|
| `{{PROJECT_NAME}}` | `Acme Notes` |
| `{{SLUG}}` | `acme-notes` |
| `{{ONE_LINER}}` | `A shared notebook for small teams.` |
| `{{STACK}}` | `Next.js 14, Prisma, Postgres, deployed on Fly.io` |
| `{{STACK_SHORT}}` | `Next.js / Prisma / Postgres` |
| `{{OWNER}}` | `a two-person founder team` |
| `{{SPECIALIST_SLUG}}` | `data-quality` |

### Fill instructions

`{{FILL: ...}}` holds an instruction to `/foundry-init`. The skill replaces the whole thing with content written for the project. A good instruction says what to cover, where to find it, and what to do when the answer is unknown.

### Project blocks

```markdown
<!-- foundry:project <key> -->
...
<!-- /foundry:project -->
```

Content inside a block belongs to the project. A refresh carries it over unchanged. Content outside a block is role craft, and a refresh replaces it with the new template.

An adopted agent can have one extra block with the key `notes`. It holds project content from the hand-written agent that fit no block in the template. A refresh keeps it.

Rules for keys:

- Lowercase letters and hyphens
- Unique within one template
- Stable over time. If you rename a key, a refresh treats it as new and fills it again.

## Changing a role everywhere

1. Edit `agents/<role>.md`.
2. Run `scripts/validate.sh`.
3. Raise the number in `VERSION`.
4. Commit, then run `./install.sh`.
5. In each project, run `/foundry-init` and accept the refresh.

When a lesson from one project would help the others, add it to the role craft. That is how the kit improves over time. Write the lesson in general terms and leave the project's details out, because this repo is public.

## Changing a role in one project

Edit the generated file in the project's `.claude/agents/`.

- Edits **inside** a project block are kept on refresh.
- Edits **outside** a block are shown to you on refresh, and the skill asks whether to keep them.

If you often make the same edit outside a block, the template probably needs a new project block there.

## Adding a new role

1. Copy the closest template to `agents/<new-role>.md`.
2. Set the frontmatter: `name: {{SLUG}}-<new-role>`, a one-line quoted `description` with trigger phrases, `tools`, `model`, `color`, and `memory: project`. If the role has no `tools` line, add `disallowedTools: Agent`.
3. Set the marker line: `<!-- agent-foundry: role=<new-role> -->`.
4. Write the role craft. Put everything that depends on the project inside project blocks with fill instructions.
5. End with a `## What to remember` section.
6. Add the role to the agent list in `skills/foundry-init/SKILL.md` and to `docs/agent-catalog.md`.
7. Run `scripts/validate.sh`.

### Writing a good description

Claude decides when to launch an agent from its `description`. Include:

- What the agent does, in one sentence
- "Use proactively when the user says" followed by the words a person would type
- Whether it is read-only

### Choosing tools

Give an agent the fewest tools its job needs.

| The agent | Tools |
|---|---|
| Reviews code or configuration | `Read, Grep, Glob, Bash` |
| Reviews and also researches | Add `WebFetch, WebSearch` |
| Advises without running anything | `Read, Grep, Glob, WebFetch, WebSearch` |
| Writes code, or needs MCP tools | Leave `tools` out, so it inherits all of them, and add `disallowedTools: Agent` |

### Launching other agents

Only the `dev` template can launch another agent. `scripts/validate.sh` enforces this: every other template must either list its tools without `Agent` or set `disallowedTools: Agent`.

The reason is visibility. When an agent launches another, the owner sees only the first agent's summary of what the second one said. That is acceptable for a quick consult. It is not acceptable for a review that decides whether something ships.

`templates/settings.json` also caps nesting at two layers with `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`. Two layers means a building agent and one advisor.

### Choosing a model

Every template uses `opus`. For roles that do lighter work, such as the tracker or the social agent, you can set `sonnet` in a project to lower cost. Valid values are `opus`, `sonnet`, `haiku`, a full model ID, or `inherit` to follow the main session.

### Colors

Valid values: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan`.

## Changing the project templates

| File | Used for |
|---|---|
| `templates/CLAUDE.md` | The project's `CLAUDE.md`. See "Optional sections" below. |
| `templates/idea/BRIEF.md` | The idea brief that `/idea` writes |
| `templates/plan/BLUEPRINT.md` | The build plan that `/blueprint` writes |
| `templates/plan/DECISIONS.md` | The decision record |
| `templates/settings.json` | Baseline permissions |
| `templates/CURRENT-STATE.md` | Session handoff for projects without a tracker |
| `templates/github/` | Pull request, issue, and CI templates |

### Optional sections

`templates/CLAUDE.md` wraps each optional section in a pair of markers:

```markdown
<!-- include if: tracker -->
## Project tracking
...
<!-- /include -->
```

| Condition | The section is kept when |
|---|---|
| A role, such as `tracker` or `ux` | Any agent fills that role, adopted agents included |
| `idea` | The project has no code yet, at the idea stage or the plan stage |
| `build` | The project has code |
| `blueprint` | `docs/plan/BLUEPRINT.md` exists, at any stage |

Include blocks can't be nested. `/foundry-init` removes the markers from the generated file.

### Stages

A project has three stages. The repo decides the stage, and the manifest records it.

| | idea | plan | build |
|---|---|---|---|
| The repo has | A brief | An approved blueprint, no code | Code |
| Agents recommended | pm, architect, ux | pm, architect, ux | The core five |
| Agents ground in | The brief | The brief and the blueprint | The code and the blueprint |
| Code facts in project blocks | "Nothing is built yet" | Planned, labelled as not yet built | Real paths and commands |
| GitHub templates and CI | Not added | Not added | Added |
| `/ship` | Stops | Stops | Runs the gates |

### The permissions baseline

`templates/settings.json` sets one environment variable, which caps agent nesting at two layers, and three permission lists:

| List | Contents | Effect |
|---|---|---|
| `allow` | Read-only `git` and `gh` commands | Run without a prompt |
| `ask` | `git push` | Always prompts |
| `deny` | Force push, `gh pr merge`, reading `.env` files | Blocked |

`/foundry-init` adds the project's own read-only commands to `allow`, such as its test and lint commands. It adds the project's deploy and migration commands to `ask`.

Keep credentials out of this file. It gets committed. When you approve a command that contains a password or a connection string, Claude Code saves it to `.claude/settings.local.json`, which stays local.

## Keeping private details out of this repo

`scripts/validate.sh` scans every file that would be published. It looks for home directory paths, email addresses, Airtable IDs, credentials in URLs, and common secret formats.

To block your own project names as well, list them in `.private-terms` at the repo root, one per line:

```
my-secret-project
internal-codename
```

That file is git-ignored, so the terms themselves are never published. Run `scripts/validate.sh` before every commit.
