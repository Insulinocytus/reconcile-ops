---
name: rco-distill-req
description: Use when receiving meeting notes, STT transcripts, Notion pages, Slack messages, emails, client feedback, or interview-style Q&A that needs to become or update a requirement document under docs/requirements/.
---

# RCO Distill Requirement

Before doing any work, read `.rco/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Turn messy client input into a stable requirement package. The output is not a transcript,
ticket, Goal, or project status record. It is a durable record of who is in what situation,
what they confirmed they need, what they confirmed they permanently don't need, and what
still needs clarification. Prioritization, scope phasing, and solution design belong in Goals
and specs, not here.

## When to Use

- Converting client meeting notes into a requirement document
- Condensing STT transcripts, Slack threads, emails, Notion notes, or PM notes
- Running an interview-style requirement intake one question at a time
- Updating `docs/requirements/<business-topic>.md` after stable client intent changes
- Separating confirmed requirements from raw discussion noise

## Core Principles

- Do not commit raw client input.
- Do not write unconfirmed assumptions as facts. Write them as pending questions instead.
- Situations describe real people in real contexts with real problems — not feature requests in disguise.
- User Confirmed Needs are only what the user explicitly stated they need. Inferred needs belong in Goals.
- User Confirmed Doesn't Need is for things the user permanently does not need. "Not this phase" belongs in Goals.
- Pending Confirmation captures ambiguous, unclear, or conflicting points that need user input before they can become Needs or Doesn't Need.
- Keep requirement files business-topic level, not one file per sentence or source.
- Do not create Goals in this skill.
- If no input is provided, list supported formats and offer interview-style intake before proceeding.
- When multiple sources provide conflicting requirements, do not resolve the conflict by assumption. Write the conflict as a Pending Confirmation item.


## Standard Workflow

1. Read `.rco/config.json` unless already read in this session. If it does not exist, stop and tell the user to run `rco-setup` first.
2. If no input was provided, list the supported input formats (meeting notes, STT transcripts, Notion pages, Slack messages, emails, client feedback) and offer interview-style intake. Do not proceed without input.
4. Review the provided messy input.
5. If the input from multiple sources contains conflicting requirements, stop and ask the user which intent takes priority. Do not silently resolve conflicts.
6. If the user requests interview-style intake, ask one focused question at a time until there is enough stable content to write the requirement document.
7. Identify the business topic from the input. Scan `docs/requirements/*.md` for an existing document whose title matches the same business topic.
   - If a matching document exists, read it and merge the new input into it:
     - **Situations**: add new H3 situations that are not already covered. Do not rewrite existing situations unless the new input directly contradicts them (in which case write the contradiction to Pending Confirmation).
     - **User Confirmed Needs**: add newly confirmed needs. Remove items only if the new input explicitly revokes them.
     - **User Confirmed Doesn't Need**: add newly confirmed exclusions. Remove items only if the new input explicitly revokes them.
     - **Pending Confirmation**: add new ambiguous points. Remove items that the new input resolves, moving them to Needs or Doesn't Need.
   - If no matching document exists, choose a kebab-case file name under `docs/requirements/` and proceed to create a new file.
8. Write the requirement document using the four-section structure:
   - **Situations**: each H3 names a situation and describes who is in what context, what problem they encounter, and what the consequence is.
   - **User Confirmed Needs**: only needs the user explicitly confirmed. Not inferred, not designed, not prioritized.
   - **User Confirmed Doesn't Need**: only things the user permanently does not need. Do not list deferred items here.
   - **Pending Confirmation**: ambiguous, unclear, or conflicting points that need user input. Use plain list format. Once confirmed, the item moves to Needs or Doesn't Need and is removed from this section.
9. Report the Pending Confirmation count in the final response. If the count is high relative to confirmed items, suggest the user resolve some before proceeding to Goal creation.
10. Verify the output contains no status metadata, internal IDs, timestamps, raw transcript, interview transcript, or source dump.
11. Ask the user whether to continue directly with `rco-define-goal` or run `rco-create-pr` first.

## Implementation Templates

Use this structure:

```md
# Requirement: <Business Topic>

## Situations

### <Situation 1>

Who is in what context, what problem they encounter, and what the consequence is.

### <Situation 2>

...

## User Confirmed Needs

- ...

## User Confirmed Doesn't Need

- ...

## Pending Confirmation

- <ambiguous point that needs user input>
- <conflicting statements from different sources>
```

## Agent Feedback Loop

If the input is too unclear to produce stable requirements, do not invent facts. Stop, summarize
the missing confirmations in the response, and do not write a requirement file unless stable
content remains.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "The transcript is useful context, so commit it." | Do not commit raw client input. Distill only stable requirements. |
| "Questions are important, so put them in the file." | Write questions as Pending Confirmation items in plain list format, not as resolved facts. |
| "The interview transcript should be saved." | Do not commit interview transcript. Distill only stable requirements. |
| "A single client sentence deserves a file." | Group requirements by business topic. Merge into an existing document when the topic matches. |
| "This is probably a Goal." | Requirements and Goals are separate artifacts. Use `rco-define-goal` later. |
| "The user probably also needs X." | Only record explicitly confirmed needs. Inferred needs go in Goals. If uncertain, add to Pending Confirmation. |
| "This is deferred to phase 2." | Deferred items belong in Goals, not in Doesn't Need. |
| "Constraints should be in the requirement." | Hard constraints that the user confirmed are User Confirmed Needs. Assumed constraints are not stable. |

## Red Flags

- File contains raw transcript, Slack dump, email dump, or STT text
- File contains interview transcript instead of distilled requirements
- File contains `status`, `owner`, `milestone`, priority, progress, created time, or updated time
- File contains unresolved assumptions presented as facts instead of Pending Confirmation items
- File contains inferred needs not explicitly confirmed by the user
- File contains deferred items in Doesn't Need instead of leaving them for Goals
- Situation is a feature request without context about who, when, and what problem
- Pending Confirmation items are written as already-resolved facts instead of ambiguous points needing clarification
- Requirement file is named after a meeting date instead of a business topic
- The output includes Goal IDs
- Agent proceeds when `.rco/config.json` is missing without telling the user to run `rco-setup`
- Agent proceeds without input and does not prompt for supported formats
- Conflicting requirements are resolved without user confirmation

## Verification

- [ ] `.rco/config.json` was read
- [ ] If `.rco/config.json` was missing, user was told to run `rco-setup`
- [ ] Output path is `docs/requirements/<business-topic>.md`
- [ ] Requirement is grouped by business topic
- [ ] Existing requirement documents were scanned before creating a new file
- [ ] If a matching document existed, new input was merged into it rather than creating a duplicate
- [ ] Merge added new items without rewriting existing confirmed content unless the input contradicted it
- [ ] Raw input is not committed
- [ ] Interview answers are distilled, not transcribed
- [ ] Unconfirmed questions are not written into Git
- [ ] Situations describe real contexts with who, what problem, and what consequence
- [ ] User Confirmed Needs are only explicitly confirmed by the user
- [ ] User Confirmed Doesn't Need contains only permanently excluded items, no deferred items
- [ ] Pending Confirmation items use plain list format (not checkboxes)
- [ ] Ambiguous or conflicting points are in Pending Confirmation, not hidden in other sections
- [ ] No project status metadata appears in the file
- [ ] User is asked whether to continue with `rco-define-goal` or run `rco-create-pr`
- [ ] When no input was provided, supported formats were listed and interview offered
- [ ] Conflicting requirements were escalated to the user instead of silently resolved
