---
name: rco-nightly-inspect
description: Use when running a scheduled or manual drift inspection across Goals, Issues, recent PRs, and ADR records to detect invisible misalignment.
---

# RCO Nightly Inspect

Before doing any work, read `.rco/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Scan the project for drift between Git-layer artifacts and GitHub-layer state. Produce a
drift report and, where appropriate, create compensating issues. Do not modify any existing
artifacts directly.

## When to Use

- Running a scheduled nightly inspection
- Manually checking whether Goals, Issues, PRs, and ADR records are aligned
- After a period of heavy activity to verify no drift accumulated

## Core Principles

- Inspect is read-only. Create new issues to flag drift; do not modify existing files, existing issues, or PRs.
- Inspect must not edit existing Goal Issues, including Acceptance Criteria checklist items. It only reports drift and creates compensating `drift` issues.
- Only check the baseline drift categories defined here. Do not add speculative checks.
- An orphan PR is only a PR that directly advances a Goal's implementation but lacks a Goal link. Maintenance PRs (CI, typo, tooling, config) are not orphans.

## Standard Workflow

1. Read `.rco/config.json` unless already read in this session. If it does not exist, stop and tell the user to run `rco-setup` first.
2. Run all five checks. Collect findings into a single drift report.
3. For each finding, create a compensating issue labeled `drift` with a description of the misalignment and a suggested fix.
4. Report the total findings and issue URLs.

### Check 1: Goal↔Issue Alignment

Collect all Goal files, Goal Issues, and GitHub Project status values, then compare:

```bash
# Goal files
rg -o 'G-[0-9]{6}' docs/goals --no-filename | sort -u

# Goal Issues
gh issue list --label goal --state all --json number,title

# Goal Project status
gh project item-list <project-number> --owner <org-or-user> --format json
```

Findings:
- Goal file has no corresponding Issue → create Issue (per `rco-create-goal-issue` rules)
- Goal Issue has no corresponding Goal file → flag as dangling Issue
- Goal file has `> **Superseded**` but GitHub Project Status is not Superseded → flag status mismatch
- GitHub Project Status is Superseded but Goal file has no Superseded marker → flag status mismatch

### Check 2: Goal Acceptance Criteria Drift

Compare each Goal file's `## Acceptance Criteria` list with the corresponding Goal Issue's `## Acceptance Criteria` checklist.

```bash
gh issue list --label goal --state all --json number,title,body,state
```

Findings:
- Goal file Acceptance Criteria item has no matching Issue checklist item → flag as missing checklist item
- Issue checklist item has no matching Goal file Acceptance Criteria item → flag as stale checklist item
- Matching item text differs between Goal file and Issue checklist → flag as text drift
- Issue is missing an Acceptance Criteria checklist section → flag as missing checklist

Rules:
- Do not edit the Goal Issue body.
- Do not check or uncheck checklist items.
- Do not delete stale checklist items.
- If automatic synchronization is needed, tell the user to use a separate sync skill; nightly inspect only reports drift.

### Check 3: Goal Issue Missing Milestone

```bash
gh issue list --label goal --state all --json number,title,milestone
```

Findings:
- Goal Issue has no milestone → flag as missing deadline

### Check 4: Orphan PR

List recently closed PRs (last 3 days):

```bash
gh pr list --state closed --search "closed:>=3 days ago" --json number,title,body,url
```

For each PR, determine whether it directly advances a Goal's implementation. A PR that only changes documentation (Goals, requirements, ADRs, README, config), CI/CD, typo fixes, or tooling is NOT an implementation PR. If an implementation PR's body does not contain a `#` reference to a Goal Issue, flag it as orphan.

### Check 5: docs/adr.md Out of Sync

Compare closed ADR Issues against the consolidated file:

```bash
gh issue list --label adr --state closed --json number,title,body
cat docs/adr.md
```

Findings:
- Closed ADR Issue has no entry in `docs/adr.md` → flag as missing
- Entry in `docs/adr.md` references an ADR Issue that is no longer closed (reopened) → flag as stale
- Entry status says Active but a newer closed ADR supersedes it → flag as stale

## Drift Report Template

```md
# Drift Report — <date>

## Goal↔Issue Alignment

| Finding | Goal ID | Issue # | Detail |
|---------|---------|---------|--------|
| ... | ... | ... | ... |

## Goal Acceptance Criteria Drift

| Goal ID | Issue # | Finding | Detail |
|---------|---------|---------|--------|
| ... | ... | ... | ... |

## Missing Milestones

| Issue # | Title |
|---------|-------|
| ... | ... |

## Orphan PRs

| PR # | Title |
|------|-------|
| ... | ... |

## ADR Out of Sync

| Finding | ADR ID | Detail |
|---------|--------|--------|
| ... | ... | ... |

**Total findings: X**
```

## Agent Feedback Loop

If GitHub API calls fail due to rate limits or missing repo context, report the failure and
continue with the checks that can still run. If no drift is found, report "No drift detected."
Do not create issues for zero findings.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "Fix the drift directly." | Inspect is read-only. Create a compensating issue instead. |
| "Sync the Goal Issue checklist automatically." | Do not edit existing Goal Issues in nightly inspect. Report Acceptance Criteria drift only. |
| "Every PR without a Goal is an orphan." | Only implementation PRs that directly advance a Goal need Goal links. Maintenance PRs are not orphans. |
| "Check all PRs, not just recent ones." | Only check the last 3 days. Older drift is historical, not actionable nightly. |
| "Update docs/adr.md directly." | Flag the gap in an issue. Let `rco-create-adr-md` do the update. |
| "Skip a check because it probably has no findings." | Run all five checks every time. Assumptions are the source of invisible drift. |

## Red Flags

- Inspect modifies existing files, existing issues, or PRs instead of creating compensating issues
- Inspect edits, checks, unchecks, deletes, or rewrites Goal Issue Acceptance Criteria checklist items
- Goal Acceptance Criteria drift between Goal files and Goal Issue checklists is not checked
- Maintenance PRs are flagged as orphans
- PRs older than 3 days are included in orphan check
- Check is skipped based on assumption
- docs/adr.md is modified directly instead of flagging via issue
- No drift report is produced
- Agent proceeds when `.rco/config.json` is missing without telling the user to run `rco-setup`

## Verification

- [ ] `.rco/config.json` was read
- [ ] If `.rco/config.json` was missing, user was told to run `rco-setup`
- [ ] All five checks were run
- [ ] Goal↔Issue alignment was verified per rco-create-goal-issue rules
- [ ] Goal file Acceptance Criteria were compared against Goal Issue checklist items
- [ ] Acceptance Criteria drift was reported without editing existing Goal Issues
- [ ] Goal Issues missing milestones were flagged
- [ ] Only recent (3 days) closed implementation PRs without Goal links were flagged as orphans
- [ ] Closed ADR Issues were compared against docs/adr.md
- [ ] No existing artifacts were modified directly
- [ ] Compensating issues were created with `drift` label
- [ ] Drift report was produced
