# Agent catalog

Every role lives in `agents/<role>.md` as a template. `/foundry-init` generates `.claude/agents/<slug>-<role>.md` from it. An agent you wrote by hand and then adopted keeps its own name.

## Summary

| Role | Tools | Edits code | Project blocks filled at init |
|---|---|---|---|
| [dev](#dev) | All | Yes | `workflow`, `protected` |
| [code-review](#code-review) | Read, Grep, Glob, Bash | No | `blast-radius` |
| [security](#security) | Read, Grep, Glob, Bash, WebFetch, WebSearch | No | `risk-map` |
| [ux](#ux) | Read, Grep, Glob, Bash, WebFetch, WebSearch | No | `user`, `brand` |
| [pm](#pm) | Read, Grep, Glob, WebFetch, WebSearch | No | `product` |
| [architect](#architect) | Read, Grep, Glob, Bash, WebFetch, WebSearch | No | `system` |
| [qa](#qa) | All | Tests only | `test-setup` |
| [devops](#devops) | All | Yes, with confirmation | `environments` |
| [tracker](#tracker) | All | Board only | `board`, `status` |
| [social](#social) | Read, Grep, Glob, WebFetch, WebSearch | No | `audience`, `voice` |
| [specialist](#specialist) | Read, Grep, Glob, Bash | Configurable | `identity`, `sources`, `principles`, `findings` |

All agents use `model: opus` and `memory: project`.

**On launching other agents:** only `dev` can, and only to consult an advisor mid-task. The read-only agents have no `Agent` tool in their tool lists. The `qa`, `devops`, and `tracker` agents set `disallowedTools: Agent`. Reviews that gate shipping are launched from the main session. See [How agents work together](getting-started.md#how-agents-work-together).

**On tools:** an agent with a restricted tool list can still read and write its own memory. Claude Code enables that when `memory` is set. Agents with no `tools` line inherit every tool available, including MCP tools, which the tracker needs to reach a board.

**On read-only agents:** the tool list is the enforcement. An agent with no Edit or Write tool cannot change project files. Agents that have Bash are also told to use it for inspection only. That part is an instruction and not a technical limit.

## The core five

### dev

Implements features, fixes, and refactors, and ships through the project's workflow.

- States a blast-radius analysis before touching a protected surface
- Consults the UX agent mid-build on anything user-facing. The final UX review comes from the main session.
- Never commissions its own review
- Builds to the blueprint. Stops and reports when the plan can't be followed.
- Verifies by observation: typecheck, build, run, screenshot, curl
- Never merges, and never pushes unless asked

**Say:** "build", "add", "fix", "implement", "refactor", "ship to staging"

### code-review

Reviews a diff for correctness bugs and cleanup. It optimizes for recall and refuses to pad the list.

- Fetches first and reviews against the remote base, because local branches go stale
- Runs five angles: line-by-line correctness, removed behavior, cross-file impact, conformance to the blueprint, cleanup
- Flags a dependency, structure, or data model that no recorded decision covers
- Reports `file:line`, the bug in one sentence, and a concrete failure scenario

**Say:** "review this", "check this diff", "anything wrong before I merge"

### security

Defensive security review of a change or the whole app.

- Works from a risk map specific to the project
- Rates each finding Critical, High, Medium, or Low, with the attack scenario and a remediation
- Runs static analysis and safe local scanners only. Never active scans, never against production.

**Say:** "security review", "is this safe", "check for vulnerabilities"

### ux

The user experience champion. Its loyalty is to the person using the product.

- Reviews against eight lenses: clarity, emotional fit, friction, states, accessibility, responsive behavior, consistency, trust
- Looks at the running app, not only the code
- Rates each issue blocker, major, minor, or polish, with the exact copy or interaction to use

**Say:** "review the UX", "how does this feel", "critique this screen"

### pm

Turns fuzzy ideas into buildable scope and pushes back on what isn't worth building.

- Confirms what exists in the code before proposing anything
- Delivers the problem, the job to be done, an MVP cut, user stories, acceptance criteria, metrics, and risks
- Ranks three to five options and recommends one

**Say:** "should we build", "spec this", "what's the MVP", "prioritize"

## Additional roles

### architect

Decides how something gets built. The pm agent decides whether.

- Owns the blueprint, the plan the owner approved for how the project gets built
- Runs a sustainability check on any plan that sets direction
- Reads the code before designing
- Compares options only when they differ in substance, and recommends one
- Plans in steps small enough for one pull request each, with acceptance criteria
- Drafts a decision record for each real choice

**Say:** "how should I build", "design this", "plan this"

### qa

Writes and runs tests, and judges the result the way a user would.

- Proves each regression test fails without the fix
- Gets a real baseline before blaming a change
- Treats a run that passes every check but delivers a poor experience as a failure

**Say:** "test this", "add tests", "does this work end to end"

### devops

Deploys, diagnoses CI, and verifies the running environment.

- Treats the running system as the truth and repo files as intent
- Reads the health endpoint, the page, and the logs after every deploy
- Needs a go-ahead for anything that changes production or touches data

**Say:** "is it live", "did it deploy", "why is CI red"

### tracker

Keeps the planning board honest. It is a bookkeeper and not a strategist.

- Verifies before marking anything Done
- Reports drift between the board and reality
- Ends every run with a changelog of what it changed
- Supports Airtable, GitHub Issues or Projects, or a markdown file

**Say:** "update the board", "what am I working on", "mark this done"

### social

Drafts and critiques social and marketing content.

- Leads with the hook, names the format and the emotional beat
- Pulls real audience language from the communities where the audience talks
- Never fabricates features, statistics, or testimonials

**Say:** "post ideas", "a hook", "a caption", "what should we post"

## specialist

A template for an expert in your project's own domain. Software roles cover software. Many projects also need someone who knows the domain.

Examples:

| Project | Specialist |
|---|---|
| A conversational AI product | An experience director who reads session transcripts and judges whether the conversation feels natural |
| An orchestration engine | A mechanics auditor who finds races, stale state, and limits a user can feel |
| A physical installation | A hardware technician who gives wiring steps with a measurable check after each one |
| A data pipeline | A data-quality reviewer who checks outputs against known invariants |
| A regulated product | A compliance reviewer who checks changes against the rules that apply |

Four things make a specialist useful:

1. **Source material.** The exact files it must read, and what each is the authority on.
2. **Principles.** Rules of the domain that are specific enough to produce a finding.
3. **What counts as a finding.** The problem classes, each described by its symptom.
4. **A fixed output format** that ends with one specific recommendation.

Specialists work best when invoked with a focus question.

## Choosing agents for a project

| Project | Suggested agents |
|---|---|
| An idea with no code yet | pm, architect, and ux if people will use an interface |
| A web app with users | The core five, plus devops and tracker |
| A prototype | dev, code-review, pm |
| A library or a CLI tool | dev, code-review, qa, architect |
| An AI or conversational product | dev, code-review, qa, and a specialist for experience quality |
| A hardware project | dev, code-review, and a specialist for the build |
| A product with a marketing effort | Add social |
