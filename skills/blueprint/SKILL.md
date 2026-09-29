---
name: blueprint
description: Plan how an idea gets built before any code is written. Turns the idea brief into a scoped, reviewed, owner-approved plan with a stack, a structure, risks, and milestones, written to docs/plan/BLUEPRINT.md. Use when the user types /blueprint.
disable-model-invocation: true
---

# Blueprint

Plan the build before the build. The aim is to avoid starting down a path that can't be sustained.

Role templates and the plan templates are bundled next to this file:

```
${CLAUDE_SKILL_DIR}/foundry/agents/                     role templates
${CLAUDE_SKILL_DIR}/foundry/templates/plan/BLUEPRINT.md
${CLAUDE_SKILL_DIR}/foundry/templates/plan/DECISIONS.md
```

If `${CLAUDE_SKILL_DIR}/foundry/` is missing, stop and tell the owner to run `./install.sh` from their agent-foundry checkout.

What the owner typed after the command: `$ARGUMENTS`

## Who does what

| Part | Owner |
|---|---|
| What the first version includes and excludes | pm |
| How it gets built | architect, who owns the blueprint |
| Whether it can be built and maintained | dev, as a challenger |
| Whether it serves the user | ux, when people use an interface |
| Whether it is safe | security, when it handles accounts, payments, or private data |
| Approving the plan | The owner, and nobody else |

## Rules for this skill

- **No code.** This skill writes documents. It creates no source files and installs nothing.
- **The owner approves.** The blueprint stays a draft until the owner approves it. An agent's recommendation is recorded as proposed.
- **Plan the first version only.** Do not design for needs the brief does not state.
- **Size the plan to the project.** A small tool gets a short plan. Aim for under 200 lines, and never pass 400. The owner should be able to read the blueprint in ten minutes. Detail that only the builder needs belongs in the milestone that uses it. Questions for the owner go in the brief's Open questions, at most ten, and the blueprint links to them.
- **Prefer what the owner knows.** A stack the owner can maintain beats a better stack they can't.
- **Every choice has a way out.** A choice with no way to back out is a risk, and the plan says so.
- **Verify claims about the outside world.** Prices, limits, and whether a tool is maintained are checked against a source, or labelled unverified.
- **Do not commit or push.**

## Step 1: Check readiness

Read `docs/idea/BRIEF.md` and the files in `docs/idea/rounds/`. If there is no brief, stop and recommend `/idea`.

A build can be planned when the brief answers four things:

| Needed | Why |
|---|---|
| Who it is for | Every trade-off is judged against this person |
| What it does | This is what gets built |
| What kind of thing it is | An app, a device, and a service are planned differently |
| The smallest useful version | This sets the scope |

If one is missing, say which. Ask the owner for it, and record the answer in the brief. If the owner doesn't know yet, stop and recommend `/idea`. A plan built on a guess is the unsustainable path this skill exists to prevent.

If a blueprint already exists, read it. A draft is continued. An approved blueprint is revised only at the owner's request, and each change to a recorded decision gets a new decision entry.

## Step 2: Ask about the build

Ask the owner what the brief does not say. One question at a time. "No preference" is a valid answer.

| Question | Why it matters |
|---|---|
| Which languages and tools do you already know? | The plan should lean on them |
| What will you spend to run this each month? | It rules options in or out |
| Where does it need to run? | A phone, a browser, a device, a server |
| Is there a date it has to work by? | It limits the scope |
| Will anyone else work on the code? | It affects workflow and structure |

**Non-interactive runs.** If you cannot ask questions, take answers from the arguments and the brief. Record everything else under "What must stay true" as assumed.

## Step 3: Say what it costs, then run it

Tell the owner before launching anything:

> Planning takes about six agent runs: scope, a draft plan, a round of challenges, and a revision. It takes several minutes. Go ahead?

### Who to launch

- If this project's agents are installed and available in this session, launch them by name.
- Otherwise launch a `general-purpose` agent for each role. Build its prompt from the role template at `${CLAUDE_SKILL_DIR}/foundry/agents/<role>.md`, with this note: "Nothing is built yet. Ignore the template tokens and fill instructions. Take the role, the method, and the standards."

Give every agent the full brief and the owner's answers from Step 2. Tell every agent to label its assumptions and to separate what it verified from what it recalls.

### 3a. Scope: pm

Ask for:

- User stories for the smallest useful version, each with acceptance criteria that can be observed
- What is out of scope, with the reason for each item
- What in the owner's description should be cut from the first version

### 3b. Draft: architect

Give it the scope from 3a. Ask for every section of the blueprint template:

- Two or three options that differ in substance, including the simplest thing that could work, and a recommendation
- The stack, with a reason and a way to back out for each choice
- The structure, the data model, and where state lives
- Risks, with the riskiest assumption first
- The sustainability check
- Decisions that can wait
- Milestones. M0 is a walking skeleton: the thinnest slice that runs end to end with the checks in place. Later milestones test the riskiest assumption first.
- A proposed decision record for each real choice

### 3c. Challenge: in parallel

Launch these in a single message. Each gets the brief, the scope, and the draft.

| Reviewer | Launch when | Asked to find |
|---|---|---|
| **dev** | Always | What will be painful to build or maintain. Where the structure will fight the work. A simpler way to get the same result. Whether M0 is thin enough. |
| **pm** | Always | Anything in the plan that the scope does not need. Anything in the scope that the plan does not deliver. |
| **ux** | People use an interface | Whether the structure serves the person's moment described in the brief. What the plan makes hard to do well later. |
| **security** | It handles accounts, payments, or private data | What must be right from the first commit because it is costly to add later. |

Each reviewer raises at most five concerns, most serious first, and marks each one as blocking or not. A concern states the problem, the change it asks for, and whether the reviewer verified it or is recalling it.

### 3d. Revise: architect

Give the architect every concern. It revises the draft and answers each concern with what changed, or why nothing did. A blocking concern that the architect rejects goes to the owner in Step 4.

## Step 4: The owner decides

Present the plan in this order:

1. The recommendation in three sentences, and what it would cost to build and to run
2. The options that were rejected, and why
3. The riskiest assumption, and which milestone tests it
4. Concerns the reviewers and the architect did not settle
5. The decisions that need the owner

Take the decisions one at a time: the stack, where it runs, the data store, the workflow. For each, give the recommendation and the alternative.

Then ask for approval of the whole plan. There are three outcomes:

| Outcome | What you do |
|---|---|
| Approved | Set the status to "approved" with the date. Record each decision as accepted. |
| Approved with changes | Make the changes, show them, and ask again. |
| Not yet | Leave the status as "draft". Record what is unresolved. |

**Non-interactive runs.** The status is "approved" only if the arguments say the owner approves. Otherwise it stays "draft" and every decision is recorded as proposed.

## Step 5: Write the plan

Write these from the templates. Replace every token and every `{{FILL: ...}}`.

If you kept working files during the planning, such as the scope or the reviewers' concerns, put them in `docs/plan/rounds/YYYY-MM-DD/` and link that folder from the "Review of this plan" section. Leave no other working files behind.

| File | Contents |
|---|---|
| `docs/plan/BLUEPRINT.md` | The plan |
| `docs/plan/DECISIONS.md` | One entry per decision |

Then update what already exists:

| File | Change |
|---|---|
| `docs/idea/BRIEF.md` | Add the owner's decisions to Decided. Close the open questions they answer. Set "Last updated". |
| `.claude/foundry.json`, if present | Set `stage` to `plan` once the blueprint is approved |
| `CLAUDE.md`, if present | Add the blueprint section from the kit's `templates/CLAUDE.md` |

If a write into `.claude/` is denied, do not work around it. Tell the owner the one-line change to make.

## Step 6: Report

```
Blueprint: docs/plan/BLUEPRINT.md (<draft | approved>)

First version: <one line>
Recommended: <the option, one line>
Stack: <the main choices>
Cost to run: <estimate, marked verified or unverified>
Riskiest assumption: <one line>, tested in <milestone>
Milestones: <count>. M0: <one line>
Decisions: <count accepted>, <count proposed>
Unsettled: <concerns still open, or "none">
Unverified: <claims nobody checked against a source, or "none">

Next:
- /scaffold to build M0, once the blueprint is approved
- /blueprint to revise the plan
- /idea if the planning showed the idea needs more work
```
