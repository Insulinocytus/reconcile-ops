---
name: rco-create-issue
description: Create missing GitHub issues for ReconcileOps Goal files. Use when Codex needs to scan docs/goals/G-*.md, create GitHub issues titled [G-000001] Goal Title, add a minimal default-branch Goal link body, and update .reconcile-ops/GOAL_ISSUE_MAP.json with goal id to issue id mappings only.
---

# RCO Create Issue

Before doing any work, read `.reconcile-ops/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Create GitHub issues for Goal files that do not already have an issue. The issue is the
GitHub Project entry point. Git stores only the Goal-to-issue mapping, not Project state.

## When to Use

- Creating missing issues for `docs/goals/G-*.md`
- Backfilling GitHub Project issues after Goal files are merged
- Updating `.reconcile-ops/GOAL_ISSUE_MAP.json` after creating issues

## Core Principles

- Issue title format is `[G-000001] Goal Title`.
- Issue body contains only a default-branch link to the Goal file.
- Do not update issue content, close issues, or sync Project status in v1.
- `.reconcile-ops/GOAL_ISSUE_MAP.json` stores only `goal id -> issue id`.
- A Goal maps to exactly one GitHub Project issue.
- GitHub Project and issue metadata own milestone, owner, status, priority, and progress.
- All user-facing output must use the `preferred_language` from `.reconcile-ops/config.json`.

## Standard Workflow

1. Read `.reconcile-ops/config.json` unless already read in this session. If it does not exist, stop and tell the user to run `rco-setup` first.
2. Read `.reconcile-ops/examples/goal-issue.md` for structure only.
3. Scan `docs/goals/` or the user-provided Goal folder.
4. For each `G-*.md`, parse the first heading:
   - `# G-000001: Goal Title`
5. Check whether an issue already exists with title starting with `[G-000001]`.
6. If no issue exists, create one:
   - title: `[G-000001] Goal Title`
   - body: `Goal file: <default-branch-link-to-docs/goals/G-000001.md>`
7. Add the issue to the GitHub Project when project information is provided.
8. Record only the mapping in `.reconcile-ops/GOAL_ISSUE_MAP.json`.
9. Skip existing issues without changing them.

## Implementation Templates

Issue body:

```md
Goal file: <default-branch-link-to-docs/goals/G-000001.md>
```

Useful `gh` commands:

```bash
gh repo view --json nameWithOwner,defaultBranchRef
gh issue list --search 'G-000001 in:title' --json number,title,id,url
gh issue create --title '[G-000001] Goal Title' --body 'Goal file: https://github.com/OWNER/REPO/blob/main/docs/goals/G-000001.md'
```

## Bundled Resources

- `.reconcile-ops/examples/goal-issue.md`: Example minimal issue body. Reference the structure only.

## Agent Feedback Loop

If GitHub repo or project context is missing and cannot be discovered with `gh repo view`,
stop and ask for the missing repository or project information. Do not guess a remote.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "The issue body should duplicate the Goal." | Link to the default-branch Goal file only. |
| "The issue should track status." | GitHub Project metadata tracks status, not the Git file or issue body. |
| "Existing issues should be refreshed." | v1 creates missing issues only. |
| "The mapping can include status." | Store only `goal id -> issue id`. |

## Red Flags

- Issue title does not start with `[G-000001]`
- Issue body duplicates Goal details
- `.reconcile-ops/GOAL_ISSUE_MAP.json` contains status, owner, milestone, or priority
- Existing issue content is edited
- Duplicate issue is created for the same Goal ID
- Agent proceeds when `.reconcile-ops/config.json` is missing without telling the user to run `rco-setup`

## Verification

- [ ] `.reconcile-ops/config.json` was read
- [ ] If `.reconcile-ops/config.json` was missing, user was told to run `rco-setup`
- [ ] Goal ID and title were parsed from the Goal heading
- [ ] Existing issues were checked before creation
- [ ] Created issue title uses `[G-000001] Goal Title`
- [ ] Created issue body contains only the default-branch Goal link
- [ ] Mapping file contains only `goal id -> issue id`
- [ ] Existing issues were skipped, not modified
