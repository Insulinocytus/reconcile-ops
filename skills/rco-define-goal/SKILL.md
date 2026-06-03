---
name: rco-define-goal
description: Use when creating or updating a Goal document under docs/goals/, or when marking a Goal as Superseded.
---

# RCO Define Goal

Before doing any work, read `.reconcile-ops/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Convert stable requirement documents into verifiable delivery Goals. A Goal is an
append-only Git artifact with a unique ID and acceptance criteria. It is not a GitHub
Project issue and must not contain status, deadline, or scope information — those belong
in the Issue layer.

## When to Use

- Creating one or more Goals from `docs/requirements/*.md`
- Marking a Goal as Superseded when it is no longer active
- Allocating new `G-000001` style Goal IDs

## Core Principles

- Goal files are append-only. Never delete a Goal file. To deactivate, add `> **Superseded**` on the line before the title.
- Do not write status, deadline, milestone, priority, progress, timestamps, owner, scope, or open questions into the Goal file.
- Do not create a Goal when requirements are too ambiguous to write concrete acceptance criteria.
- Use Markdown relative links in `Source Requirements`.
- Allocate Goal IDs from observed current files, issue mappings, and Git history.
- Never reuse a Goal ID.
- A single Requirement may produce multiple Goals over time (different delivery phases). A single Goal may reference multiple Requirements (cross-cutting delivery).

## Standard Workflow

1. Read `.reconcile-ops/config.json` unless already read in this session. If it does not exist, stop and tell the user to run `rco-setup` first.
2. Read the source requirement file or files.
3. Decide whether the requirement content is stable enough to produce a Goal with concrete acceptance criteria.
4. Allocate the next Goal ID:
   - scan `docs/goals/**/*.md`
   - inspect Git history for previous `docs/goals/G-*.md` paths
   - choose the next integer greater than every observed Goal ID
5. Create `docs/goals/G-000001.md` using the allocated ID with this structure:

```md
# G-000001: <Goal Title>

## Source Requirements

- [Requirement Title](../requirements/<business-topic>.md)

## Acceptance Criteria

- ...
```

6. If the user requests deactivating a Goal, add `> **Superseded**` on the line before the H1 title. Do not delete the file or remove its content.
7. Stop and report missing confirmations if acceptance criteria cannot be made concrete.
8. Verify no state metadata appears in the Goal file.
9. Remind the user to run `rco-create-pr` for the Goal document changes, then `rco-create-goal-issue` to create or update the corresponding Issue.

## Implementation Templates

Goal file (active):

```md
# G-000001: Basic Auth Login

## Source Requirements

- [Login System](../requirements/login-system.md)

## Acceptance Criteria

- User can log in with username and password
- Failed login shows an error message
- Session persists for 30 minutes
```

Goal file (superseded):

```md
> **Superseded**

# G-000002: Google OIDC Login

## Source Requirements

- [Login System](../requirements/login-system.md)

## Acceptance Criteria

- User can log in via Google Workspace OIDC
- OIDC login replaces Basic Auth as the default
- Existing sessions migrate without forcing re-login
```

Goal ID discovery commands:

```bash
rg -o 'G-[0-9]{6}' docs/goals
git log --name-only --pretty=format: -- docs/goals | rg 'docs/goals/G-[0-9]{6}\\.md'
```

## Agent Feedback Loop

If a requirement lacks enough clarity to write concrete acceptance criteria, do not create a
speculative Goal. Explain what is missing in the response and leave Git unchanged unless another
Goal can be safely defined.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "This Goal needs an owner." | Owner belongs in PR review routing, not the Goal file. |
| "This belongs to a milestone." | Deadline belongs in the GitHub Issue milestone, not the Goal file. |
| "The next ID is missing, so reuse it." | Goal IDs are never reused; use the next greater observed ID. |
| "The requirement path is obvious." | Use a Markdown relative link in `Source Requirements`. |
| "Delete this Goal, it's cancelled." | Goal files are append-only. Add `> **Superseded**` instead. |
| "Add scope to the Goal file." | Scope belongs in the Issue layer, not the Goal file. |

## Red Flags

- Goal file contains `status`, `owner`, `milestone`, `deadline`, priority, progress, created time, or updated time
- Goal file contains `Open Questions`, `Out of Scope`, or `Scope`
- Goal ID is reused
- `Source Requirements` are plain text paths instead of Markdown links
- Acceptance criteria are vague or unverifiable
- A Goal file is deleted instead of marked Superseded
- Agent proceeds when `.reconcile-ops/config.json` is missing without telling the user to run `rco-setup`

## Verification

- [ ] `.reconcile-ops/config.json` was read
- [ ] If `.reconcile-ops/config.json` was missing, user was told to run `rco-setup`
- [ ] Output path is `docs/goals/G-*.md`
- [ ] Goal ID is next greater observed ID
- [ ] Goal ID was not reused
- [ ] `Source Requirements` uses Markdown relative links
- [ ] Goal has concrete acceptance criteria
- [ ] Goal file has no status, deadline, milestone, owner, or scope metadata
- [ ] If deactivating, `> **Superseded**` was added before the title, file was not deleted
- [ ] User is reminded to run `rco-create-pr` then `rco-create-goal-issue`
