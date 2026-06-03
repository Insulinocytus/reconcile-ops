---
name: rco-create-adr-md
description: Use when ADR Issues have been closed and their conclusions need to be consolidated into docs/adr.md, or when the consolidated file is out of date with recent ADR decisions.
---

# RCO Create ADR Markdown

Before doing any work, read `.rco/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Scan all ADR Issues, extract the final conclusion from each, and write a consolidated
`docs/adr.md` file. This file is the current effective state of all architectural decisions.
Individual ADR Issues are the discussion and decision process; this file is the result.

## When to Use

- Closed ADR Issues need their conclusions consolidated
- `docs/adr.md` is missing or out of date
- After closing or superseding an ADR Issue

## Core Principles

- Only extract from ADR Issues that are closed. Open issues mean the decision is not yet final.
- Each ADR entry in the file includes: ID, title, conclusion from Consequences section, and a link back to the Issue.
- Superseded ADRs are kept in the file but marked as superseded, with a link to the replacing ADR.
- The file is the single source of truth for what decisions are currently effective.
- This skill writes to Git, so the output should go through `rco-create-pr`.

## Standard Workflow

1. Read `.rco/config.json` unless already read in this session. If it does not exist, stop and tell the user to run `rco-setup` first.
2. Collect all ADR Issues, both open and closed:

```bash
gh issue list --label adr --state all --json number,title,state,body --jq '.[] | select(.title | test("ADR-")) | {number, title, state, body}'
```

3. For each closed ADR Issue, extract:
   - ADR ID and title from the Issue title
   - Consequences section content from the Issue body
   - Whether it has a Supersedes link (meaning it replaced an older ADR)
   - Whether it is itself superseded (a newer closed ADR references it in its Supersedes section)
4. For each open ADR Issue, note it as pending but do not include it in the file.
5. Write `docs/adr.md` with this structure:

```md
# Architecture Decision Records

## ADR-0001: <title>

**Status:** Active | Superseded by [ADR-0002](#adr-0002-title)
**Issue:** #[number](issue-url)

- <consequence 1>
- <consequence 2>

---

## ADR-0002: <title>

**Status:** Active
**Issue:** #[number](issue-url)

- <consequence 1>
- <consequence 2>

---

## Pending

- [ADR-0003] <title> (Issue #[number] — open)
```

6. Verify the file contains no content from open issues in the active section.
7. Remind the user to run `rco-create-pr` for the `docs/adr.md` changes.

## Implementation Templates

File structure:

```md
# Architecture Decision Records

## ADR-0001: Use PostgreSQL for Session Storage

**Status:** Superseded by [ADR-0002: Migrate Session Storage to Redis Cluster](#adr-0002-migrate-session-storage-to-redis-cluster)
**Issue:** [#12](https://github.com/OWNER/REPO/issues/12)

- All session data moved from Redis to PostgreSQL
- Redis dependency removed from the auth service

---

## ADR-0002: Migrate Session Storage to Redis Cluster

**Status:** Active
**Issue:** [#34](https://github.com/OWNER/REPO/issues/34)

- Session storage migrated from PostgreSQL to Redis Cluster
- PostgreSQL session table removed after migration

---

## Pending

- [ADR-0003] Choose API gateway vendor (Issue #40 — open)
```

Useful commands:

```bash
gh issue list --label adr --state all --json number,title,state,body
```

## Agent Feedback Loop

If no ADR Issues exist, do not create `docs/adr.md`. Report that there are no ADRs to
consolidate. If all ADR Issues are open, report that no decisions are final yet and suggest
re-running after decisions are closed.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "Include open ADRs in the active section." | Only closed ADRs are final. Open ADRs go in the Pending section. |
| "Delete superseded ADRs from the file." | Keep them for traceability. Mark them as Superseded with a link to the replacement. |
| "This is just a summary, so skip the PR." | The file goes into Git. Run `rco-create-pr`. |
| "Copy the full Context and Decision sections." | Only extract Consequences. The Issue link provides full detail. |

## Red Flags

- File includes content from open ADR Issues in the active section
- Superseded ADRs are removed instead of marked
- ADR entries are missing the Issue link
- File contains full Context and Decision sections instead of Conclusions only
- No Pending section when open ADR Issues exist
- Agent proceeds when `.rco/config.json` is missing without telling the user to run `rco-setup`

## Verification

- [ ] `.rco/config.json` was read
- [ ] If `.rco/config.json` was missing, user was told to run `rco-setup`
- [ ] All ADR Issues were collected (open and closed)
- [ ] Only closed ADRs appear in the active/superseded sections
- [ ] Open ADRs appear in the Pending section only
- [ ] Each entry includes ADR ID, title, status, Issue link, and Consequences
- [ ] Superseded ADRs are marked with a link to the replacement
- [ ] No full Context or Decision sections are copied into the file
- [ ] User is reminded to run `rco-create-pr`
