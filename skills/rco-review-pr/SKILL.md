---
name: rco-review-pr
description: Use when a PR needs multi-axis code review before merge — covers correctness, readability, architecture, security, and performance plus any project-specific review dimensions defined in .rco/REVIEW.md. Designed for GitHub Actions PR triggers and manual invocation.
---

# RCO Review PR

Before doing any work, read `.rco/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Multi-dimensional PR review with built-in five axes plus project-specific custom dimensions
from `.rco/REVIEW.md`. Every PR gets reviewed before merge. Review is read-only — report
findings, never modify code or PR check status.

**Approval standard:** Approve when the change definitely improves overall code health, even
if it isn't perfect. Don't block because it isn't exactly how you would have written it. If
it improves the codebase and follows project conventions, approve.

## When to Use

- PR opened or updated (GitHub Actions)
- `/review` keyword in PR comment (GitHub Actions)
- Manual request to review a PR before merge

### When NOT to Use

- Spaghetti code deep scan → use `rco-review-spaghetti`
- Development efficiency / toil → use `rco-review-toil`
- Drift alignment inspection → use `rco-nightly-inspect`
- Reviewing uncommitted changes or a full repository → use `rco-review-spaghetti`

## Core Principles

- **Review is read-only.** Post comments; do not modify code, files, or PR check status.
- **All five built-in axes are always checked.** Do not skip any axis.
- **Custom dimensions from `.rco/REVIEW.md` are always checked if the file exists.**
- **Every finding is labeled with severity.** Required changes have no prefix. Optional changes are labeled.
- **PR scope only.** Review the diff, not the entire repository.

## Built-in Axes

### 1. Correctness

Does the code do what it claims?

- Matches spec or task requirements
- Edge cases handled (null, empty, boundary values)
- Error paths handled (not just the happy path)
- Tests cover the change adequately and test behavior not implementation details
- No off-by-one errors, race conditions, or state inconsistencies

### 2. Readability & Simplicity

Can another engineer understand this without the author explaining it?

- Names descriptive and consistent with project conventions (no `temp`, `data`, `result` without context)
- Control flow straightforward (avoid nested ternaries, deep callbacks)
- Code organized logically (related code grouped, clear module boundaries)
- No "clever" tricks that should be simplified
- Could this be done in fewer lines? (1000 lines where 100 suffice is a failure)
- Are abstractions earning their complexity? (Don't generalize until the third use case)
- Dead code artifacts: no-op variables, backwards-compat shims, `// removed` comments

### 3. Architecture

Does the change fit the system's design?

- Follows existing patterns or introduces a new one with justification
- Maintains clean module boundaries
- No unnecessary code duplication that should be shared
- Dependencies flowing in the right direction (no circular dependencies)
- Abstraction level appropriate (not over-engineered, not too coupled)

### 4. Security

Does the change introduce vulnerabilities?

- User input validated and sanitized at boundaries
- Secrets kept out of code, logs, and version control
- Authentication/authorization checked where needed
- SQL queries parameterized (no string concatenation)
- Outputs encoded to prevent XSS
- Dependencies from trusted sources with no known vulnerabilities
- External data treated as untrusted before use in logic or rendering

### 5. Performance

Does the change introduce performance problems?

- No N+1 query patterns
- No unbounded loops or unconstrained data fetching
- No synchronous operations that should be async
- No unnecessary re-renders in UI components
- Pagination on list endpoints
- No large objects created in hot paths

## Custom Dimensions (.rco/REVIEW.md)

If `.rco/REVIEW.md` exists, read it and add its dimensions to the review. The file defines
project-specific review axes that go beyond the five built-in axes.

**File format:**

```md
# Project Review Dimensions

## D6: API Contract Compliance

- All API endpoints must have OpenAPI schema
- Response shapes must match the schema in docs/api.yaml
- No new endpoints without schema updates

## D7: Database Migration Safety

- No raw ALTER TABLE without down migration
- New columns must have defaults or be nullable
- Index additions must include CONCURRENTLY

## D8: Error Code Consistency

- All error responses must use the standard error envelope
- Error codes must be registered in docs/error-codes.md
- No ad-hoc error shapes
```

**Rules:**
- Dimension IDs continue from D5 (built-in axes are D1–D5). Start custom dimensions at D6.
- Each dimension has a title and bullet points defining what to check.
- If `.rco/REVIEW.md` does not exist, skip custom dimensions. Do not warn about its absence.
- If `.rco/REVIEW.md` exists but is empty or has no dimension sections, skip custom dimensions.
- Custom dimensions are checked with the same rigor as built-in axes.

## Severity Classification

Label every finding so the author knows what is required vs optional:

| Label | Meaning | Author Action |
|-------|---------|---------------|
| **Critical:** | Blocks merge — security vulnerability, data loss, broken functionality | Must address before merge |
| *(no prefix)* | Required change | Must address before merge |
| **Nit:** | Minor, optional | Author may ignore |
| **Optional:** / **Consider:** | Suggestion | Worth considering but not required |
| **FYI** | Informational only | No action needed |

## Review Process

### Step 1: Understand the Context

Before looking at code, understand the intent:

- What is this change trying to accomplish?
- What spec or task does it implement?
- What is the expected behavior change?

### Step 2: Review the Tests First

Tests reveal intent and coverage:

- Do tests exist for the change?
- Do they test behavior (not implementation details)?
- Are edge cases covered?
- Would the tests catch a regression if the code changed?

### Step 3: Review the Implementation

Walk through the diff with all axes in mind. For each file changed:

1. Correctness: Does this code do what the test says it should?
2. Readability: Can I understand this without help?
3. Architecture: Does this fit the system?
4. Security: Any vulnerabilities?
5. Performance: Any bottlenecks?
6. (D6, D7, ...): Custom dimensions from `.rco/REVIEW.md`

### Step 4: Categorize Findings

Label every finding with its severity (see Classification table above).

### Step 5: Check Change Size

Small, focused changes are easier to review and safer to deploy:

| Size | Lines Changed | Verdict |
|------|---------------|---------|
| Good | ~100 | Reviewable in one sitting |
| Acceptable | ~300 | If it's a single logical change |
| Too large | ~1000+ | Ask the author to split |

When a change is too large, suggest splitting:

| Strategy | When |
|----------|------|
| Stack | Sequential dependencies |
| By file group | Cross-cutting concerns needing different reviewers |
| Horizontal | Layered architecture — shared code/stubs first |
| Vertical | Feature work — smaller full-stack slices |

**Separate refactoring from feature work.** A change that refactors existing code and adds new behavior is two changes.

### Step 6: Produce Output

Post a summary comment and inline review comments on the PR.

**Summary comment:**

```md
## PR Review: 🔴 X Critical | Y Required | Z Nit | W Optional

### 🔴 Critical

| # | Axis | File | Line | Issue |
|---|------|------|------|-------|
| 1 | D4 Security | `src/auth.ts` | 42 | SQL string concatenation — injection risk. Use parameterized queries. |

### Required

| # | Axis | File | Line | Issue |
|---|------|------|------|-------|
| 1 | D1 Correctness | `src/api.ts` | 15 | Null check missing before accessing `user.id`. |

### Nit / Optional / FYI

- D2 Readability: `src/utils.ts:33` — Variable `tmp2` could be more descriptive. *(Nit)*
- D5 Performance: `src/orders.ts:88` — Consider batching the queries. *(Optional)*

### Custom Dimensions (from .rco/REVIEW.md)

| # | Axis | File | Line | Issue |
|---|------|------|------|-------|
| 1 | D6 API Contract | `src/routes.ts` | 12 | New endpoint missing OpenAPI schema. *(Required)* |

**Verdict:** Request changes — X Critical + Y Required issues must be addressed.
```

**Inline review comments** — for Critical and Required findings only. Nit/Optional/FYI appear only in summary.

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --method POST \
  --field path="<file-path>" \
  --field line=<line-number> \
  --field side="RIGHT" \
  --field body="<severity-label> **<Axis>**: <issue>. <suggestion>."
```

If inline comment posting fails, include the finding in the summary with file and line info.

**Do not modify PR check status.**

**Verdict line:**
- No Critical or Required issues → "Approve — ready to merge."
- Any Critical or Required issues → "Request changes — N issues must be addressed."

## Change Descriptions (Meta-Review)

If the PR description is missing or inadequate, flag it. Every change needs a description that stands alone in version control history:

- **First line:** Short, imperative, standalone. "Delete the FizzBuzz RPC" not "Deleting the FizzBuzz RPC."
- **Body:** What is changing and why. Include context, decisions, and reasoning not visible in the code itself.
- **Anti-patterns:** "Fix bug", "Fix build", "Add patch", "Moving code from A to B", "Phase 1".

## Honesty in Review

- **Don't rubber-stamp.** "LGTM" without evidence of review helps no one.
- **Don't soften real issues.** "This might be a minor concern" when it's a bug that will hit production is dishonest.
- **Quantify problems when possible.** "This N+1 query will add ~50ms per item" is better than "this could be slow."
- **Push back on approaches with clear problems.** Sycophancy is a failure mode.
- **Accept override gracefully.** If the author has full context and disagrees, defer to their judgment.

## Dependency Discipline

Before adding any dependency:

1. Does the existing stack solve this?
2. How large is the dependency? (Check bundle impact.)
3. Is it actively maintained?
4. Does it have known vulnerabilities? (`npm audit`, `pip audit`)
5. What's the license?

Prefer standard library and existing utilities over new dependencies. Every dependency is a liability.

## Implementation Templates

```bash
# Get PR diff
gh pr diff <number>

# Read custom review dimensions
cat .rco/REVIEW.md 2>/dev/null

# Post PR summary comment
gh pr comment <number> --body-file <summary-file>

# Post inline review comment
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --method POST \
  --field path="<path>" \
  --field line=<line> \
  --field side="RIGHT" \
  --field body="<body>"

# Discover repo owner/name
gh repo view --json nameWithOwner -q .nameWithOwner
```

## Agent Feedback Loop

If the diff is empty, report "No changes to review" and stop.
If `.rco/REVIEW.md` exists but has malformed dimension sections, parse what is possible and skip the rest.
If `gh` commands fail due to permissions, report the error and suggest the user check GitHub token scope.
If inline comment posting fails, fall back to including the finding in the summary.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "It works, that's good enough" | Working code that's unreadable, insecure, or architecturally wrong creates debt that compounds. Report it. |
| "The tests pass, so it's good" | Tests are necessary but not sufficient. They don't catch architecture problems, security issues, or readability concerns. |
| "We'll clean it up later" | Later never comes. The review is the quality gate. Require cleanup before merge, not after. |
| "AI-generated code is probably fine" | AI code needs more scrutiny, not less. It's confident and plausible, even when wrong. |
| "This axis probably has no findings" | Check all axes every time. Output "No findings." for empty axes. Assumptions are the source of missed issues. |
| "The PR is small, skip review" | All PRs get reviewed regardless of size. Small PRs can contain critical issues. |
| "Skip custom dimensions, they're optional" | If `.rco/REVIEW.md` exists, its dimensions are mandatory. They represent project-specific quality gates. |
| "I'll fix the code directly" | Review is read-only. Report findings only. |
| "This is just style, no need to flag" | If it violates project conventions from REVIEW.md, flag it. If it's personal preference, label it Nit. |
| "Downgrade this Critical because it's internal-only" | Severity criteria are fixed. Internal code with SQL injection is still Critical. |

## Red Flags

- An axis is missing from the output (even as "No findings.")
- Findings suppressed because "it's probably fine" or "the team handles it"
- Review modifies code, files, or PR check status
- Critical or Required findings are not followed up in the verdict line
- No severity label on a finding
- Inline comments posted for Nit/Optional/FYI findings
- Custom dimensions from `.rco/REVIEW.md` are skipped
- REVIEW.md dimensions are treated as suggestions rather than mandatory checks
- PR description is missing and not flagged
- Change size is over 1000 lines and not flagged for splitting
- Verdict line contradicts the findings (Critical exists but verdict says Approve)
- Agent proceeds when `.rco/config.json` is missing without telling the user to run `rco-setup`

## Verification

- [ ] `.rco/config.json` was read
- [ ] If `.rco/config.json` was missing, user was told to run `rco-setup`
- [ ] All five built-in axes appear in the output (even if "No findings.")
- [ ] If `.rco/REVIEW.md` exists, all custom dimensions appear in the output
- [ ] If `.rco/REVIEW.md` does not exist, no warning about its absence
- [ ] Each finding has a severity label
- [ ] Critical and Required findings have inline review comments
- [ ] Nit/Optional/FYI findings appear only in summary
- [ ] Summary includes the severity count header and verdict line
- [ ] No code, files, or PR check status were modified
- [ ] Change size was assessed and flagged if too large
- [ ] PR description was assessed and flagged if missing or inadequate
