# Getting started

This guide covers installing agent-foundry, then four ways to start: from an idea, from a new project, from an existing project, and from a project that already has agents you wrote by hand. It ends with day-to-day use.

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

The installer copies seven skills into `~/.claude/skills/`: `idea`, `blueprint`, `scaffold`, `foundry-init`, `kickoff`, `ship`, and `wrap-up`. It bundles the agent templates inside the skills that use them, so they work from any project.

The installer only replaces skills it installed itself. If you already have a skill named `kickoff` from somewhere else, the installer skips it and tells you.

## Part 2: Start from an idea

Use this when you have an idea and little else. You don't need a stack, a name, or a plan. This part takes you from the first conversation to the first running code.

| Step | Skill | Result |
|---|---|---|
| 1 to 4 | `/idea` | A brief, in your words |
| 5 and 6 | `/blueprint` | An approved plan for the first version |
| 7 | `/scaffold` | The first milestone, running |
| 8 | `/foundry-init` | The full team, generated from the code |

### Step 1: Make a folder and run the skill

```bash
mkdir my-idea && cd my-idea
```

Open the folder in Claude Code and type:

```
/idea
```

You can also put the idea on the same line: `/idea a jar sensor that tells me when my sourdough starter peaks`.

### Step 2: Talk

The skill opens with one question: tell me about the idea. After that it asks one question at a time about what you haven't covered.

| It asks about | It never asks about |
|---|---|
| What prompted the idea | Stack |
| Who it is for, and the moment they are in | Hosting |
| What they do today, and what is wrong with it | Tools |
| What the thing does | |
| The smallest version worth showing someone | |
| What it is not | |
| Constraints and worries | |

**"I don't know" is a valid answer to every question.** It gets recorded as an open question. The interview captures what you say and does not judge it. You can stop at any point.

### Step 3: Read the brief

The skill writes `docs/idea/BRIEF.md` in your words. It has three sections that keep the idea honest:

| Section | Holds |
|---|---|
| **Decided** | Only what you decided, with the date and the reason |
| **Open questions** | Everything not known yet, with why it matters |
| **Parked** | Ideas set aside, with the reason |

Tell the skill what is wrong or missing and it corrects the brief.

### Step 4: Get a round of perspectives

The skill offers to gather three perspectives on the brief. It asks first, because a round launches three agents and takes a few minutes.

| Perspective | What it answers |
|---|---|
| **Product** | Is the problem real? What is the smallest version worth building? What should be cut? |
| **User experience** | What is the person's moment like from start to end? Where is the friction? |
| **Architecture** | What forms could this take? What should be prototyped first? Which decisions can wait? |

The result is saved to `docs/idea/rounds/<date>.md`: where they agree, where they disagree, and at most five questions for you. The skill then takes you through those questions one at a time.

A recommendation from an agent is not a decision. Nothing moves to Decided until you say so.

### Step 5: Plan the build

When the brief says who it is for, what it does, and what the smallest useful version is, plan how to build it:

```
/blueprint
```

No code is written in this step. If the brief is missing one of those answers, the skill asks you for it, and sends you back to `/idea` if you don't know yet.

It asks a few questions about the build. "No preference" is a valid answer to each.

| It asks | Why |
|---|---|
| Which languages and tools do you already know? | The plan leans on them |
| What will you spend to run this each month? | It rules options in or out |
| Where does it need to run? | A phone, a browser, a device, a server |
| Is there a date it has to work by? | It limits the scope |
| Will anyone else work on the code? | It affects the workflow |

Then it runs the planning, which takes about six agent runs. It asks before it starts.

| Step | Who | Produces |
|---|---|---|
| Scope | pm | What the first version includes, and what it leaves out |
| Draft | architect | Two or three options compared, a stack, a structure, risks, milestones |
| Challenge | dev, pm, and ux or security when relevant | What will be painful, unsafe, or unnecessary |
| Revise | architect | An answer to every concern |

### Step 6: Approve the plan

The skill presents the plan and takes you through the decisions one at a time: the stack, where it runs, the data store, the workflow. Each comes with the recommendation and the alternative.

You can approve the plan, approve it with changes, or leave it as a draft. Nothing is built from a draft.

It writes two files:

| File | Holds |
|---|---|
| `docs/plan/BLUEPRINT.md` | The scope, the options, the stack, the structure, the risks, the sustainability check, and the milestones |
| `docs/plan/DECISIONS.md` | One entry per decision: the context, the choice, what was rejected, and how to back out |

The parts that protect you from an unsustainable path:

| Part of the blueprint | What it does |
|---|---|
| Options considered | Always includes the simplest thing that could work |
| "How we would back out" | Recorded for every choice in the stack |
| Sustainability check | Can you maintain it alone? What does it cost at ten times the use? What breaks first? What locks you in? |
| Risks | The riskiest assumption comes first, and an early milestone tests it |
| Decisions that can wait | Choices left open on purpose, with what would force them |

### Step 7: Build the first milestone

```
/scaffold
```

It builds milestone 0 and nothing more. M0 is a walking skeleton: the thinnest slice that runs end to end, with the tests and checks in place.

1. The dev agent builds M0 to the blueprint.
2. The main session runs every command itself and checks each "done when" criterion.
3. The architect compares the result with the blueprint. The code-review agent reviews the code.
4. Blocking findings get one round of fixes.
5. You decide on each departure from the plan: accept it, or send it back.

Nothing is committed. Review the code first.

### Step 8: Generate the full team

```
/foundry-init
```

The project now has code, so the agents are generated from it. This run:

1. Takes the stack and the workflow from the blueprint
2. Offers the building agents: dev, code-review, security, qa, devops
3. Rewrites any planning agents so they describe what was built
4. Adds the build sections to `CLAUDE.md`, plus the GitHub templates
5. Reports where the code and the blueprint differ

Start a new session so the agents load. Then `/kickoff` reports the next milestone.

### The plan after the scaffold

The blueprint stays in force. A departure from it is your decision.

| Who | What it does |
|---|---|
| dev | Stops and reports when the plan can't be followed. Lists every departure in its report. |
| code-review | Flags a dependency, structure, or data model that no decision records |
| architect | Owns the blueprint. Says what a departure costs now and later. |
| `/ship` | Has the architect check the change against the blueprint before the push |
| You | Accept a departure, which adds a decision entry, or reject it |

A decision entry is never rewritten. A later decision supersedes it, so the record shows how the project got where it is.

### Optional: a planning team that remembers

`/idea`, `/blueprint`, and `/scaffold` work without any agents installed. They run each role from the kit's templates.

If you want planning agents that keep memory between sessions, run `/foundry-init` at any point before there is code. It sets up pm, architect, and ux from the brief. Start a new session so they load. The three skills then use those agents.

| You type | What happens |
|---|---|
| `/idea` | Picks up where you stopped and works through the open questions |
| `/kickoff` | Reports what is known, what was decided last, and what to do next |
| "Ask the architect what I should prototype first" | The planning agent answers from the brief |
| `/wrap-up` | Records the session's decisions in the brief |

## Part 3: Set up a new project that has code

### Step 1: Create the project

Scaffold it with your stack's tooling, such as `npx create-next-app`, and run `git init`. The more code `/foundry-init` can read, the more specific the agents will be.

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
│   └── foundry.json                   what was installed, the stage, and the version
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

If something is wrong, edit the file. Your edits inside the `foundry:project` blocks survive later updates.

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

## Part 4: Set up an existing project

Run `/foundry-init` in the project. The steps in Part 3 apply, with these differences:

- **Existing `CLAUDE.md`:** the skill keeps your content and adds only the sections that are missing.
- **Existing `.claude/settings.json`:** the skill merges its rules into yours and removes nothing.
- **Existing GitHub templates:** left as they are.
- **CI:** the skill adds `ci.yml` only when no workflow runs checks on pull requests. A workflow that only deploys does not count. If the project's checks fail today, the new workflow will fail too, and the report says so.

The survey also reports problems it notices, such as missing tests or configuration that contradicts the code.

**One thing to check before you commit:** the baseline permissions deny reading `.env` files. If one of your agents reads an `.env` file as part of its work, remove that file's line from the `deny` list in `.claude/settings.json`.

## Part 5: Adopt agents you wrote by hand

If the project has agents in `.claude/agents/` that you wrote yourself, `/foundry-init` offers three choices for each one that does a foundry role:

| Choice | What happens | Memory |
|---|---|---|
| **Adopt it** (recommended) | The agent is converted in place | Kept |
| **Keep it as it is** | Nothing changes. The role is skipped. | Kept |
| **Generate a second agent beside it** | A new agent under a different name | The new agent starts empty |

An agent's memory lives in a folder named after the agent. That is why adoption never renames anything.

### What adoption changes

| Part of your agent | Outcome |
|---|---|
| Name | Kept exactly |
| Description, model, tools | Kept |
| What you wrote about the project | Moved into project blocks, in your words |
| Project content that fits no block | Kept in a `notes` block |
| General working method | Replaced by the foundry's role craft |
| A method of yours that the foundry lacks | Kept in the `notes` block, and reported as something the kit could gain |
| Memory instructions and hardcoded memory paths | Dropped. Claude Code supplies these when `memory` is set. |
| A color that is not valid | Replaced, and reported |

### How it protects your work

1. It stops if the agent file has uncommitted changes. Git history is the backup.
2. It accounts for every line. You get a table of what moved, what was replaced, and what was dropped.
3. It shows the diff and waits for your go-ahead, one agent at a time.
4. It reports statements in your agent that the code now contradicts. It does not change them.

An agent that matches no foundry role, such as a domain expert, is left as it is unless you ask for it to be adopted as a specialist. Either way it appears in the team table in `CLAUDE.md`.

To go straight to adoption: `/foundry-init adopt`

## Part 6: A working session

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
7. Blueprint conformance, when the project has a blueprint
8. **Your go-ahead**
9. Push, with CI watched to completion
10. Verification in the deployed environment
11. Pull request opened and board updated

`/ship` never merges. You review and merge the pull request yourself.

### End

```
/wrap-up
```

This records what changed, captures follow-ups as tasks, lists uncommitted and unpushed work, and gives you the first message for the next session.

## Part 7: Later

| You want to | Do this |
|---|---|
| Add an agent | Run `/foundry-init` and choose the roles to add |
| Add a domain specialist | Run `/foundry-init` and answer yes to the specialist question |
| Update the agents after the code has changed a lot | `/foundry-init resurvey` |
| Update after a new foundry version | `git pull && ./install.sh` in the kit, then `/foundry-init` in the project |
| Check a project | `bash ~/.claude/skills/foundry-init/foundry/check-project.sh .` |

**Re-survey** rewrites the facts that come from the code: paths, commands, surfaces, the stack. It keeps what you wrote.

**Refresh** updates the role craft from a newer foundry version. It keeps every project block unchanged.

Both show a diff and ask before writing each file.

## What the skills cost

Each agent run uses part of your Claude usage allowance. The planning skills launch several agents, so they use more than ordinary work does.

| Skill | Agent runs | Time |
|---|---|---|
| `/idea`, interview only | None | As long as you talk |
| `/idea`, with a round of perspectives | 3 | A few minutes |
| `/blueprint` | 6 or 7 | 15 to 35 minutes |
| `/scaffold` | 3 or 4, plus one round of fixes | 15 to 30 minutes |
| `/foundry-init` | None | 5 to 10 minutes |
| `/ship` | One per review gate | Depends on the change |

Each of these skills tells you what it will launch and asks before it starts.

Keep the computer awake during a long run. If it goes to sleep, the agents that are running get cut off.

If a run is cut off, by sleep or by a usage limit, nothing is lost. `/blueprint` continues a draft, and `/scaffold` picks up a partly built milestone without rebuilding it. Run the skill again after the limit resets.

To use less: run `/blueprint` once the brief is settled, and skip the round of perspectives in `/idea` if you plan to run `/blueprint` soon after, since the planning covers the same ground in more depth.

## How agents work together

| Situation | Who launches the agent |
|---|---|
| The dev agent needs a UX opinion mid-build | The dev agent may launch the UX agent itself |
| A review that gates shipping: code review, security review, final UX review | The main session, always |
| Any other handoff | The agent names it in its report, and the main session routes it |

Reviews come through the main session so that you see the findings first-hand. If the dev agent launched its own review, you would see only its summary of the result.

Only the dev agent can launch another agent. Nesting is capped at two layers in `.claude/settings.json`: a building agent and one advisor.

## Troubleshooting

| Problem | Fix |
|---|---|
| A skill such as `/idea` or `/foundry-init` is not recognized | Run `./install.sh`, then start a new session |
| The run ends with a `foundry-pending/` folder | Writes into `.claude/` were denied. Review the files, then run the move commands in `foundry-pending/README.md`. |
| The agents don't appear | Start a new session. Agents load at session start. |
| `/scaffold` stops and says the blueprint is a draft | Run `/blueprint` and approve the plan |
| `/blueprint` sends you back to `/idea` | The brief does not yet say who it is for, what it does, or what the smallest version is |
| A long run stalls with no progress | The computer may have gone to sleep. Stop the run and start the skill again. It continues from where it was cut off. |
| An agent is too generic | Its project blocks are thin. Edit them, or run `/foundry-init resurvey` once there is more code. |
| An agent lost its memory | It was renamed. Rename it back, or move its folder in `.claude/agent-memory/` to the new name. |
| The installer skipped a skill | You have a skill with the same name from another source. Rename yours, or run `./install.sh --force` to replace it. |
| Too many permission prompts | Add the project's own safe commands to the `allow` list in `.claude/settings.json` |
| An agent reads an `.env` file through the shell | The `deny` rules in `settings.json` cover the Read tool. They do not stop a shell command such as `cat`. Keep real secrets out of the project directory where you can. |
