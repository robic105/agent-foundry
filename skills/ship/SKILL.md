---
name: ship
description: Take finished work through the project's review gates and the project's release workflow. Runs checks, code review, security review, and UX review, then pushes and opens a pull request. It never merges. Use when the user types /ship.
disable-model-invocation: true
---

# Ship

Move the current work from "code written" to "in review and verified". Stop at the first failed gate and report.

Notes from the user: `$ARGUMENTS`

## Rules

- **Never merge a pull request.** Open it and leave it for the owner.
- **Never push to the production branch.**
- **Confirm before pushing.** Show the gate results and what will be pushed, then wait for a go-ahead. Typing `/ship` starts the gates. It does not pre-approve the push.
- **Report what you observed.** A gate passes only on evidence.

## Gates

Read `CLAUDE.md` and `.claude/foundry.json` first for the workflow, the commands, the protected surfaces, and the installed agents. Skip a gate whose agent is not installed and say that you skipped it.

```
- [ ] 1. Up to date with the base branch
- [ ] 2. Local checks pass
- [ ] 3. Tests cover the change
- [ ] 4. Code review
- [ ] 5. Security review, if the change touches a sensitive surface
- [ ] 6. UX review, if the change is user-facing
- [ ] 7. Owner go-ahead
- [ ] 8. Pushed, CI watched to completion
- [ ] 9. Verified in the deployed environment
- [ ] 10. Pull request open, board updated
```

1. **Up to date.** `git fetch origin`, then confirm the branch contains the latest base. If a conflict touches logic you did not write, stop and ask.
2. **Local checks.** Run the project's typecheck, lint, test, and build commands. Report the results. Compare failures against the known baseline before blaming the change.
3. **Tests.** If logic changed without tests, launch the qa agent.
4. **Code review.** Launch the code-review agent on the real diff against the remote base. Fix what it would block on, then re-run gate 2.
5. **Security review.** Required when the diff touches auth, sessions, payments, uploads, storage, headers, middleware, secrets, or dependencies. Launch the security agent. Critical and High findings block.
6. **UX review.** Required when the diff touches anything the user sees or does. Launch the ux agent. Blockers block.
7. **Go-ahead.** Present the gate results, the blast-radius statement for any protected surface, the commits to be pushed, and what the push will trigger. Wait.
8. **Push.** Follow the workflow:
   - *Staging-first:* push to `staging`. Watch the CI run to completion and report each step.
   - *Feature branches:* push the branch.
   - *Trunk:* push to `main` only if the manifest says trunk and the owner confirmed.
9. **Verify.** Launch the devops agent, or check the deployed environment directly: health endpoint, the changed behavior, logs. If a migration shipped, confirm by name that it was applied.
10. **Pull request.** Open it with `gh pr create` using the project's template: staging-first opens `staging → main`, feature branches open `<branch> → main`. Then launch the tracker agent. Work that is built but not yet reachable by users is **Review**, not Done.

## Final report

```
Gates: <each gate: passed / failed / skipped, with one line of evidence>
Pushed: <branch> at <sha>   CI: <result>
Verified: <environment and what you observed>
PR: <link>, open and awaiting your review
Board: <what the tracker changed>
Unverified: <anything you could not confirm>
```
