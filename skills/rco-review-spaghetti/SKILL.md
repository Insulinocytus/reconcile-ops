---
name: rco-review-spaghetti
description: Use when code has structure smells, duplication, bad naming, dead code, swallowed errors, hardcoded secrets, type unsafety, stale dependencies, security vulnerabilities, or performance hazards. Works on PRs, diffs, uncommitted changes, or full repository scans.
---

# RCO Review Spaghetti

Before doing any work, read `.rco/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Detect code quality problems across ten dimensions, classify severity, and report
findings through the channel matching the trigger mode. Review is read-only — report
findings, never modify code.

## When to Use

- Manual request to review code quality
- PR opened or updated (GitHub Actions)
- `/review` keyword in PR or Issue comment (GitHub Actions)
- Nightly full-repository scan running alongside `rco-nightly-inspect`

## Core Principles

- **Review is read-only.** Create reports and comments; do not modify code, files, or PR check status.
- **All ten dimensions are always checked.** Do not skip any dimension. Adapt detection criteria to the language, but never skip.
- **Severity is based on production consequence, not personal judgment:**
  - 🔴 **Critical** — will cause irreversible damage in production
  - 🟡 **Warning** — clearly bad code but not dangerous
  - 🟢 **Suggestion** — not elegant enough, minor improvement
- **Every finding must include:** file path, line number or range, what is wrong, why it matters, how to fix it.
- **Nightly scan creates an Issue with title `[Code Review] YYYY-MM-DD`, no label.**

## Standard Workflow

1. Read `.rco/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

2. Determine trigger mode and scope:

| Trigger | How to identify | Scope |
|---------|-----------------|-------|
| Manual, no input | User provided nothing | Ask: review a PR number / a diff / uncommitted changes / a specific directory? |
| Manual, PR number | User gave a PR number | PR diff |
| Manual, diff | User provided diff text | Provided diff |
| Manual, uncommitted | User asked for uncommitted | `git diff` + `git diff --cached` |
| Manual, directory | User gave a path | All source files under that path |
| PR Actions | PR event payload | PR diff |
| Comment `/review` on PR | Keyword in PR comment | PR diff |
| Comment `/review` on Issue | Keyword in Issue comment | All source files in repository |
| Nightly scan | Scheduled or manual full scan | All source files in repository |

3. Collect the code to review:

```bash
# PR diff
gh pr diff <number>

# Uncommitted changes
git diff
git diff --cached

# Full repository source files
find . -type f \( -name '*.ts' -o -name '*.js' -o -name '*.py' -o -name '*.go' -o -name '*.rs' -o -name '*.java' -o -name '*.rb' \) \
  ! -path '*/node_modules/*' ! -path '*/vendor/*' ! -path '*/.git/*' ! -path '*/dist/*' ! -path '*/build/*'
```

4. Run all ten detection dimensions against the collected code. Every dimension must produce findings or explicitly state "No findings." Never omit a dimension from the output.

### D1: Structure Smells

- Functions exceeding 80 lines
- Nesting depth exceeding 4 levels
- Files exceeding 500 lines
- Modules/classes with more than 10 public methods
- Obvious circular or tight coupling between modules

### D2: Duplication

- Blocks of 6+ identical or nearly-identical lines across files
- Copy-paste with minor variable name changes
- Repeated error handling patterns that should be centralized

### D3: Naming Quality

- Single-letter or meaningless names (`a`, `b`, `tmp`, `data`, `result`, `obj`)
- Mixed language naming (Chinese + English in identifiers)
- Names that contradict behavior (`getX` that modifies state, `isY` that returns string)
- Overly abbreviated names that lose meaning

### D4: Dead Code

- Unreachable code after return/throw/break
- Functions, variables, or imports with zero references
- Large blocks of commented-out code (5+ lines)
- Unused files not referenced by any other file or config

### D5: Error Handling

- Empty catch blocks (swallowed exceptions)
- Bare panic / throw without context
- Error paths that return None/null silently instead of propagating
- Missing error handling on IO, network, or database operations

### D6: Hardcoding

- Magic numbers without named constants (except 0, 1, -1, and well-known math constants)
- Hardcoded URLs, IP addresses, file paths
- Hardcoded secrets, API keys, tokens, passwords — **always 🔴 Critical**
- Hardcoded environment-specific values (port numbers, hostnames)

### D7: Type Safety

- `any` type usage in TypeScript (each instance is a finding)
- Unsafe type assertions without guards (`as` without check)
- Runtime type bypass (stringly-typed enums, JSON.parse without validation)
- Implicit any / missing return types on exported functions
- For untyped languages: missing input validation, duck-typing without guards

### D8: Dependency Smells

- Circular imports between modules
- Unused imports
- Imports of deprecated or known-vulnerable packages
- Importing entire libraries when only specific functions are needed

### D9: Security

- SQL string concatenation or interpolation — **always 🔴 Critical**
- Unvalidated user input flowing into commands, queries, or HTML
- Sensitive data in logs (passwords, tokens, PII) — **always 🔴 Critical**
- Missing authentication or authorization checks on endpoints
- Insecure deserialization

### D10: Performance

- N+1 query patterns (query inside loop)
- Synchronous IO inside loops
- Unnecessary large object copies or deep clones
- Missing pagination on list endpoints
- Unindexed database queries in hot paths

5. Classify each finding by severity. **Do not downgrade a finding because "it's probably fine" or "context makes it acceptable."** The classification criteria are fixed:

| Severity | Criteria | Examples |
|----------|----------|---------|
| 🔴 Critical | Will cause irreversible production damage | SQL injection, hardcoded secrets, swallowed exceptions that corrupt data, sensitive data in logs, unvalidated input into commands |
| 🟡 Warning | Clearly bad, not dangerous | God function, deep nesting, duplication, N+1, dead code, bare panic, `any` abuse, unused imports, circular deps, magic numbers, synchronous IO in loops |
| 🟢 Suggestion | Not elegant, minor improvement | Poor naming, minor type unsafety, missing return types, overly broad imports, unused files |

6. Produce output based on trigger mode.

### PR Trigger Output

Post a summary comment on the PR and inline review comments for 🔴 and 🟡 findings.

Summary comment:

```md
## Code Review: 🔴 X Critical | 🟡 Y Warning | 🟢 Z Suggestion

### 🔴 Critical

| # | Dimension | File | Line | Issue |
|---|-----------|------|------|-------|
| 1 | D9 Security | `src/auth/login.ts` | 42 | SQL string concatenation — injection risk. Use parameterized queries. |
| 2 | D6 Hardcoding | `src/config.ts` | 8 | Hardcoded API key. Move to environment variable. |

### 🟡 Warning

| # | Dimension | File | Line | Issue |
|---|-----------|------|------|-------|
| 1 | D1 Structure | `src/api/users.ts` | 15-120 | Function `handleUsers` is 105 lines. Break into focused functions. |

### 🟢 Suggestion

| # | Dimension | File | Line | Issue |
|---|-----------|------|------|-------|
| 1 | D3 Naming | `src/utils.ts` | 33 | Variable `tmp2` is meaningless. Use a descriptive name. |
```

Inline review comments for 🔴 and 🟡 only (🟢 appears only in summary):

```bash
gh api repos/{owner}/{repo}/pulls/{pr-number}/comments \
  --method POST \
  --field path="<file-path>" \
  --field line=<line-number> \
  --field side="RIGHT" \
  --field body="🔴 **D9 Security**: SQL string concatenation — use parameterized queries.

\`\`\`ts
await db.query('SELECT * FROM users WHERE id = $1', [userId])
\`\`\`"
```

If inline comment posting fails (line position mismatch), include the finding in the summary comment with file and line info.

**Do not modify PR check status.**

### Nightly Scan Output

Create a GitHub Issue with no label:

```bash
gh issue create \
  --title "[Code Review] $(date +%Y-%m-%d)" \
  --body-file <report-file>
```

Issue body:

```md
# Code Review Report — YYYY-MM-DD

## 🔴 Critical: X

### D6: Hardcoding

- `src/config.ts:8` — Hardcoded API key. Move to environment variable.

### D9: Security

- `src/auth/login.ts:42` — SQL string concatenation. Use parameterized queries.

## 🟡 Warning: Y

### D1: Structure Smells

- `src/api/users.ts:15-120` — Function `handleUsers` is 105 lines. Break into focused functions.

### D4: Dead Code

- `src/legacy.ts:200-250` — 50 lines of commented-out code. Remove or extract.

(Continue for all dimensions with findings)

### D2: Duplication

No findings.

### D3: Naming Quality

No findings.

(all ten dimensions must appear, even if "No findings.")

## 🟢 Suggestion: Z

### D3: Naming Quality

- `src/utils.ts:33` — Variable `tmp2` is meaningless. Use a descriptive name.

---

**Total: 🔴 X | 🟡 Y | 🟢 Z**
```

### Manual Trigger Output

Print the same markdown report directly in the conversation.

7. Report total finding counts. If 🔴 count > 0, explicitly state: "This code has Critical issues that should be resolved before merging."

## Implementation Templates

```bash
# Get PR diff
gh pr diff <number>

# Post PR summary comment
gh pr comment <number> --body-file <summary-file>

# Post inline review comment
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --method POST \
  --field path="<path>" \
  --field line=<line> \
  --field side="RIGHT" \
  --field body="<comment-body>"

# Create nightly Issue
gh issue create --title "[Code Review] $(date +%Y-%m-%d)" --body-file <report-file>

# Discover repo owner/name
gh repo view --json nameWithOwner -q .nameWithOwner

# Scan source files
find . -type f \( -name '*.ts' -o -name '*.js' -o -name '*.py' -o -name '*.go' -o -name '*.rs' -o -name '*.java' -o -name '*.rb' \) \
  ! -path '*/node_modules/*' ! -path '*/vendor/*' ! -path '*/.git/*' ! -path '*/dist/*' ! -path '*/build/*'

# Uncommitted changes
git diff
git diff --cached
```

## Agent Feedback Loop

If the code to review is empty (empty diff, no source files found), report "No code to review" and stop.
If `gh` commands fail due to permissions, report the error and suggest the user check GitHub token scope.
If inline comment posting fails, fall back to including the finding in the summary comment with file and line info.
If the user requests a specific dimension only, still run all ten but highlight the requested dimension in the output.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "This dimension probably has no findings." | Run all ten dimensions every time. Output "No findings." for empty dimensions. Assumptions are the source of missed issues. |
| "The function is long but acceptable in context." | Any function over 80 lines is a finding. Report it. The author decides acceptability. |
| "This naming is fine in context." | Report the finding. The severity level communicates priority. |
| "It's just a suggestion, skip it." | Report all findings at their correct severity. |
| "I'll fix the code directly." | Review is read-only. Report findings only. |
| "Only check the changed lines." | PR scope reviews the diff. Nightly/manual scope reviews full files. Do not mix scopes. |
| "The PR is small, skip review." | All PRs get reviewed regardless of size. Small PRs can contain critical issues. |
| "This language doesn't have type safety issues." | Adapt detection criteria to the language. Python → duck-typing safety and missing type hints. Go → empty interface{} usage. Never skip a dimension entirely. |
| "Downgrade this Critical because it's internal-only." | Classification criteria are fixed. Internal code with SQL injection is still Critical. |
| "Skip unused imports, the bundler handles it." | Unused imports are dead code. Report them. |
| "The hardcoded IP is just for testing." | Hardcoded secrets are always Critical. Other hardcoded values are Warning. Report them. |

## Red Flags

- A dimension is missing from the output entirely (even as "No findings.")
- Findings are suppressed because "it's probably fine"
- Review modifies code, files, or PR check status
- Nightly Issue has a label applied
- Nightly Issue title does not follow `[Code Review] YYYY-MM-DD` format
- Finding is missing file path, line number, or fix suggestion
- Critical findings are downgraded without the criteria matching
- Agent proceeds when `.rco/config.json` is missing without telling the user to run `rco-setup`
- Summary comment is missing the severity count header
- Manual trigger with no input proceeds without asking the user what to review
- Inline comments are posted for 🟢 Suggestion findings
- Only changed lines are reviewed when scope is nightly or manual-directory
- Severity classification contradicts the criteria table
- A dimension is skipped because "this language doesn't have that problem"

## Verification

- [ ] `.rco/config.json` was read
- [ ] If `.rco/config.json` was missing, user was told to run `rco-setup`
- [ ] Trigger mode and scope were determined correctly
- [ ] If manual with no input, user was asked what to review
- [ ] All ten dimensions appear in the output (even if "No findings.")
- [ ] Each finding includes file path, line/range, what is wrong, and fix suggestion
- [ ] Severity follows the classification criteria (no downgrades without criteria match)
- [ ] PR output: summary comment + inline for 🔴🟡 only, no check status change
- [ ] Nightly output: Issue with `[Code Review] YYYY-MM-DD` title, no label
- [ ] Manual output: markdown report in conversation
- [ ] No code or files were modified during review
- [ ] Total finding counts were reported
- [ ] If 🔴 > 0, the Critical warning was stated
