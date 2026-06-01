---
name: rco-create-spec
description: Create ReconcileOps spec documents from requirement or Goal files. Use when Codex needs to turn docs/requirements/*.md or docs/goals/G-*.md into code foundation design under docs/specs/<business-area>/<capability-or-flow>.md, using engineering best practices and relevant engineering skills before implementation begins.
---

# RCO Create Spec

Before doing any work, read `.reconcile-ops/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Create a spec document that defines the code foundation design for a business capability or flow.
A spec is not a task list, ticket, implementation log, or project status record. It is the design
bridge between stable requirements or Goals and implementation.

The agent should actively use relevant engineering skills and best-practice judgment to produce
the strongest practical design it can. For example, use API/interface design guidance for public
interfaces, security guidance for authentication or sensitive data, database guidance for data
contracts, and frontend guidance for user-facing flows when those concerns are present.

## When to Use

- Creating `docs/specs/<business-area>/<capability-or-flow>.md` from a requirement file
- Creating `docs/specs/<business-area>/<capability-or-flow>.md` from a Goal file
- Designing baseline code behavior before implementation starts
- Converting verifiable delivery goals into engineering design boundaries
- Capturing interfaces, data contracts, validation, errors, and verification approach

## Core Principles

- Use `.reconcile-ops/examples/spec.md` for structure only.
- Ground every spec in one or more requirement or Goal documents.
- Reference source requirement and Goal files with Markdown relative links.
- Organize specs by business logic area under `docs/specs/`.
- Prefer best-practice engineering advice over merely restating requirements.
- Use relevant engineering skills when the spec touches APIs, security, data, frontend behavior, performance, or architecture.
- Prefer skills such as `api-and-interface-design`, `security-best-practices`, `postgresql-optimization`, `frontend-design`, `performance-optimization`, or `refactor` when their domain applies.
- Do not write project status, owner, milestone, priority, progress, timestamps, raw client input, or unconfirmed questions.
- Do not write implementation tasks; write baseline design.
- All user-facing output must use the `preferred_language` from `.reconcile-ops/config.json`.

## Standard Workflow

1. Read `.reconcile-ops/config.json` unless already read in this session. If it does not exist, stop and tell the user to run `rco-setup` first.
2. Read `.reconcile-ops/examples/spec.md` for structure only.
3. Read the input requirement or Goal file.
4. Follow links between requirement and Goal files when available, so the spec is grounded in both business intent and verifiable delivery goals.
5. Identify the business logic area and capability or flow.
6. Choose the output path:

```txt
docs/specs/<business-area>/<capability-or-flow>.md
```

7. Identify which engineering concerns apply and use relevant engineering skills or best-practice checks before writing the spec.
   - API or module boundary: consider `api-and-interface-design`.
   - Authentication, authorization, or sensitive data: consider `security-best-practices`.
   - Database schema, query, or persistence design: consider `postgresql-optimization` or another database-specific skill.
   - User-facing frontend behavior: consider `frontend-design`.
   - Performance-sensitive behavior: consider `performance-optimization`.
   - Existing code structure or maintainability concerns: consider `refactor`.
8. Write the spec with durable design content:
   - `Source Documents`
   - `Purpose`
   - `Behavior`
   - `Boundaries`
   - `Interfaces`
   - `Data Contracts`
   - `Validation Rules`
   - `Error Handling`
   - `Verification Approach`
9. Omit sections that truly do not apply, but do not omit design concerns merely because they are inconvenient.
10. Stop and report missing confirmations if the source documents are too ambiguous to design safely.
11. Remind the user to run `rco-create-pr` for the spec document changes.

## Implementation Templates

Use this structure:

```md
# Spec: <Business Area Capability>

## Source Documents

- [Goal Title](../../goals/G-000001.md)
- [Requirement Title](../../requirements/<business-topic>.md)

## Purpose

...

## Behavior

- ...

## Boundaries

- ...

## Interfaces

- ...

## Data Contracts

- ...

## Validation Rules

- ...

## Error Handling

- ...

## Verification Approach

- ...
```

Path examples:

```txt
docs/specs/auth/login.md
docs/specs/auth/logout.md
docs/specs/billing/invoice-generation.md
```

## Bundled Resources

- `.reconcile-ops/examples/spec.md`: Example spec using todo login behavior. Reference the structure only.

## Agent Feedback Loop

If the spec would require assumptions not present in requirements, Goals, or established project
patterns, do not write those assumptions as facts. Ask for confirmation in the response or clearly
label the blocker. If an engineering best-practice review reveals a weak design, revise the spec
before presenting it.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "The Goal is enough; no spec is needed." | If implementation design decisions are needed, create a spec before coding. |
| "Just restate the requirement." | A spec must add engineering design: boundaries, interfaces, contracts, validation, errors, and verification. |
| "Skip other engineering skills to save time." | Use relevant engineering skills when they can improve correctness or design quality. |
| "Put TODOs or open questions in the spec." | Do not write unconfirmed questions into Git. Report blockers in the response. |
| "Use a flat spec file name." | Specs live under business logic folders such as `docs/specs/auth/login.md`. |

## Red Flags

- Spec contains status, owner, milestone, priority, progress, created time, or updated time
- Spec contains raw client input or unconfirmed questions
- Spec does not link to source requirement or Goal documents
- Spec is a task checklist instead of a design document
- Spec ignores obvious security, API, data, validation, or error-handling concerns
- Spec path is not under `docs/specs/<business-area>/`
- Agent proceeds when `.reconcile-ops/config.json` is missing without telling the user to run `rco-setup`

## Verification

- [ ] `.reconcile-ops/config.json` was read
- [ ] If `.reconcile-ops/config.json` was missing, user was told to run `rco-setup`
- [ ] `.reconcile-ops/examples/spec.md` was used only as a structure reference
- [ ] Output path is `docs/specs/<business-area>/<capability-or-flow>.md`
- [ ] Source requirement or Goal files are linked with Markdown relative links
- [ ] Relevant engineering skills or best-practice checks were considered
- [ ] Spec describes baseline design, not tasks or status
- [ ] Spec includes applicable behavior, boundaries, interfaces, data contracts, validation, errors, and verification
- [ ] Spec contains no project status metadata
- [ ] Spec contains no raw client input or unconfirmed questions
- [ ] User is reminded to run `rco-create-pr`
