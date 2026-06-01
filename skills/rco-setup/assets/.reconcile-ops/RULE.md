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

- Git stores durable artifacts only: rules, examples, requirements, goals, specs, and issue mappings.
- Git must not store project status, owner, milestone, priority, or progress.
- Raw client input must not be committed.
- Unconfirmed questions must not be committed.
- Explicitly rejected or excluded client requests must be recorded when they are stable.
- Requirement documents are cleaned requirement packages, not raw transcripts.
- Goal documents are verifiable delivery goals, not tickets or project status records.
- Spec documents are code foundation designs, not implementation tasks, tickets, or project status records.

## Language

- `.reconcile-ops/config.json` stores the preferred ReconcileOps language.
- The config shape is:

```json
{
  "preferred_language": "en"
}
```

- Supported language values are `en`, `zh`, and `jp`.
- Every issue, PR, document, and other user-facing artifact created through an `rco-*` skill must use the language specified by `.reconcile-ops/config.json`.
- Every `rco-*` skill must read `.reconcile-ops/config.json` before creating user-facing output.
- Top-level files under `.reconcile-ops/examples/*.md` are language symlinks managed by `rco-setup`.
- Language-specific examples live under `.reconcile-ops/examples/<language>/`.

## Specs

- Specs live under `docs/specs/`.
- Use `specs` because the repository already uses plural document roots such as `docs/requirements/` and `docs/goals/`.
- Specs are organized by business logic area, then by specific capability or flow.
- Spec paths use this shape:

```txt
docs/specs/<business-area>/<capability-or-flow>.md
```

- Example paths:

```txt
docs/specs/auth/login.md
docs/specs/auth/logout.md
docs/specs/billing/invoice-generation.md
```

- A spec must be grounded in one or more requirements or goals.
- Requirement and Goal references in specs must use Markdown relative links.
- A spec should describe the baseline design needed before coding, including behavior, boundaries, interfaces, data contracts, validation rules, error handling, and verification approach when relevant.
- A spec must not contain project status, owner, milestone, priority, progress, created time, or updated time.
- A spec must not contain unconfirmed questions or raw client input.
