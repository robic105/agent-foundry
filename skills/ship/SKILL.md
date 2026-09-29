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
- **You launch every review.** Code review, security review, and UX review are launched from this session. A review that the dev agent commissioned for itself does not pass a gate.

## Gates

Read `CLAUDE.md` and `.claude/foundry.json` first for the workflow, the commands, the protected surfaces, and the agents. The manifest maps each agent's name to its role, and an agent's name may not contain its role. Skip a gate that no agent fills and say that you skipped it.

If the manifest's stage is `idea` or `plan`, there is nothing to ship. Say so and stop.

```
- [ ] 1. Up to date with the base branch
- [ ] 2. Local checks pass
- [ ] 3. Tests cover the change
- [ ] 4. Code review
- [ ] 5. Security review, if the change touches a sensitive surface
- [ ] 6. UX review, if the change is user-facing
- [ ] 7. Blueprint conformance, if the project has a blueprint
- [ ] 8. Owner go-ahead
- [ ] 9. Pushed, CI watched to completion
- [ ] 10. Verified in the deployed environment
- [ ] 11. Pull request open, board updated
```

1. **Up to date.** `git fetch origin`, then confirm the branch contains the latest base. If a conflict touches logic you did not write, stop and ask.
2. **Local checks.** Run the project's typecheck, lint, test, and build commands. Report the results. Compare failures against the known baseline before blaming the change.
3. **Tests.** If logic changed without tests, launch the qa agent.
4. **Code review.** Launch the code-review agent on the real diff against the remote base. Fix what it would block on, then re-run gate 2.
5. **Security review.** Required when the diff touches auth, sessions, payments, uploads, storage, headers, middleware, secrets, or dependencies. Launch the security agent. Critical and High findings block.
6. **UX review.** Required when the diff touches anything the user sees or does. Launch the ux agent. Blockers block.
7. **Blueprint conformance.** Required when `docs/plan/BLUEPRINT.md` exists. Launch the architect agent to compare the diff with the blueprint and the decisions. Each departure needs a decision from the owner before the push: accept it, which adds a decision entry and updates the blueprint, or reject it, which sends the work back. If the project has no architect agent, make the comparison yourself and say so.
8. **Go-ahead.** Present the gate results, every departure from the blueprint, the blast-radius statement for any protected surface, the commits to be pushed, and what the push will trigger. Wait.
9. **Push.** Follow the workflow:
   - *Staging-first:* push to `staging`. Watch the CI run to completion and report each step.
   - *Feature branches:* push the branch.
   - *Trunk:* push to `main` only if the manifest says trunk and the owner confirmed.
10. **Verify.** Launch the devops agent, or check the deployed environment directly: health endpoint, the changed behavior, logs. If a migration shipped, confirm by name that it was applied.
11. **Pull request.** If the change completes a milestone, set that milestone to "done" in the blueprint with the date. Open the pull request with `gh pr create` using the project's template: staging-first opens `staging → main`, feature branches open `<branch> → main`. Then launch the tracker agent. Work that is built but not yet reachable by users is **Review**, not Done.

## Final report

```
Gates: <each gate: passed / failed / skipped, with one line of evidence>
Pushed: <branch> at <sha>   CI: <result>
Verified: <environment and what you observed>
PR: <link>, open and awaiting your review
Board: <what the tracker changed>
Unverified: <anything you could not confirm>
```
