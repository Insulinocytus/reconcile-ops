---
name: rco-create-goal-issue
description: Use when docs/goals/G-*.md files lack corresponding GitHub issues, or after Goal documents are merged and need Issue creation.
---

# RCO Create Goal Issue

Before doing any work, read `.rco/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Create GitHub issues for Goal files that do not already have an issue. The issue is the
status carrier: it owns deadline (milestone), status, PR accumulation, and manual
Acceptance Criteria checklist progress. The Goal file owns the canonical acceptance
criteria and source requirements. The Issue mirrors only the Acceptance Criteria as a
checklist so PMs can see progress without creating speculative task Issues.

## When to Use

- Creating missing issues for `docs/goals/G-*.md`
- Backfilling GitHub Project issues after Goal files are merged
- Updating GitHub Project Status after Goal Superseded changes

## Core Principles

- Goal Issues use the label `goal`.
- Issue title format is `[G-000001] Goal Title`.
- Issue body contains only a Goal file link, an Acceptance Criteria checklist copied from the Goal file, and a PRs section. No source requirements, background, status, owner, deadline, scope, or implementation tasks.
- The Goal file is the canonical source of Acceptance Criteria. The Issue checklist is the progress view that humans manually check off.
- This skill creates Issues from scratch. `rco-create-pr` is responsible for appending PR links to existing Issue bodies. This skill never appends PR links.
- A Goal maps to exactly one GitHub Project issue. Find the issue by searching with `--label goal`.
- GitHub Project owns status (Todo / In Progress / Done / Superseded). `github_project_id` must be configured.
- GitHub Milestone owns deadline.
- If a Goal file has `> **Superseded**`, set the GitHub Project Status to Superseded.

## Standard Workflow

1. Read `.rco/config.json` unless already read in this session. If it does not exist, stop and tell the user to run `rco-setup` first.
2. Scan `docs/goals/` or the user-provided Goal folder.
3. For each `G-*.md`, parse the first heading after any Superseded marker:
   - `# G-000001: Goal Title`
4. Parse every plain list item under `## Acceptance Criteria`. Preserve order and text exactly.
5. Ensure the `goal` label exists in the repository. If not, create it:

```bash
gh label list --json name --jq '.[].name' | grep -qx goal || gh label create goal --description 'Goal issue' --color '0E8A16'
```

6. Check whether an issue already exists for this Goal ID by searching with `--label goal`.
7. If no issue exists, create one:
   - title: `[G-000001] Goal Title`
   - label: `goal`
   - body:

```md
Goal: <default-branch-link-to-docs/goals/G-000001.md>

## Acceptance Criteria

- [ ] <acceptance criterion 1>
- [ ] <acceptance criterion 2>

PRs:
```

8. If an issue already exists, compare its Acceptance Criteria checklist with the Goal file Acceptance Criteria. Report any drift, but do not rewrite the existing issue.
9. Add the issue to the GitHub Project. If `github_project_id` is empty, stop and tell the user to run `rco-setup` to configure the required GitHub Project.
10. If the Goal file has `> **Superseded**`, set the GitHub Project Status to Superseded.
11. Skip existing issues without changing them, except for Superseded status handling when required.

## Implementation Templates

Issue body:

```md
Goal: https://github.com/OWNER/REPO/blob/main/docs/goals/G-000001.md

## Acceptance Criteria

- [ ] User can log in with username and password
- [ ] Failed login shows an error message
- [ ] Session persists for 30 minutes

PRs:
```

Useful `gh` commands:

```bash
gh repo view --json nameWithOwner,defaultBranchRef
gh label list --json name --jq '.[].name' | grep -qx goal || gh label create goal --description 'Goal issue' --color '0E8A16'
gh issue list --label goal --search 'G-000001' --json number,title,id,url
gh issue create --title '[G-000001] Goal Title' --label goal --body 'Goal: https://github.com/OWNER/REPO/blob/main/docs/goals/G-000001.md

## Acceptance Criteria

- [ ] User can log in with username and password
- [ ] Failed login shows an error message
- [ ] Session persists for 30 minutes

PRs:'
gh project item-add <project-id> --url <issue-url>
```

## Agent Feedback Loop

If GitHub repo context is missing and cannot be discovered with `gh repo view`,
stop and ask for the missing repository information. Do not guess a remote.
If `github_project_id` is empty in the config, stop and tell the user to run `rco-setup`
to configure the required GitHub Project.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "The issue body should duplicate the whole Goal." | Only mirror Acceptance Criteria as a checklist. Source requirements and context stay in Git. |
| "Existing issues should be refreshed." | Report Acceptance Criteria drift, but do not rewrite existing issue bodies in this skill. |
| "The mapping can include status." | Store only `goal id -> issue id`. |
| "Superseded Goals don't need issues." | Create the issue anyway and set status to Superseded for traceability. |

## Red Flags

- Goal Issue is missing the `goal` label
- Issue title does not start with `[G-000001]`
- Issue body duplicates Goal source requirements, context, scope, or status metadata
- Issue body is missing the Acceptance Criteria checklist
- Issue body is missing the PRs section
- Existing issue content is rewritten instead of drift being reported
- Duplicate issue is created for the same Goal ID
- Superseded Goal does not have its GitHub Project Status set to Superseded
- Agent proceeds when `.rco/config.json` is missing without telling the user to run `rco-setup`

## Verification

- [ ] `.rco/config.json` was read
- [ ] If `.rco/config.json` was missing, user was told to run `rco-setup`
- [ ] Goal ID and title were parsed from the Goal heading
- [ ] Acceptance Criteria were parsed from the Goal file
- [ ] Existing issues were checked before creation
- [ ] The `goal` label exists in the repository
- [ ] Created issue has the `goal` label
- [ ] Created issue title uses `[G-000001] Goal Title`
- [ ] Created issue body contains only Goal link, Acceptance Criteria checklist, and PRs section
- [ ] Checklist items preserve Goal file Acceptance Criteria text and order
- [ ] Existing issue Acceptance Criteria drift was reported, not auto-fixed
- [ ] If Goal file has Superseded marker, GitHub Project Status was set to Superseded
- [ ] The issue was added to the configured GitHub Project
- [ ] Existing issues were skipped, not modified except for required Superseded status handling
