---
name: wrap-up
description: End a working session so the next one can resume from the record. Updates the board or the state file, captures follow-ups, and lists loose ends. Use when the user types /wrap-up or says "wrap up", "I'm done for today", or "end session".
---

# Wrap Up

Make sure nothing important lives only in this conversation.

Notes from the user: `$ARGUMENTS`

## Steps

1. **Summarize the session** from the conversation and from `git log`:
   - The objective
   - What changed: files, commits, pull requests, deploys
   - Decisions made, with the reasons
   - Bugs found or fixed: symptom, cause, fix
   - What is verified and what is not
   - Follow-ups and risks that surfaced

2. **Record it.** Read `.claude/foundry.json` to see how this project tracks state.
   - **With a tracker agent:** launch it with the summary. It updates statuses, captures each follow-up as a task, and reports a changelog. Remind it that built-but-unreachable work is Review, not Done.
   - **Without one:** update `docs/CURRENT-STATE.md`. Overwrite the status sections with the current truth and keep the file short.

3. **Check for loose ends.**

   ```bash
   git status -sb
   git log @{u}..HEAD --oneline
   gh pr list --state open
   ```

   List uncommitted changes, unpushed commits, open pull requests awaiting the owner, failing CI runs, and any deploy that was not verified.

4. **Do not commit or push** unless the user asks. Report what is uncommitted and let them decide.

5. **Report:**

   ```
   Session: <objective, one line>
   Shipped: <what reached users>
   In review: <what is built but not yet live>
   Recorded: <board changes or state file updated>
   Follow-ups captured: <list>
   Loose ends: <list, or "none">
   Unverified: <list, or "none">
   Next session, start with: "<an exact first message>"
   ```

Facts only: commit hashes, file paths, observed results. If something was not verified, say so.
