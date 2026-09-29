---
name: scaffold
description: Build the first milestone of an approved blueprint, a walking skeleton, then verify it and review it against the plan. For a project with a plan and no code yet. Use when the user types /scaffold.
disable-model-invocation: true
---

# Scaffold

Turn an approved blueprint into the first running code. Build milestone 0 and nothing more.

The dev role template is bundled next to this file:

```
${CLAUDE_SKILL_DIR}/foundry/agents/     role templates
```

If `${CLAUDE_SKILL_DIR}/foundry/` is missing, stop and tell the owner to run `./install.sh` from their agent-foundry checkout.

What the owner typed after the command: `$ARGUMENTS`

## Rules for this skill

- **Build to the blueprint.** The stack, the structure, and the layout come from `docs/plan/BLUEPRINT.md`.
- **Milestone 0 only.** No feature beyond what M0 lists. A thin scaffold that runs beats a full one that doesn't.
- **A departure from the blueprint is the owner's decision.** If the plan can't be followed, stop and report. Do not pick a different library, structure, or data model and carry on.
- **Verify by observation.** A command that was not run did not pass.
- **You launch the reviews.** The agent that built the scaffold does not commission its own review.
- **Respect what the owner ruled out.** If the brief or the blueprint keeps certain data away from online services, no agent reads that data. Work from made-up sample data.
- **No secrets in files.** Environment variable names go in `.env.example`. Values go nowhere in the repo.
- **Do not commit or push** unless the owner asks.

## Step 1: Check the preconditions

| Check | If it fails |
|---|---|
| `docs/plan/BLUEPRINT.md` exists | Stop. Recommend `/blueprint`. |
| Its status is "approved" | Stop. Say the blueprint is a draft and needs the owner's approval through `/blueprint`. |
| M0 is "not started" or "in progress" | Stop. M0 is done. Recommend `/kickoff` for the next milestone. |
| The repo has no source code, or only a partial M0 | Stop. Say this skill is for the first build, and recommend `/kickoff`. |
| Every step the blueprint gives the owner to do before M0 is done | Stop. List those steps and what each one needs from the owner. Do not do them on the owner's behalf, and do not assume their results. |

If the folder is not a git repository, offer `git init`, unless the blueprint chose to work without git.

**Resuming a partial M0.** A run can be cut off. If part of M0 exists, find out what is there before you launch anything: which files M0 lists exist, and whether the check commands run. Do not rebuild what exists. Set M0's status to "in progress" and continue from the first step that was not completed. Ask the builder only for what is missing.

Read the blueprint, `docs/plan/DECISIONS.md`, and the brief. Tell the owner what M0 will build and what it leaves out, and that the run launches a builder and two or three reviewers. Get a go-ahead.

Once the builder starts, set M0's status to "in progress" in the blueprint, so an interrupted run leaves a true record.

## Step 2: Build M0

Launch the builder:

- If this project's dev agent is installed and available in this session, launch it.
- Otherwise launch a `general-purpose` agent. Build its prompt from the role template at `${CLAUDE_SKILL_DIR}/foundry/agents/dev.md`, with this note: "Ignore the template tokens and fill instructions. The blueprint is your project context."

Give the builder the full blueprint and the decisions, and these instructions:

1. Build milestone 0 as the blueprint describes it, and nothing beyond it.
2. Use the stack and the repo layout from the blueprint.
3. Use the stack's own tooling to create the project where there is one.
4. Pin dependency versions and commit the lockfile.
5. Write a `.gitignore` that excludes dependencies, build output, and `.env` files.
6. Write `.env.example` with variable names only.
7. Make the check commands real: test, lint, and typecheck where the stack has one. Add at least one test that exercises the slice.
8. Write a README with the commands to install, run, and check the project.
9. Run every command you added and report what you observed.
10. If the blueprint can't be followed, stop. Report what blocked you, what you would do in its place, and why. Do not proceed on the alternative.

Ask the builder to end its report with two lists: what it verified by running, and every place it departed from the blueprint, however small.

## Step 3: Verify it yourself

Do not rely on the builder's report. Run the commands from the README and observe:

| Check | Evidence |
|---|---|
| Install | The command completes. A lockfile exists. |
| Tests | The pass and fail counts |
| Lint and typecheck | The output |
| Run | The slice working end to end: a response, a page, a reading |
| Secrets | No value in any tracked file. `.env` is ignored. |

Then check each "Done when" criterion for M0 in the blueprint. Record each as observed or not observed.

## Step 4: Review

Launch these in a single message. Use the project's agents if they are available, or `general-purpose` agents with the role templates.

| Reviewer | Launch when | Asked to find |
|---|---|---|
| **architect** | Always | Every place the scaffold departs from the blueprint or a recorded decision. Whether the structure will hold the later milestones. |
| **code-review** | Always | Correctness problems in what was written. Anything beyond M0. |
| **security** | The blueprint handles accounts, payments, or private data | What must be right from the first commit. |

## Step 5: Fix once

Send blocking findings to the builder, then repeat Step 3 for what changed. One round. If blockers remain after it, stop and report them to the owner.

## Step 6: Settle the departures

List every departure from the blueprint, from the builder and from the architect. For each one, give the owner a choice:

| Choice | What you do |
|---|---|
| Accept it | Add a decision entry with status "accepted", and update the blueprint to match |
| Reject it | Send it back to the builder to follow the blueprint |

**Non-interactive runs.** Record each departure as a decision entry with status "proposed". Change nothing in the blueprint.

## Step 7: Record

In `docs/plan/BLUEPRINT.md`:

- Set M0's status to "done" with the date, only if every "Done when" criterion was observed. Otherwise set it to "in progress" and list what is missing.
- Set "Last updated".

## Step 8: Report

```
Scaffold: M0 <done | in progress>

Built: <what exists now, one line per part>
Verified by running:
  Install: <result>
  Tests: <pass and fail counts>
  Lint / typecheck: <result>
  Run: <what was observed>
Done-when criteria: <count observed> of <count>
Departures from the blueprint: <count>. <accepted / rejected / proposed>
Review findings: <blocking fixed>, <blocking open>, <non-blocking>
Not verified: <list, or "nothing">

Next:
1. Review the code. Nothing has been committed.
2. /foundry-init to generate the building team from the real code.
3. Start a new session so the agents load.
4. /kickoff to begin the next milestone.
```
