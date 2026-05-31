---
name: rco-distill-req
description: Distill messy client input into a cleaned ReconcileOps requirement document. Use when Codex receives meeting notes, STT transcripts, Notion pages, Slack messages, emails, client feedback, or PM notes and needs to create or update docs/requirements/<business-topic>.md without committing raw input or unconfirmed questions.
---

# RCO Distill Requirement

Before doing any work, read `.reconcile-ops/RULE.md`.

## Overview

Turn messy client input into a stable requirement package. The output is not a transcript,
ticket, Goal, or project status record. It is a durable summary of what the client wants,
what the client explicitly does not want, and stable constraints.

## When to Use

- Converting client meeting notes into a requirement document
- Condensing STT transcripts, Slack threads, emails, Notion notes, or PM notes
- Updating `docs/requirements/<business-topic>.md` after stable client intent changes
- Separating confirmed requirements from raw discussion noise

## Core Principles

- Read `.reconcile-ops/RULE.md` before doing any work.
- Do not commit raw client input.
- Do not write unconfirmed questions into Git.
- Record explicitly unwanted scope when it is stable.
- Keep requirement files business-topic level, not one file per sentence or source.
- Do not create Goals in this skill.

## Standard Workflow

1. Read `.reconcile-ops/RULE.md`.
2. Read `.reconcile-ops/examples/requirement.md` for structure only.
3. Review the provided messy input.
4. Identify the business topic and choose a kebab-case file name under `docs/requirements/`.
5. Write only stable content into the requirement document:
   - `Context`
   - `Client Wants`
   - `Client Does Not Want`
   - `Constraints`
6. Keep unresolved questions out of the file.
7. Report unresolved questions in the final response as PM follow-up items.
8. Verify the output contains no status metadata, internal IDs, timestamps, raw transcript, or source dump.

## Implementation Templates

Use this structure:

```md
# Requirement: <Business Topic>

## Context

...

## Client Wants

- ...

## Client Does Not Want

- ...

## Constraints

- ...
```

## Bundled Resources

- `.reconcile-ops/examples/requirement.md`: Example requirement document using a todo web app. Reference the structure only.

## Agent Feedback Loop

If the input is too unclear to produce stable requirements, do not invent facts. Stop, summarize
the missing confirmations in the response, and do not write a requirement file unless stable
content remains.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "The transcript is useful context, so commit it." | Do not commit raw client input. Distill only stable requirements. |
| "Questions are important, so put them in the file." | Report questions in the response; do not write unconfirmed questions into Git. |
| "A single client sentence deserves a file." | Group requirements by business topic. |
| "This is probably a Goal." | Requirements and Goals are separate artifacts. Use `rco-define-goal` later. |

## Red Flags

- File contains raw transcript, Slack dump, email dump, or STT text
- File contains `status`, `owner`, `milestone`, priority, progress, created time, or updated time
- File contains open questions or unresolved assumptions
- Requirement file is named after a meeting date instead of a business topic
- The output includes Goal IDs

## Verification

- [ ] `.reconcile-ops/RULE.md` was read
- [ ] Output path is `docs/requirements/<business-topic>.md`
- [ ] Requirement is grouped by business topic
- [ ] Raw input is not committed
- [ ] Unconfirmed questions are not written into Git
- [ ] Explicitly unwanted scope is recorded when stable
- [ ] No project status metadata appears in the file
