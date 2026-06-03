---
name: rco-define-goal
description: Define verifiable ReconcileOps Goals from cleaned requirement documents. Use when Codex needs to create docs/goals/G-*.md from one or more docs/requirements/*.md files, allocate a non-reused Goal ID, and ensure Source Requirements are Markdown relative links.
---

# RCO Define Goal

Before doing any work, read `.reconcile-ops/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Convert stable requirement documents into verifiable delivery Goals. A Goal is a durable
artifact with a unique ID, concrete deliverable, acceptance criteria, and verification method.
It is not a GitHub Project issue and must not contain status metadata.

## When to Use

- Creating one or more Goals from `docs/requirements/*.md`
- Turning client intent into verifiable delivery outcomes
- Allocating new `G-000001` style Goal IDs
- Updating a Goal's durable content after requirement changes

## Core Principles

- Do not write project status, owner, milestone, priority, progress, timestamps, or open questions.
- Do not create a Goal when requirements are too ambiguous to verify.
- Use Markdown relative links in `Source Requirements`.
- Allocate Goal IDs from observed current files, issue mappings, and Git history.
- Never reuse a Goal ID.


## Standard Workflow

1. Read `.reconcile-ops/config.json` unless already read in this session. If it does not exist, stop and tell the user to run `rco-setup` first.
2. Read `.reconcile-ops/examples/goal.md` for structure only.
3. Read the source requirement file or files.
4. Decide whether the requirement content is stable enough to produce a verifiable Goal.
5. Allocate the next Goal ID:
   - scan `docs/goals/**/*.md`
   - read keys from `.reconcile-ops/GOAL_ISSUE_MAP.json`
   - inspect Git history for previous `docs/goals/G-*.md` paths
   - choose the next integer greater than every observed Goal ID
6. Create `docs/goals/G-000001.md` using the allocated ID.
7. Include:
   - `Goal`
   - `Source Requirements`
   - `Client Intent`
   - `Deliverable`
   - `Acceptance Criteria`
   - `Verification Method`
8. Stop and report missing confirmations if the Goal cannot be made verifiable.
9. Verify no state metadata appears in the Goal file.
10. Remind the user to run `rco-create-pr` for the Goal document changes.

## Implementation Templates

Goal structure:

```md
# G-000001: <Goal Title>

## Goal

...

## Source Requirements

- [Requirement Title](../requirements/<business-topic>.md)

## Client Intent

...

## Deliverable

...

## Acceptance Criteria

- [ ] ...

## Verification Method

...
```

Goal ID discovery commands:

```bash
rg -o 'G-[0-9]{6}' docs/goals .reconcile-ops/GOAL_ISSUE_MAP.json
git log --name-only --pretty=format: -- docs/goals | rg 'docs/goals/G-[0-9]{6}\\.md'
```

## Bundled Resources

- `.reconcile-ops/examples/goal.md`: Example Goal using a todo web app. Reference the structure only.

## Agent Feedback Loop

If a requirement lacks a concrete deliverable, acceptance criteria, or verification method,
do not create a speculative Goal. Explain the missing confirmations in the response and leave
Git unchanged unless another Goal can be safely defined.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "This Goal needs an owner." | Owner belongs in GitHub Project or issue metadata, not the Goal file. |
| "This belongs to a milestone." | Milestone belongs in GitHub Project or issue metadata, not the Goal file. |
| "The next ID is missing, so reuse it." | Goal IDs are never reused; use the next greater observed ID. |
| "The requirement path is obvious." | Use a Markdown relative link in `Source Requirements`. |

## Red Flags

- Goal file contains `status`, `owner`, `milestone`, priority, progress, created time, or updated time
- Goal file contains `Open Questions` or `Out of Scope`
- Goal ID is reused
- `Source Requirements` are plain text paths instead of Markdown links
- Acceptance criteria are vague or unverifiable
- Agent proceeds when `.reconcile-ops/config.json` is missing without telling the user to run `rco-setup`

## Verification

- [ ] `.reconcile-ops/config.json` was read
- [ ] If `.reconcile-ops/config.json` was missing, user was told to run `rco-setup`
- [ ] Output path is `docs/goals/G-*.md`
- [ ] Goal ID is next greater observed ID
- [ ] Goal ID was not reused
- [ ] `Source Requirements` uses Markdown relative links
- [ ] Goal has acceptance criteria and verification method
- [ ] Goal file has no project status metadata
- [ ] User is reminded to run `rco-create-pr`
