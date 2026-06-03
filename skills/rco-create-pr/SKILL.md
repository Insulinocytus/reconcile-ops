---
name: rco-create-pr
description: Use when changes are ready to submit as a pull request.
---

# RCO Create PR

Before doing any work, read `.rco/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Create a PR that leaves a trace. The PR body is generated from changed files, with
reviewer assignment from config. PRs that implement a Goal link to the corresponding
Issue. All other PRs omit the Goals section.

## When to Use

- Opening a PR after any change that needs review and traceability
- After creating or updating requirements, Goals, or ADR files
- After code or configuration changes

## Core Principles

- PR title is a one-line summary of what the PR does.
- PR body starts with Goals (if implementing a Goal), then Summary, then Changed Files.
- Goals are linked by Issue number (`#123`). Only PRs that directly implement a Goal include this section. All others omit it.
- Reviewers are auto-assigned based on `pr_reviewers` in config — matching changed file paths against `paths` and evaluating `conditions` against the diff.
- Changed Files are a table: path (or folder) with a one-sentence note. Folders can be used when a group of files serves one purpose.
- Do not write project status metadata into Git documents.

## Standard Workflow

1. Read `.rco/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.
2. Inspect changed files with `git status --short`.
3. Determine whether this PR directly implements a Goal. Search for Goal IDs in the changed files or ask the user. If yes, link the corresponding Issue by number. If not, omit the Goals section.
4. Collect reviewers: match changed file paths against `paths` in each `pr_reviewers` entry, evaluate `conditions` against the diff, and union the `reviewers` from all matching entries.
5. Build the PR body:

PR implementing a Goal:

```md
## Goals

- #12

## Summary

- Add basic auth login endpoint
- Add session management with 30-minute expiry
- Create sessions table in PostgreSQL

## Changed Files

| Path | Note |
|------|------|
| `src/auth/` | Add basic auth login and session management |
| `migrations/001_create_sessions.sql` | Create sessions table |
```

PR not implementing a Goal:

```md
## Summary

- Fix typo in API endpoint documentation

## Changed Files

| Path | Note |
|------|------|
| `docs/api.md` | Fix endpoint URL typo |
```

6. Read `branch_prefix` from `.rco/config.json`. If the key is absent, stop and tell the user to run `rco-setup` first.
7. Check current branch. If already on a branch with the expected prefix (or the user confirms the current branch), skip branch creation and commit directly. Otherwise create a branch with the prefix.
8. Stage the changed files.
9. Commit with a concise message.
10. Before creating the PR, verify:
    - The base branch is correct (usually `main` or the project's default branch).
    - `git diff <base>...HEAD` contains only expected changes. If the diff contains unexpected files, stop and report the anomaly.
11. Create the PR with the generated body, assigning detected reviewers with `--reviewer`.
12. If the PR implements a Goal, find the corresponding Issue by searching for `[G-XXXXXX]` in issue titles and append the PR link to the Issue body under the PRs section.
13. Report the PR URL and assigned reviewers.

## Implementation Templates

Useful commands:

```bash
git status --short
git branch --show-current
git switch -c <branch_prefix><short-topic>
git add <files>
git commit -m "<message>"
git diff <base>...HEAD --stat
gh pr create --title "<title>" --body-file <body-file> --reviewer <reviewer1,reviewer2>
gh issue list --search 'G-000001 in:title' --json number
gh issue edit <issue-number> --body "$(gh issue view <issue-number> --json body -q .body)

- <pr-url>"
```

## Agent Feedback Loop

If relevant files contain status metadata, stop and fix the documents before creating the PR.
If the issue update fails because the issue does not exist yet, report the missing issue and continue
without blocking the PR creation. If no reviewers matched from config and the PR touches business code,
warn the user that reviewer routing may be incomplete and suggest updating config.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "Force a Goal link on every PR." | Only PRs that directly implement a Goal include Goals. All others omit it. |
| "The PR should include status." | Status belongs in GitHub Project metadata. |
| "No reviewers matched, so skip assignment." | Warn the user. Missing reviewer coverage means config needs updating. |
| "List every changed file individually." | Group files by folder when they serve one purpose. |
| "Skip the diff sanity check." | Always verify the diff before creating the PR. Unexpected files mean something is wrong. |

## Red Flags

- User is asked to choose a PR type
- PR body contains milestone, owner, priority, or progress as Git-managed state
- Requirement or Goal files contain status metadata
- Goals section is present for a PR that does not implement a Goal
- A PR implementing a Goal has Goals section with vague text instead of Issue references
- No reviewers matched from config for a business-code PR and no warning was given
- Diff sanity check is skipped
- Unexpected files appear in the diff and are not reported
- Agent proceeds when `.rco/config.json` is missing without telling the user to run `rco-setup`

## Verification

- [ ] `.rco/config.json` was read
- [ ] If `.rco/config.json` was missing, user was told to run `rco-setup`
- [ ] Changed files were inspected
- [ ] Goals section is present only if the PR directly implements a Goal; Issue references use `#123` format
- [ ] Reviewers were assigned from matching `pr_reviewers` entries
- [ ] `branch_prefix` was read from `.rco/config.json`
- [ ] Existing branch was reused when appropriate instead of creating a new one
- [ ] Base branch was verified before PR creation
- [ ] Diff sanity check passed — no unexpected files
- [ ] Changed Files section uses table format with path and note
- [ ] If implementing a Goal, corresponding issue was updated with the PR link
- [ ] If no reviewers matched for a business-code PR, a warning was given
