---
name: rco-create-pr
description: Create a pull request for ReconcileOps document, rule, example, or issue-map changes. Use when Codex needs to branch, commit, and open a PR whose description is generated from changed file paths rather than a declared PR type.
---

# RCO Create PR

Before doing any work, read `.reconcile-ops/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Create a PR that leaves a trace for ReconcileOps artifacts. PRs do not have ReconcileOps
types. The description is generated from the actual changed files.

## When to Use

- Opening a PR after creating or updating requirements
- Opening a PR after creating or updating Goals
- Opening a PR after changing `.reconcile-ops/config.json`
- Opening a PR after changing examples or issue mappings
- Creating a reviewable trace for ReconcileOps document changes

## Core Principles

- Do not ask the user to choose a PR type.
- Describe what changed based on file paths.
- Do not write project status metadata into Git documents.
- Keep PR descriptions factual and review-oriented.
- When a PR relates to a Goal, update the corresponding GitHub issue body with the PR link.


## Standard Workflow

1. Read `.reconcile-ops/config.json` unless already read in this session. If it does not exist, stop and tell the user to run `rco-setup` first.
2. Read `.reconcile-ops/examples/pr.md` for structure only.
3. Inspect changed files with `git status --short`.
4. Build a PR summary from paths:
   - `docs/requirements/**`: requirement changes
   - `docs/goals/**`: Goal changes
   - `.reconcile-ops/config.json`: rule changes
   - `.reconcile-ops/examples/**`: example structure changes
   - `.reconcile-ops/GOAL_ISSUE_MAP.json`: issue mapping changes
5. Read `branch_prefix` from `.reconcile-ops/config.json`. If the key is absent, stop and tell the user to run `rco-setup` first. Create a branch with that prefix unless the user requests another prefix.
6. Stage the changed files.
7. Commit with a concise message.
8. Create the PR with a description based on `.reconcile-ops/examples/pr.md`.
9. If the changed files include `docs/goals/G-*.md`, look up the corresponding issue in `.reconcile-ops/GOAL_ISSUE_MAP.json` and append the PR link to the issue body under the PRs section.
10. Report the PR URL and changed files.

## Implementation Templates

PR description:

```md
## Summary

- ...

## Changed Files

- `...`

## Review Notes

- Confirm requirement documents reflect stable client intent when `docs/requirements/**` changed.
- Confirm Goals are verifiable when `docs/goals/**` changed.
- Confirm Git-tracked documents do not contain project status metadata.
```

Useful commands:

```bash
git status --short
git switch -c <branch_prefix><short-topic>
git add <files>
git commit -m "<message>"
gh pr create --title "<title>" --body-file <body-file>
gh issue edit <issue-number> --body "$(gh issue view <issue-number> --json body -q .body)

- <pr-url>"
```

## Bundled Resources

- `.reconcile-ops/examples/pr.md`: Example PR description. Reference the structure only.

## Agent Feedback Loop

If relevant files contain status metadata, stop and fix the documents before creating the PR.
If the issue update fails because the issue does not exist yet, report the missing issue and continue
without blocking the PR creation.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "This is a Goal PR." | PRs have no ReconcileOps type; describe changed files. |
| "The PR should include status." | Status belongs in GitHub Project metadata. |
| "The examples are templates." | Examples guide structure; generated PR text should reflect actual changes. |

## Red Flags

- User is asked to choose a PR type
- PR description is generic and does not mention changed paths
- PR body contains milestone, owner, priority, or progress as Git-managed state
- Requirement or Goal files contain status metadata
- Agent proceeds when `.reconcile-ops/config.json` is missing without telling the user to run `rco-setup`

## Verification

- [ ] `.reconcile-ops/config.json` was read
- [ ] If `.reconcile-ops/config.json` was missing, user was told to run `rco-setup`
- [ ] Changed files were inspected
- [ ] PR description was generated from file paths
- [ ] No PR type was requested or recorded
- [ ] `branch_prefix` was read from `.reconcile-ops/config.json`
- [ ] If Goals changed, corresponding issues were updated with the PR link
- [ ] PR review notes are factual and path-driven
