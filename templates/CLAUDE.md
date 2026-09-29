# {{PROJECT_NAME}}

{{ONE_LINER}}

<!-- include if: build -->
**Stack:** {{STACK}}
<!-- /include -->

<!-- include if: idea -->
## Stage: idea

Nothing is built yet. This project is being planned.

- **The idea lives in `docs/idea/BRIEF.md`.** It is the source of truth. Read it before advising.
- **Ground in the brief.** There is no code to read yet. Label every assumption you make.
- **Advisors recommend. The main session records.** When the owner decides something, the main session updates the brief: the item moves from Open questions to Decided, with the date and the reason.
- **"I don't know yet" is a valid answer.** Record it as an open question. Do not fill the gap with a guess.
- **Do not choose a stack until the owner asks for one.** Comparing options is fine.
- `/idea` continues the interview and gathers a round of perspectives.
- `/blueprint` plans how the first version gets built. `/scaffold` builds its first milestone once the owner has approved the plan.
- No code is written before the blueprint is approved.
<!-- /include -->

<!-- include if: blueprint -->
## The blueprint: build to it

`docs/plan/BLUEPRINT.md` records how this project gets built: the scope of the first version, the stack, the structure, and the milestones. `docs/plan/DECISIONS.md` records each choice and the reason for it. The owner approved them.

- **Read both before planning or building.**
- **Build the current milestone, and nothing beyond it.**
- **A departure from the blueprint is the owner's decision.** A new dependency, a different structure, a different data model, or a different way to store state is a departure. Stop and report it. Do not make the change and carry on.
- **An accepted departure becomes a decision entry,** and the blueprint is updated to match. The old entry is marked superseded and is never rewritten.
- The architect owns the blueprint. Only the owner accepts a decision.
<!-- /include -->

## The team

This project has specialist agents in `.claude/agents/`. Route work to them. The main session coordinates and owns the handoffs between them.

| Agent | Launch it when |
|---|---|
{{FILL: One row per agent in `.claude/agents/`, including agents the owner wrote by hand. Order: dev, architect, code-review, security, qa, ux, pm, devops, tracker, social, then specialists and hand-written agents. Format: "| `<name>` | Code needs to be written, fixed, or refactored |". Write the trigger as a plain condition. For a hand-written agent, take the trigger from its own description.}}

Rules for routing:

- Advisory agents review and recommend. They do not edit code.
- Treat an agent's recommendations as first-class. If the work diverges from them, say why.
- **Reviews that gate shipping are launched from the main session.** That covers code review, security review, and the final UX review. The owner sees the findings first-hand, and no agent commissions its own review.
- **A building agent may consult an advisor mid-task.** It reports what it asked and what the advisor answered.
- Each agent keeps its own memory in `.claude/agent-memory/`, in a folder named after the agent. That directory is local and is not committed. Renaming an agent leaves its memory behind.

<!-- include if: build -->
## Workflow

{{FILL: The release flow chosen at init, written as rules. Name the branches, what a push to each one triggers, and how production ships.}}

- Commit and push only when asked. Approval in one context does not extend to the next.
- Never merge a pull request from a session. Open it and leave it for review.
- Fetch before comparing branches. Local refs go stale.
- Stage explicit paths. Never `git add -A`.

## Commands

```bash
{{FILL: The project's real commands, one per line with a short comment: install, dev, typecheck, lint, test, build. Mark any that do not exist yet.}}
```

## Protected surfaces: state the blast radius before changing these

{{FILL: The list of high-risk paths with one line each on why. Use the same list the agents carry. If the project has no users yet, say so and name what becomes protected at launch.}}

Before a change to any of these, state which existing users or data it touches and why it is safe.
<!-- /include -->

<!-- include if: tracker -->
## Project tracking: do this every working session

The planning board is the system of record for what is in flight. Keep it current with `{{SLUG}}-tracker`.

- **At the start of a session,** before picking up a task: launch `{{SLUG}}-tracker` to report what is In Progress and Next, and to mark what is being started. `/kickoff` does this.
- **When work lands** (merged, deployed, flag flipped, or abandoned): launch `{{SLUG}}-tracker` to record it.
- **When new work surfaces mid-session** (a bug, a risk, a follow-up): launch `{{SLUG}}-tracker` to capture it as a task.

Do not update the board by hand from the main session. Route it through `{{SLUG}}-tracker` so status meanings stay consistent.

### Status meanings

`Backlog → Next → In Progress → Review → Done`, plus `On Hold` for work paused on purpose.

**"Code is written" is not Done.** A feature merged behind a feature flag that is off is **Review**. Done means users can reach it.
<!-- /include -->

<!-- include if: ux -->
## User experience: check with the UX champion on anything user-facing

`{{SLUG}}-ux` is the user experience champion. Its loyalty is to {{FILL: the user in their moment, in one phrase}}.

- **When a change touches what the user sees or does,** `{{SLUG}}-ux` is consulted during the build and reviews again before the work counts as done. The main session launches that final review.
- **When the user asks for a UX review, design review, or critique,** launch `{{SLUG}}-ux`.
- It is advisory and read-only. It reviews and recommends. It does not implement.
<!-- /include -->

<!-- include if: build -->
## Before shipping

`/ship` runs these gates in order and stops at the first failure. The main session launches each review.

1. Local checks pass
2. `{{SLUG}}-code-review` on the real diff against the remote base
3. `{{SLUG}}-security` when the change touches auth, payments, uploads, storage, headers, middleware, secrets, or dependencies
4. `{{SLUG}}-ux` when the change is user-facing
5. The architect checks the change against the blueprint, when the project has one
6. Owner go-ahead, then push, then verification in the deployed environment

{{FILL: Remove the gates whose agents are not installed, and renumber.}}
<!-- /include -->

## Ground truth

The board and the documents describe intent. The repo and the running environments describe reality. When they disagree, reality wins and the record is what changes.

- **Never infer that something exists because a file describes it.** A manifest may never have been applied. A job that is defined may never have run. Check the running system.
- **Never infer that a step did its job because it exited zero.** A green step reports on the work it performed, not on whether the result is correct. Ask what would exist if the step had really worked, then go look for it.
- **Never claim something works without having observed it.** Say what was verified, what was inferred, and what is still open.
- **Never hardcode what moves.** Resolve names, leaders, and addresses at time of use.

## Project-specific rules

{{FILL: Rules this project has earned that fit nowhere above, such as how migrations reach an environment or which tool is the only approved path for an operation. Take them from existing documents and from the interview. If there are none yet, write "None recorded yet. Add rules here as the project earns them."}}
