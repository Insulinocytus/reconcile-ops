---
name: rco-nightly-inspect
description: Post-merge inspection that discovers reconciliation gaps — orphan PRs, Goals without issues, incomplete Goals, overdue Goals, doc debt, PRs missing Scope or Decision Owner, and stale issues. READ-ONLY scan that produces a structured report and optionally creates GitHub issues for high-priority findings.
---

# RCO Nightly Inspect

Before doing any work, read `.reconcile-ops/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Nightly Inspect is the post-merge reconciliation scan promised by the MANIFESTO. It discovers
drift, orphans, doc debt, and other gaps that humans and PR review did not catch. The scan is
READ-ONLY: it does not modify files, issues, or Project state. It produces a structured markdown
report and optionally creates GitHub issues for findings that need human attention.

## When to Use

- Running a scheduled post-merge reconciliation check
- Discovering orphan PRs disconnected from any Goal
- Finding Goals that lack GitHub issues or are incomplete
- Identifying overdue Goals that need human triage
- Detecting doc debt across requirements, Goals, and specs
- Surfacing PRs that violate L2 or L3 baseline
- Checking for stale GitHub Project issues
- Before a milestone or release to verify project hygiene

## Core Principles

- Nightly Inspect is READ-ONLY. It does not modify files, close issues, update Project status, or push commits.
- The report is the primary output. It replaces the previous report each run.
- `--create-issues` is an optional flag. When set, the skill creates GitHub issues only for high-priority findings. Issue creation is the only write operation.
- Use `inspect_stale_days` from `.reconcile-ops/config.json` for staleness threshold. Default 14 days if the key is absent.
- All inspection commands must use `gh`, `rg`, and `jq`. Do not install additional tools.
- Every finding must include the specific file path, issue number, or PR number, what is missing or wrong, and a suggested action.
- Do not suppress findings to keep the report short. The report is the mechanism that makes invisible drift visible.


## Standard Workflow

1. Read `.reconcile-ops/config.json` unless already read in this session. If it does not exist, stop and tell the user to run `rco-setup` first.
2. Read `inspect_stale_days` from `.reconcile-ops/config.json`. If the key is absent, use 14.
3. Discover the repository context:

```bash
gh repo view --json nameWithOwner,defaultBranchRef
```

4. Collect all open PRs:

```bash
gh pr list --state open --json number,title,body,updatedAt
```

5. Collect all Goal files:

```bash
rg -l '' docs/goals/G-*.md 2>/dev/null || echo 'no goals found'
```

6. Read `.reconcile-ops/GOAL_ISSUE_MAP.json` if it exists.
7. Run each inspection category below and collect findings.

### 7a. Orphan PRs

Open PRs that do not reference any Goal ID. A PR references a Goal when its title or body contains a `G-XXXXXX` pattern or its changed files include `docs/goals/G-*.md`.

```bash
gh pr list --state open --json number,title,body --jq '.[] | select((.title | test("G-[0-9]{6}") | not) and (.body | test("G-[0-9]{6}") | not)) | .number'
```

For each PR without a Goal ID match in title or body, check if the PR touches Goal files:

```bash
gh pr diff <pr-number> --name-only | rg 'docs/goals/G-[0-9]{6}\\.md'
```

If neither the title/body nor the diff references a Goal, the PR is an orphan. Suggested action: add Goal reference to PR body or create a Goal if the work is legitimate but untracked.

### 7b. Goals without GitHub Issues

For each `docs/goals/G-*.md`, check whether the Goal ID exists in `.reconcile-ops/GOAL_ISSUE_MAP.json`. If the map file does not exist, every Goal is a finding. If the Goal ID is in the map, verify the issue exists and is open:

```bash
gh issue view <issue-number> --json state,number 2>/dev/null || echo 'issue not found'
```

If the mapped issue does not exist or is closed, it is a finding. Suggested action: run `rco-create-issue` to create or recreate the missing issue.

### 7c. Incomplete Goals

For each `docs/goals/G-*.md`, check that the file contains all required L1 sections:

```bash
rg -c '## Acceptance Criteria|## Verification Method|## Deliverable|## Deadline' docs/goals/G-000001.md
```

A Goal is incomplete if it is missing any of: Acceptance Criteria, Verification Method, Deliverable, or Deadline. Suggested action: update the Goal file to include the missing section.

### 7d. Goals past Deadline

For each `docs/goals/G-*.md`, parse the Deadline section and compare to the current date. If the Deadline has passed and the mapped GitHub issue is not in a Done or Closed state, it is a finding:

```bash
deadline=$(rg -o 'Deadline$' docs/goals/G-000001.md | head -1)
```

Suggested action: triage the Goal — extend the deadline, mark it done, or split it into smaller Goals.

### 7e. Doc Debt

Check three doc debt signals:

1. Requirements without Goals: `docs/requirements/*.md` files that no `docs/goals/G-*.md` references via Source Requirements links.

```bash
for req in docs/requirements/*.md; do
  base=$(basename "$req" .md)
  rg "requirements/${base}" docs/goals/G-*.md 2>/dev/null | head -1 || echo "orphan requirement: $req"
done
```

2. Goals without Specs: `docs/goals/G-*.md` files that have no corresponding spec under `docs/specs/`.

```bash
for goal in docs/goals/G-*.md; do
  goal_id=$(basename "$goal" .md)
  rg "$goal_id" docs/specs/**/*.md 2>/dev/null | head -1 || echo "goal without spec: $goal"
done
```

3. Specs without PRs: spec files that have no open or recently merged PRs touching the relevant code paths. This requires human judgment; report the spec and note that no recent PRs reference it.

Suggested action: create Goals for orphan requirements, create specs for Goals, or confirm that work is planned.

### 7f. PRs missing Scope or Decision Owner

For each open PR, check whether the body mentions a Capability Scope and a Decision Owner. L2 requires Scope; L3 requires Decision Owner.

```bash
gh pr list --state open --json number,body --jq '.[] | select((.body | test("[Ss]cope") | not) or (.body | test("[Dd]ecision [Oo]wner") | not)) | .number'
```

Suggested action: update the PR body to include Capability Scope and Decision Owner.

### 7g. Issue Staleness

GitHub Project issues with no activity for more than `inspect_stale_days` days. Activity includes comments and linked PRs.

```bash
stale_days=14
gh issue list --state open --json number,updatedAt --jq ".[] | select((.updatedAt | sub(\"\\\\.[0-9]+Z$\"; \"Z\") | strptime(\"%Y-%m-%dT%H:%M:%SZ\") | mktime) < (now - ($stale_days * 86400))) | .number"
```

For each stale issue, check for linked PRs:

```bash
gh issue view <issue-number> --json timelineItems --jq '[.timelineItems[] | select(.typename == "CrossReferencedEvent") | .source.url]'
```

If no linked PRs and no recent comments, the issue is stale. Suggested action: triage the issue — confirm it is still relevant, close it, or break it into smaller items.

8. Compile all findings into a markdown report with one section per category.

9. Write the report to `.reconcile-ops/nightly-inspect-report.md`, overwriting the previous report.

10. If `--create-issues` is set, create a single GitHub issue per high-priority finding. High-priority findings are:
    - Orphan PRs
    - Goals past Deadline
    - Goals missing Acceptance Criteria or Verification Method

    Use this issue body template:

```md
## Source

Nightly Inspect report: [report link]

## Finding

<finding description>

## Suggested Action

<suggested action>

---
*This issue was created by rco-nightly-inspect. Close it when the finding is resolved.*
```

11. Report the total findings count and the report path.

## Implementation Templates

Report structure:

```md
# Nightly Inspect Report

Repository: OWNER/REPO
Date: YYYY-MM-DD
Stale threshold: N days

## Orphan PRs

| PR | What is missing | Suggested action |
| --- | --- | --- |
| #123 | No Goal ID reference | Add Goal reference or create Goal |

## Goals without GitHub Issues

| Goal | What is missing | Suggested action |
| --- | --- | --- |
| G-000001 | No issue in GOAL_ISSUE_MAP.json | Run rco-create-issue |

## Incomplete Goals

| Goal | Missing section | Suggested action |
| --- | --- | --- |
| G-000002 | Acceptance Criteria, Verification Method | Update Goal file |

## Goals past Deadline

| Goal | Deadline | Suggested action |
| --- | --- | --- |
| G-000003 | 2025-01-15 (passed) | Triage: extend, close, or split |

## Doc Debt

| File | What is missing | Suggested action |
| --- | --- | --- |
| docs/requirements/auth.md | No Goal references this requirement | Create Goal |
| docs/goals/G-000001.md | No spec found | Create spec |

## PRs missing Scope or Decision Owner

| PR | What is missing | Suggested action |
| --- | --- | --- |
| #124 | No Capability Scope | Add Scope to PR body |
| #125 | No Decision Owner | Add Decision Owner to PR body |

## Stale Issues

| Issue | Last activity | Suggested action |
| --- | --- | --- |
| #45 | 21 days ago | Triage: confirm relevance or close |

## Summary

- Orphan PRs: N
- Goals without issues: N
- Incomplete Goals: N
- Goals past Deadline: N
- Doc Debt items: N
- PRs missing Scope or Decision Owner: N
- Stale Issues: N
- Total findings: N
```

Config extension:

```json
{
  "branch_prefix": "ai/",
  "github_project_url": "https://github.com/orgs/OWNER/projects/1",
  "github_project_id": "PVT_xxxxx",
  "inspect_stale_days": 14
}
```

Useful commands:

```bash
gh repo view --json nameWithOwner,defaultBranchRef
gh pr list --state open --json number,title,body,updatedAt
gh issue list --state open --json number,updatedAt
gh issue view <number> --json state,body,timelineItems
gh pr diff <number> --name-only
rg -o 'G-[0-9]{6}' docs/goals .reconcile-ops/GOAL_ISSUE_MAP.json
rg -c '## Acceptance Criteria|## Verification Method|## Deliverable|## Deadline' docs/goals/G-000001.md
jq '.[] | keys' .reconcile-ops/GOAL_ISSUE_MAP.json
```

## Bundled Resources

- `.reconcile-ops/examples/goal.md`: Goal structure reference for checking required L1 sections.
- `.reconcile-ops/GOAL_ISSUE_MAP.json`: Goal-to-issue mapping used to verify issue existence.

## Agent Feedback Loop

If `gh` commands fail because the repository has no GitHub remote, stop and report that Nightly
Inspect requires a GitHub-connected repository. If `GOAL_ISSUE_MAP.json` does not exist, treat
every Goal as a "Goals without GitHub Issues" finding and suggest running `rco-create-issue`. If
no Goal files exist under `docs/goals/`, report that the project has no Goals to inspect and note
this as potential doc debt if `docs/requirements/` is non-empty.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "The report is long, so trim it." | Do not suppress findings. The report makes invisible drift visible. |
| "This orphan PR is probably fine." | Report it. Human triage decides whether it is fine. |
| "I'll fix the incomplete Goal now." | Nightly Inspect is READ-ONLY. Report the finding and suggest the user update the Goal. |
| "The stale threshold is too sensitive." | Use `inspect_stale_days` from config. Suggest the user adjust it if too noisy. |
| "Skip doc debt; it's not urgent." | Doc debt is drift. Report all findings regardless of urgency. |
| "Create issues for everything." | Only create issues for high-priority findings when `--create-issues` is set. |
| "The PR body has implied scope." | Scope must be explicit in the PR body. Report missing explicit mentions. |
| "I already know this project is clean." | Run the full scan. Assumptions are not inspections. |

## Red Flags

- Nightly Inspect modifies files, closes issues, or updates Project status
- Findings are omitted from the report to keep it short
- Orphan PRs are dismissed without reporting
- Incomplete Goals are "fixed" during the inspection instead of reported
- The report does not include specific file paths, issue numbers, or PR numbers
- `--create-issues` creates issues for low-priority findings
- Issue body does not mention it was created by `rco-nightly-inspect`
- Staleness check uses a hardcoded threshold instead of `inspect_stale_days` from config
- The previous report is preserved instead of overwritten
- Agent proceeds when `.reconcile-ops/config.json` is missing without telling the user to run `rco-setup`

## Verification

- [ ] `.reconcile-ops/config.json` was read
- [ ] If `.reconcile-ops/config.json` was missing, user was told to run `rco-setup`
- [ ] `inspect_stale_days` was read from config (default 14 used if absent)
- [ ] All open PRs were collected and inspected
- [ ] All Goal files under `docs/goals/` were scanned
- [ ] `.reconcile-ops/GOAL_ISSUE_MAP.json` was read if it exists
- [ ] Orphan PRs were identified (no Goal ID in title, body, or diff)
- [ ] Goals without GitHub issues were identified
- [ ] Incomplete Goals were identified (missing L1 sections)
- [ ] Goals past Deadline were identified
- [ ] Doc debt was identified (orphan requirements, Goals without specs, specs without PRs)
- [ ] PRs missing Scope or Decision Owner were identified
- [ ] Stale issues were identified using `inspect_stale_days` threshold
- [ ] Report was written to `.reconcile-ops/nightly-inspect-report.md`
- [ ] Previous report was overwritten, not appended
- [ ] Each finding includes specific identifier, what is missing, and suggested action
- [ ] No files, issues, or Project state were modified (unless `--create-issues` was set)
- [ ] If `--create-issues` was set, only high-priority findings received issues
- [ ] Created issues mention `rco-nightly-inspect` in the body
- [ ] Total findings count and report path were reported to the user
