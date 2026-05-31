# ReconcileOps Rules

This file defines shared rules for ReconcileOps v1. It stores business and naming rules only.
It must not store workflow state, ownership state, project status, milestone, priority, progress,
or other GitHub Project metadata.

## Goal IDs

- Goal IDs use the format `G-000001`.
- Goal IDs are globally unique.
- Goal IDs must never be reused.
- When allocating a new Goal ID, inspect:
  - existing files under `docs/goals/**/*.md`
  - keys in `.reconcile-ops/GOAL_ISSUE_MAP.json`
  - Git history for previously tracked `docs/goals/G-*.md` files
- Allocate the next integer greater than every observed Goal ID.

## GitHub Issues

- GitHub issue titles for Goals use this format:

```txt
[G-000001] Goal Title
```

- A Goal maps to exactly one GitHub Project issue.
- `.reconcile-ops/GOAL_ISSUE_MAP.json` stores only `goal id -> issue id`.
- GitHub Project and issue metadata own milestone, owner, status, priority, and progress.

## Git-Tracked Documents

- Git stores durable artifacts only: rules, examples, requirements, Goals, and issue mappings.
- Git must not store project status, owner, milestone, priority, or progress.
- Raw client input must not be committed.
- Unconfirmed questions must not be committed.
- Explicitly rejected or excluded client requests must be recorded when they are stable.
- Requirement documents are cleaned requirement packages, not raw transcripts.
- Goal documents are verifiable delivery goals, not tickets or project status records.
