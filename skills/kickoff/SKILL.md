---
name: kickoff
description: Start a working session in a project. Checks git health, loads the current state of work, and agrees on one objective. Use when the user types /kickoff or says "let's start", "where did we leave off", or "what am I working on".
---

# Kickoff

Get oriented quickly, then agree on the session's objective. This skill reads and reports. It changes nothing except marking the chosen task as started.

Focus for this session, if given: `$ARGUMENTS`

## Steps

1. **Load the project.** Read `CLAUDE.md` and `.claude/foundry.json`. The manifest lists this project's agents and its workflow. If there is no manifest, say so and offer `/foundry-init`.

2. **Git health.**

   ```bash
   git fetch --all --prune
   git status -sb
   git log -5 --oneline
   ```

   Then compare against the base the workflow uses:
   - Staging-first: confirm `origin/main` is contained in `origin/staging`, and report how far the local branch is from `origin/staging`.
   - Feature branches or trunk: report how far the current branch is from `origin/main`.

   Flag uncommitted changes, a stale branch, and any divergence between the production branch and the working branch.

3. **Load the state of work.**
   - If the project has a tracker agent, launch it to report what is In Progress and Next, and to surface drift between the board and reality.
   - Otherwise read `docs/CURRENT-STATE.md`.

4. **Open work.** Run `gh pr list --state open` and `gh run list --limit 5` if `gh` is available. Report failing runs.

5. **Report** in this shape:

   ```
   Project: <name>   Branch: <branch> (<n> behind / <m> ahead of <base>)
   Working tree: clean / <summary of changes>
   In flight: <tasks in progress>
   Next up: <queued tasks>
   Open PRs: <list>   CI: <latest result>
   Drift: <anything the board and reality disagree on, or "none found">
   Suggested objective: <one sentence>
   ```

6. **Agree on one objective.** If the work is large or unclear, suggest the architect or pm agent first. Once the user picks, have the tracker mark the task In Progress.

Do not start implementation in this skill. Kickoff ends when the objective is agreed.
