---
name: rco-create-issue
description: Use when creating a GitHub issue that is neither a Goal Issue nor an ADR Issue
---

# RCO Create Issue

Distill messy input or interactive Q&A into a three-section GitHub Issue: Why / TODO / References.

Before any work, read `.rco/config.json` unless already read this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## When to Use

- Creating a non-Goal, non-ADR GitHub Issue (bug, feature, chore, refactor, etc.)
- Distilling messy input (meeting notes, Slack dumps, transcripts) into a structured issue
- Creating an issue via interactive Q&A when no input is available

## When NOT to Use

- Goal Issues → `rco-create-goal-issue`
- ADR Issues → `rco-create-adr-issue`

## Core Principles

1. **Dirty data → smart generation.** When the user provides messy input, distill directly. No interview needed.
2. **No input → interview.** Ask one question at a time to build the issue incrementally.
3. **Three sections only: Why / TODO / References.** No extra sections.
4. **No labels.** This project does not use labels.

## Standard Workflow

1. Determine input mode:
   - **Dirty data provided** (transcript, Slack dump, notes) → skip to Step 3.
   - **No input** → enter interview mode (Step 2).
2. **Interview mode** — ask one question at a time:
   - "What problem are we solving?" → builds **Why**
   - "What are the concrete tasks?" → builds **TODO**
   - "Any related Goals, ADRs, or Issues?" → builds **References** (optional)
3. Distill into three sections:
   - **Why** — 1–3 sentences on why this issue exists.
   - **TODO** — flat checklist, one concrete action per item.
   - **References** — optional links to Goals, ADRs, or other Issues.
4. Create the issue via `gh issue create`.

## Issue Body Template

```md
## Why

<1–3 sentences>

## TODO

- [ ] <task 1>
- [ ] <task 2>

## References

- <link to Goal, ADR, or Issue>
```

## Implementation

```bash
gh issue create --title "<title>" --body-file /tmp/issue-body.md
```

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Pasting raw input into the issue body | Always distill, never paste |
| Vague TODOs like "improve performance" | Each TODO must be a concrete, checkable action |
| Writing a paragraph in Why | Keep Why under 3 sentences |
| Asking all interview questions at once | One question at a time |
| Applying GitHub labels | This project does not use labels |

## Red Flags

- Issue body does not follow Why / TODO / References structure
- Body contains raw, undistilled input
- TODO items are vague ("improve performance") instead of concrete actions
- Interview mode asks multiple questions at once

## Verification

- [ ] `.rco/config.json` was read
- [ ] Dirty input was distilled, not pasted
- [ ] Body follows Why / TODO / References
- [ ] Each TODO item is concrete and checkable
- [ ] No labels were applied
