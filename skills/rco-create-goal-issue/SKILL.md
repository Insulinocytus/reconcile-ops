---
name: rco-create-goal-issue
description: Use when docs/goals/G-*.md files lack corresponding GitHub issues, or after Goal documents are merged and need Issue creation.
---

# RCO Create Goal Issue

Before doing any work, read `.rco/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Create GitHub issues for Goal files that do not already have an issue. The issue is the
status carrier: it owns deadline (milestone), status, and PR accumulation. The Goal file
owns acceptance criteria and source requirements. They never duplicate content.

## When to Use

- Creating missing issues for `docs/goals/G-*.md`
- Backfilling GitHub Project issues after Goal files are merged
- Updating Issue status after Goal Superseded changes

## Core Principles

- Issue title format is `[G-000001] Goal Title`.
- Issue body contains only a Goal file link and a PRs section. No acceptance criteria, no requirements, no scope.
- This skill creates Issues from scratch. `rco-create-pr` is responsible for appending PR links to existing Issue bodies. This skill never appends PR links.
- A Goal maps to exactly one GitHub Project issue. Find the issue by searching for `[G-XXXXXX]` in the title.
- GitHub Project owns status (Todo / In Progress / Done / Superseded).
- GitHub Milestone owns deadline.
- If a Goal file has `> **Superseded**`, set the issue status to Superseded.

## Standard Workflow

1. Read `.rco/config.json` unless already read in this session. If it does not exist, stop and tell the user to run `rco-setup` first.
2. Scan `docs/goals/` or the user-provided Goal folder.
3. For each `G-*.md`, parse the first heading after any Superseded marker:
   - `# G-000001: Goal Title`
4. Check whether an issue already exists with title starting with `[G-000001]`.
5. If no issue exists, create one:
   - title: `[G-000001] Goal Title`
   - body:

```md
Goal: <default-branch-link-to-docs/goals/G-000001.md>

PRs:
```

6. Add the issue to the GitHub Project when `github_project_id` is present in `.rco/config.json`. If `github_project_id` is empty, skip this step.
7. If the Goal file has `> **Superseded**`, set the issue status to Superseded.
8. Skip existing issues without changing them.

## Implementation Templates

Issue body:

```md
Goal: https://github.com/OWNER/REPO/blob/main/docs/goals/G-000001.md

PRs:
```

Useful `gh` commands:

```bash
gh repo view --json nameWithOwner,defaultBranchRef
gh issue list --search 'G-000001 in:title' --json number,title,id,url
gh issue create --title '[G-000001] Goal Title' --body 'Goal: https://github.com/OWNER/REPO/blob/main/docs/goals/G-000001.md

PRs:'
gh project item-add <project-id> --url <issue-url>
```

## Agent Feedback Loop

If GitHub repo context is missing and cannot be discovered with `gh repo view`,
stop and ask for the missing repository information. Do not guess a remote.
If `github_project_id` is empty in the config and the user wants issues added to a project,
tell the user to run `rco-setup` to configure the project.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "The issue body should duplicate the Goal." | Link to the Goal file only. Content lives in Git, status lives in Project. |
| "Existing issues should be refreshed." | Create missing issues and append PR links only. Do not rewrite issue bodies. |
| "The mapping can include status." | Store only `goal id -> issue id`. |
| "Superseded Goals don't need issues." | Create the issue anyway and set status to Superseded for traceability. |

## Red Flags

- Issue title does not start with `[G-000001]`
- Issue body duplicates Goal content (acceptance criteria, requirements)
- Issue body is missing the PRs section
- Existing issue content is rewritten
- Duplicate issue is created for the same Goal ID
- Superseded Goal does not have its issue status set to Superseded
- Agent proceeds when `.rco/config.json` is missing without telling the user to run `rco-setup`

## Verification

- [ ] `.rco/config.json` was read
- [ ] If `.rco/config.json` was missing, user was told to run `rco-setup`
- [ ] Goal ID and title were parsed from the Goal heading
- [ ] Existing issues were checked before creation
- [ ] Created issue title uses `[G-000001] Goal Title`
- [ ] Created issue body contains only Goal link and PRs section
- [ ] If Goal file has Superseded marker, issue status was set to Superseded
- [ ] If `github_project_id` was present, the issue was added to the project
- [ ] Existing issues were skipped, not modified
