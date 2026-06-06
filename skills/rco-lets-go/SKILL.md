---
name: rco-lets-go
description: Use when a user mentions ReconcileOps work without specifying which skill to run, or when unsure which RCO skill matches the current situation.
---

# RCO Lets Go

Before doing any work, read `.rco/config.json` unless already read in this session. If the file does not exist, route to `rco-setup`.

## Overview

Route the user's request to the correct RCO skill. Read the user's intent, match it against
the routing table, and invoke exactly one skill. Do not invoke multiple skills at once.

## When to Use

- User asks to do something with ReconcileOps but does not name a specific skill
- User describes a situation and you need to determine which RCO skill applies
- Starting a new RCO conversation and unsure where to begin

## Routing Table

| User intent | Route to |
|---|---|
| Initialize or repair the RCO environment; `.rco/` is missing or incomplete | `rco-setup` |
| Turn messy input (meeting notes, transcripts, Slack, email, feedback) into a requirement document | `rco-distill-req` |
| Create or update a Goal document; mark a Goal as Superseded | `rco-define-goal` |
| Create a GitHub Issue for a Goal file that lacks one | `rco-create-goal-issue` |
| Record a technical decision as an ADR; reconsider a past decision | `rco-create-adr-issue` |
| Consolidate closed ADR Issues into `docs/adr.md` | `rco-create-adr-md` |
| Submit changes as a PR with reviewer assignment | `rco-create-pr` |
| Run a drift inspection across Goals, Issues, PRs, and ADR records | `rco-nightly-inspect` |
| Detect spaghetti code — structure smells, duplication, naming, dead code, error handling, hardcoding, type safety, dependency issues, security, performance | `rco-review-spaghetti` |
| Create a non-Goal, non-ADR GitHub Issue (bug, feature, chore, refactor) | `rco-create-issue` |
| Detect development toil — things people must remember, repeat, manually detect, or bridge between tools | `rco-review-toil` |
| PR review before merge — five-axis code quality (correctness, readability, architecture, security, performance) plus project-specific dimensions from .rco/REVIEW.md | `rco-review-pr` |

## Routing Rules

- If the user's intent matches exactly one row, invoke that skill.
- If the user's intent matches multiple rows, ask the user to clarify which one first. Suggest the one that is earliest in the normal workflow order: setup → distill-req → define-goal → create-goal-issue → create-pr → nightly-inspect. ADR and spaghetti-review skills are independent of this order.
- If the user's intent matches no row, tell the user that no RCO skill covers this and explain what the available skills handle.
- If `.rco/config.json` does not exist, always route to `rco-setup` regardless of the user's intent.
- Do not invoke multiple skills at once. Complete one before suggesting the next.

## Post-Skill Suggestion

After a skill completes, suggest the next skill in the workflow if the output naturally leads to one:

| Completed skill | Suggested next |
|---|---|
| `rco-setup` | `rco-distill-req` (if user has input) or `rco-nightly-inspect` (if existing repo) |
| `rco-distill-req` | `rco-define-goal` |
| `rco-define-goal` | `rco-create-pr` (commit Goal doc), then `rco-create-goal-issue` (after merge) |
| `rco-create-goal-issue` | `rco-create-pr` (if ready to implement) |
| `rco-create-adr-issue` | (none — wait for discussion to close) |
| `rco-create-adr-md` | `rco-create-pr` (commit docs/adr.md) |
| `rco-create-pr` | (none — PR is submitted) |
| `rco-nightly-inspect` | Whatever skill the drift findings point to |
| `rco-review-spaghetti` | Whatever skill the findings point to (e.g., `rco-create-pr` for a fix) |
| `rco-review-toil` | Whatever skill the findings point to (e.g., `rco-setup` for tooling, `rco-create-pr` for config) |
| `rco-review-pr` | `rco-create-pr` (if review findings lead to a fix)

Suggestions are optional. Do not force the user into the next step.

## Red Flags

- Multiple skills invoked at once
- User is routed to a skill when `.rco/config.json` does not exist and `rco-setup` was not run first
- Router guesses instead of asking when intent is ambiguous
- Router suggests a skill that does not match the user's described situation
