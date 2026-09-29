# Getting started

This guide covers installing agent-foundry and using it in a new project, an existing project, and day-to-day work.

## Before you start

You need:

- [Claude Code](https://claude.com/claude-code), in the desktop app, the terminal, or an IDE extension
- `git`
- The [GitHub CLI](https://cli.github.com) (`gh`), signed in. `/kickoff` and `/ship` use it for pull requests and CI runs.

## Part 1: Install, once per computer

```bash
git clone https://github.com/robic105/agent-foundry.git
cd agent-foundry
./install.sh
```

To preview the changes first, run `./install.sh --dry-run`.

The installer copies four skills into `~/.claude/skills/`: `foundry-init`, `kickoff`, `ship`, and `wrap-up`. It bundles the agent templates inside the `foundry-init` skill so the skill can find them from any project.

The installer only replaces skills it installed itself. If you already have a skill named `kickoff` from somewhere else, the installer skips it and tells you.

## Part 2: Set up a new project

### Step 1: Create the project

```bash
mkdir my-app && cd my-app
git init
```

If you already know the stack, scaffold it first, for example with `npx create-next-app`. The more code `/foundry-init` can read, the more specific the agents will be. An empty repo also works. The agents will carry more `TODO(owner)` gaps, and you can refresh them once there is code.

### Step 2: Run the init skill

Open the project in Claude Code and type:

```
/foundry-init
```

### Step 3: Answer the questions

The skill reads the repo first and asks only what it could not find. Expect questions on:

| Question | What it decides |
|---|---|
| Project name and slug | The slug prefixes every agent name. Slug `my-app` produces `my-app-dev`, `my-app-ux`, and so on. |
| One-line description | The opening line of every agent |
| Which agents | The core five are recommended. Add the others as needed. |
| Workflow | How the dev agent, `/kickoff`, and `/ship` handle branches |
| Tracker backend | Where the planning board lives, if you chose the tracker |
| User and brand | What the UX and social agents measure against |
| Domain specialists | Whether the project needs an expert in its own domain |

**Choosing a workflow:**

| Workflow | How it works | Choose it when |
|---|---|---|
| Staging-first | Work on `staging`. A push deploys to a staging environment. Production ships through a `staging → main` pull request. | The product has real users |
| Feature branches | Branch from `main`. One pull request per change. | You want review without a staging environment |
| Trunk | Commit to `main`. | A solo prototype with no users |

Claude Code asks for permission before it writes into `.claude/`. Approve those writes. If they are denied, the skill puts the finished files in a `foundry-pending/` folder and gives you the commands to move them into place.

### Step 4: Review what was generated

```
my-app/
├── CLAUDE.md                          routing rules, workflow, protected surfaces
├── .claude/
│   ├── agents/
│   │   ├── my-app-dev.md
│   │   ├── my-app-code-review.md
│   │   └── ...
│   ├── settings.json                  baseline permissions
│   └── foundry.json                   what was installed, and which version
├── .github/
│   ├── pull_request_template.md
│   ├── ISSUE_TEMPLATE/
│   └── workflows/ci.yml
├── docs/CURRENT-STATE.md              only when there is no tracker agent
└── .gitignore                         updated
```

Read each agent file. The skill reports every gap it could not fill as `TODO(owner)`. Pay most attention to these sections, because they drive the agents' judgment:

- **Protected surfaces** in `CLAUDE.md` and in the dev and code-review agents
- **Where the risk lives** in the security agent
- **Who the user is** and **The brand** in the UX agent

If something is wrong, edit the file. Your edits inside the `foundry:project` blocks survive a later refresh.

### Step 5: Start a new session

Claude Code loads agents when a session starts. Start a new session, then check that the agents are present:

```
/agents
```

### Step 6: Commit

Commit these:

```bash
git add CLAUDE.md .claude/agents .claude/settings.json .claude/foundry.json .github .gitignore
git commit -m "Add agent-foundry team"
```

These stay local, and `.gitignore` already excludes them:

| Path | Why it stays local |
|---|---|
| `.claude/settings.local.json` | Your personal permissions. It can end up holding credentials inside approved commands. |
| `.claude/agent-memory/` | What each agent has learned. It can include details about your infrastructure. |
| `.claude/worktrees/` | Temporary working copies |

## Part 3: Set up an existing project

Run `/foundry-init` in the project. The same steps apply, with these differences:

- **Existing `CLAUDE.md`:** the skill keeps your content and adds only the sections that are missing.
- **Existing `.claude/settings.json`:** the skill merges its rules into yours and removes nothing.
- **Existing agents:** hand-written agents are never modified. If one covers a role you select, the skill asks whether to keep it or to generate a foundry version beside it.
- **Existing CI and GitHub templates:** left as they are.

The survey also reports problems it notices, such as missing tests, no CI on pull requests, or configuration that contradicts the code.

## Part 4: A working session

### Start

```
/kickoff
```

You get the branch state, what is in flight, open pull requests, the latest CI result, and a suggested objective. If the project has a tracker agent, kickoff also reports drift between the board and reality.

You can name a focus: `/kickoff the checkout bug`.

### Work

Talk normally. Claude routes to the right agent based on what you ask. You can also name one:

```
Have my-app-architect plan the notification system first.
```

```
Ask my-app-ux whether the status change should need a confirm step.
```

### Ship

```
/ship
```

The gates run in order and stop at the first failure:

1. Up to date with the base branch
2. Local checks pass
3. Tests cover the change
4. Code review
5. Security review, when the change touches a sensitive surface
6. UX review, when the change is user-facing
7. **Your go-ahead**
8. Push, with CI watched to completion
9. Verification in the deployed environment
10. Pull request opened and board updated

`/ship` never merges. You review and merge the pull request yourself.

### End

```
/wrap-up
```

This records what changed, captures follow-ups as tasks, lists uncommitted and unpushed work, and gives you the first message for the next session.

## Part 5: Later

### Add an agent

Run `/foundry-init` again and choose the roles to add. It reuses the project facts it recorded the first time.

### Add a domain specialist

Run `/foundry-init` and answer yes to the specialist question. It asks for the role, the source files the specialist must ground in, the standard it holds, and whether it is read-only.

### Refresh after a foundry update

```bash
cd agent-foundry && git pull && ./install.sh
```

Then run `/foundry-init` in the project. It sees the newer version and offers a refresh: the role craft updates and your project blocks carry over unchanged. It shows a diff and asks before writing each file.

### Check a project

```bash
bash ~/.claude/skills/foundry-init/foundry/check-project.sh .
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `/foundry-init` is not recognized | Run `./install.sh`, then start a new session |
| The run ends with a `foundry-pending/` folder | Writes into `.claude/` were denied. Review the files, then run the move commands in `foundry-pending/README.md`. |
| The agents don't appear | Start a new session. Agents load at session start. |
| An agent is too generic | Its project blocks are thin. Edit them, or add code and documents and refresh. |
| The installer skipped a skill | You have a skill with the same name from another source. Rename yours, or run `./install.sh --force` to replace it. |
| Too many permission prompts | Add the project's own safe commands to the `allow` list in `.claude/settings.json` |
| An agent reads an `.env` file through the shell | The `deny` rules in `settings.json` cover the Read tool. They do not stop a shell command such as `cat`. Keep real secrets out of the project directory where you can. |
