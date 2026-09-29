# {{PROJECT_NAME}}: blueprint

_How the first version gets built. `/blueprint` writes it, the architect owns it, and the owner approves it. Once it is approved, the build follows it. A departure from it is a decision for the owner._

- **Status:** {{FILL: "draft", or "approved YYYY-MM-DD" once the owner has approved it. Never write "approved" without the owner's approval.}}
- **Last updated:** {{FILL: YYYY-MM-DD}}
- **Brief:** [docs/idea/BRIEF.md](../idea/BRIEF.md)
- **Decisions:** [DECISIONS.md](DECISIONS.md)

## Scope of the first version

### In scope

{{FILL: From the pm. User stories for the smallest useful version in the brief, each with acceptance criteria that can be observed.}}

### Out of scope

{{FILL: From the pm. What the first version leaves out on purpose, each with the reason. Include what the owner's description implied that was cut.}}

## What must stay true

{{FILL: The constraints the plan has to respect, taken from the brief and the owner: the owner's skills, the time they have, the money they will spend to build it and to run it, where it has to run, privacy or safety requirements, and any deadline. Mark each one as stated by the owner or assumed.}}

## Options considered

| Option | What it is | Fits the constraints | Cost to build | Cost to run | Risk | How hard to reverse |
|---|---|---|---|---|---|---|
{{FILL: Two or three options that differ in substance. One of them is the simplest thing that could work.}}

**Recommended:** {{FILL: Which option and why, in three sentences at most.}}

## Stack

| Layer | Choice | Why | How we would back out |
|---|---|---|---|
{{FILL: One row per layer that applies: language, framework, data store, auth, hosting, hardware, and so on. Prefer proven technology the owner already knows. Every row says how to back out of the choice.}}

## Structure

{{FILL: The components and how data moves between them. Where each kind of state lives and whether it survives a restart. The layout of the repo, as a short tree. A small diagram if it helps.}}

## Data model

{{FILL: The entities, their fields, and how they relate. "None yet" if the first version stores nothing.}}

## Risks

| Risk | What happens if it is real | How we find out early |
|---|---|---|
{{FILL: Most serious first. The first row is the riskiest assumption in the whole plan.}}

## Sustainability check

| Question | Answer |
|---|---|
| Can the owner maintain this alone? | {{FILL}} |
| What does it cost to run today? | {{FILL}} |
| What does it cost at ten times the use? | {{FILL}} |
| What breaks first as it grows? | {{FILL}} |
| Which choice locks us in the most, and what is the way out? | {{FILL}} |
| Which dependency is most likely to be abandoned or to change its terms? | {{FILL}} |
| What would a rewrite be triggered by? | {{FILL}} |

## Decisions that can wait

| Decision | Why it can wait | What would force it |
|---|---|---|
{{FILL: Choices left open on purpose. "None" if there are none.}}

## Workflow

{{FILL: How changes ship: trunk, feature branches, or staging-first, and why that fits this project now. Say what would make the owner move to a stricter one.}}

## Milestones

Each milestone is small enough to build, verify, and review as one piece of work.

### M0: walking skeleton

- **Status:** not started
- **Goal:** the thinnest slice that runs end to end, with the checks in place.
- **Builds:** {{FILL: What M0 creates: the project structure, one path through every layer in the Structure section, the test, lint, and typecheck commands, and a README with the commands to run it.}}
- **Done when:** {{FILL: Observable criteria: the commands that must pass and what must be seen running.}}
- **Leaves out:** {{FILL: What M0 does not include, so the scaffold stays thin.}}

{{FILL: Milestones M1 onward, in the same format. Order them so the riskiest assumption is tested first.}}

## Review of this plan

| Reviewer | Concern raised | What changed, or why nothing did |
|---|---|---|
{{FILL: One row per concern from the challenge round.}}
