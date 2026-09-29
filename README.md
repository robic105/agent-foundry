# agent-foundry

An operating system for building apps with a team of AI agents in [Claude Code](https://claude.com/claude-code).

Install it once. In any new project, type `/foundry-init` and get a team of specialist agents that already know the project: its stack, its workflow, its users, and the code that must not break.

## What you get

- **Ten agent roles plus a specialist template.** Developer, code review, security, UX, product manager, architect, QA, DevOps, project tracker, and social. Each is a role template that gets tailored to the project.
- **Four skills.** `/foundry-init` sets a project up. `/kickoff`, `/ship`, and `/wrap-up` run a working session.
- **Project scaffolding.** A `CLAUDE.md` with routing rules, a baseline permissions file, a pull request template, issue templates, and a CI workflow.
- **Validators.** One checks a generated project. One checks this kit and blocks private details from being published.

## Quick start

### 1. Install, once per computer

```bash
git clone https://github.com/robic105/agent-foundry.git
cd agent-foundry
./install.sh
```

This copies the four skills into `~/.claude/skills/`. It touches nothing else.

### 2. Set up a project, once per project

Open the project in Claude Code and type:

```
/foundry-init
```

It surveys the repo, asks a few questions, and writes the agents and project files. Review what it generated, then start a new session so the agents load.

### 3. Work

| You type | What happens |
|---|---|
| `/kickoff` | Checks git health, loads what is in flight, agrees on one objective |
| "Add a share button to the footer" | The dev agent builds it and consults the UX agent |
| "Review this before I push" | The code-review agent reviews the real diff against the remote base |
| "Is this safe?" | The security agent reviews the change |
| "Should we build video upload?" | The pm agent scopes it and makes a recommendation |
| `/ship` | Runs the review gates, asks for a go-ahead, pushes, verifies, opens a pull request. It never merges. |
| `/wrap-up` | Records what changed, captures follow-ups, lists loose ends |

Full walkthrough: [docs/getting-started.md](docs/getting-started.md)

## How it works

Most of an agent's value comes from project context. A generic security reviewer knows about CSRF. A useful one knows that this project's webhook route is exempt from CSRF and checks that the exemption stays narrow.

So each role template has two kinds of content:

```markdown
## Review angles (run them all)          <- role craft: the same in every project
1. Line-by-line correctness: ...

<!-- foundry:project blast-radius -->
## Blast-radius lens                     <- project context: written by /foundry-init
{{FILL: The specific paths where a mistake reaches every user...}}
<!-- /foundry:project -->
```

`/foundry-init` reads the repo, fills every project block with real files and commands, and writes the result to `.claude/agents/<project>-<role>.md`. The markers stay in the file, so a later refresh can update the role craft and keep the project context.

## The agents

| Role | What it does | Edits code |
|---|---|---|
| `dev` | Implements features and fixes, ships through the project's workflow | Yes |
| `code-review` | Reviews a diff for correctness bugs and cleanup | No |
| `security` | Defensive security review, static analysis only | No |
| `ux` | Champions the user: flows, copy, states, accessibility, brand | No |
| `pm` | Scopes features, prioritizes, writes specs | No |
| `architect` | Plans how to build something, records decisions | No |
| `qa` | Writes and runs tests, judges whether the result is good | Tests only |
| `devops` | Deploys, diagnoses CI, verifies the running environment | Yes, with confirmation |
| `tracker` | Keeps the planning board in line with reality | Board only |
| `social` | Drafts and critiques social and marketing content | No |
| `specialist` | A template for an expert in your project's own domain | Configurable |

Details: [docs/agents.md](docs/agents.md)

## Principles

The agents share a set of working rules. The main ones:

1. **Verify with evidence.** Nothing works until it has been observed working.
2. **A green check is not proof.** A step that exits zero reports on the work it performed, not on whether the result is correct.
3. **Reality beats the record.** When the board or a document disagrees with the running system, the record is what changes.
4. **State the blast radius** before touching anything that every user depends on.
5. **Advisory agents don't edit.** Reviewers recommend. The developer implements.
6. **Never merge, never push unasked.** The owner approves what ships.

Full list: [docs/principles.md](docs/principles.md)

## Repository layout

```
agent-foundry/
├── install.sh                 installs the skills into ~/.claude/skills/
├── VERSION
├── agents/                    role templates, one per role
├── skills/
│   ├── foundry-init/          generates a project's agents and files
│   ├── kickoff/               starts a session
│   ├── ship/                  review gates, push, verify, pull request
│   └── wrap-up/               ends a session
├── templates/                 copied into each project by /foundry-init
│   ├── CLAUDE.md
│   ├── settings.json          baseline permissions
│   ├── CURRENT-STATE.md       session handoff, for projects without a tracker
│   └── github/                pull request, issue, and CI templates
├── scripts/
│   ├── check-project.sh       validates a generated project
│   └── validate.sh            validates this kit
└── docs/
```

## Updating

```bash
cd agent-foundry
git pull
./install.sh
```

Then run `/foundry-init` in a project. It detects the newer version and offers to refresh that project's agents, keeping the project context.

## Customizing

Edit the templates in `agents/` to change how a role works everywhere. Edit a generated agent in a project's `.claude/agents/` to change it for that project only. See [docs/customizing.md](docs/customizing.md).

## Uninstalling

```bash
./install.sh --uninstall
```

This removes the skills. Agents already generated inside your projects stay where they are.
