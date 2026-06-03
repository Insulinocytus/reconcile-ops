---
name: rco-create-adr-issue
description: Use when a technical decision needs to be made and recorded as an ADR, or when a past decision is being reconsidered and a new ADR supersedes it.
---

# RCO Create ADR Issue

Before doing any work, read `.reconcile-ops/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Create a GitHub Issue to record a technical decision as an Architecture Decision Record.
ADRs live as Issues because decisions emerge from discussion, may change, and should not
require a PR to create or update. Once closed, the conclusion is extracted by
`rco-create-adr-md` into the consolidated Git file.

## When to Use

- A technical decision needs to be made and the reasoning should be visible
- Two or more approaches are being considered and a choice must be recorded
- A past ADR is being superseded by a new decision

## Core Principles

- ADR Issues use the label `adr`.
- ADR Issue title format is `[ADR-0001] <short decision description>`.
- Allocate ADR IDs sequentially from the highest existing ADR number in open and closed issues.
- Never reuse an ADR ID.
- Structure the body with Consequences first so readers see the conclusion before the context.
- If this ADR supersedes a previous one, link to the old ADR Issue in the Supersedes section.
- Do not write ADR content into Git files. That is the job of `rco-create-adr-md`.

## Standard Workflow

1. Read `.reconcile-ops/config.json` unless already read in this session. If it does not exist, stop and tell the user to run `rco-setup` first.
2. Identify the technical decision that needs to be recorded.
3. Allocate the next ADR ID by scanning existing issues with the `adr` label:

```bash
gh issue list --label adr --state all --json title --jq '.[].title' | rg -o 'ADR-[0-9]+' | rg -o '[0-9]+' | sort -n | tail -1
```

4. Create the ADR Issue:

- title: `[ADR-0001] <short decision description>`
- label: `adr`
- body:

```md
## Consequences

- <what changes or results from this decision>
- <impact on existing systems, patterns, or workflows>

## Context

- <what triggered this decision>
- <what alternatives were considered>

## Decision

- <what was decided>

## Supersedes

(Empty, or: Closes #[previous ADR issue number])
```

5. If the ADR supersedes a previous one, add `Closes #[previous ADR issue number]` in the Supersedes section so the old Issue closes when the new one is closed.
6. Report the Issue URL.

## Implementation Templates

ADR Issue (standalone):

```md
## Consequences

- All session data moves from Redis to PostgreSQL
- Redis dependency is removed from the auth service

## Context

- Session storage currently uses Redis but the team has no Redis operational expertise
- PostgreSQL is already operational and the team is comfortable managing it
- Evaluated: Redis (current), PostgreSQL, DynamoDB

## Decision

- Use PostgreSQL for session storage

## Supersedes
```

ADR Issue (superseding):

```md
## Consequences

- Session storage moves from PostgreSQL back to Redis with Redis Cluster
- PostgreSQL session table will be migrated and removed

## Context

- ADR-0001 chose PostgreSQL for session storage due to lack of Redis expertise
- Team has since completed Redis operations training
- Session read latency under PostgreSQL has become a bottleneck at scale

## Decision

- Migrate session storage to Redis Cluster

## Supersedes

Closes #12
```

## Agent Feedback Loop

If the decision is not yet made and still under discussion, create the Issue anyway with
the known context and alternatives. The Decision and Consequences sections can be filled in
as the discussion resolves. If the decision is trivial and needs no record (e.g., obvious
dependency upgrade), do not create an ADR.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "Write the ADR into a Git file instead." | ADR Issues are discussion-grade. Git files come from `rco-create-adr-md`. |
| "This decision is too small for an ADR." | If it affects architecture or other developers, record it. If it is trivial, skip it. |
| "Reopen the old ADR Issue instead of creating a new one." | Supersede with a new ADR. The old one stays closed for traceability. |
| "The ADR needs a PR review." | ADR Issues do not require PR review. They record decisions, not deliverables. |

## Red Flags

- ADR Issue is missing the `adr` label
- ADR Issue title does not start with `[ADR-0001]`
- ADR ID is reused
- Body structure is not Consequences / Context / Decision / Supersedes
- Superseded ADR Issue is reopened instead of a new ADR being created
- ADR content is written into a Git file by this skill
- Agent proceeds when `.reconcile-ops/config.json` is missing without telling the user to run `rco-setup`

## Verification

- [ ] `.reconcile-ops/config.json` was read
- [ ] If `.reconcile-ops/config.json` was missing, user was told to run `rco-setup`
- [ ] ADR ID is next sequential number from existing ADR Issues
- [ ] ADR ID was not reused
- [ ] Issue has the `adr` label
- [ ] Issue title uses `[ADR-0001] <description>` format
- [ ] Body follows Consequences / Context / Decision / Supersedes structure
- [ ] If superseding, the old ADR Issue number is linked in Supersedes
- [ ] No ADR content was written to Git files
