---
name: rco-review-toil
description: Use when human time is being wasted on things that should not require human attention — manual steps, memorized conventions, unenforced rules, disconnected tools, problems caught only by human eyes. Not for PR review or code quality.
---

# RCO Review Toil

Before doing any work, read `.rco/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## Overview

Find where human time is wasted on things that should not require human attention.
Review the project for toil — tasks that are manual, repetitive, or require memorization
when they could be automated, scripted, skill-ified, or CI-ified. Review is read-only.

## When to Use

- Manual request to review development efficiency
- Nightly full-repository scan running alongside `rco-nightly-inspect` and `rco-review-spaghetti`

Not for PR review. This skill reviews project-level patterns, not code-level quality.

### When NOT to Use

- PR code quality review → use `rco-review-spaghetti`
- Drift alignment inspection → use `rco-nightly-inspect`
- Reviewing a specific diff → not this skill's scope

## Core Principles

- **Review is read-only.** Report findings only. Do not modify files or create scripts.
- **All four dimensions are always checked.** Do not skip any dimension. Output "No findings." for empty dimensions.
- **No severity classification.** All findings are equal. The reader decides priority.
- **Every finding must include:** what is wrong, where it manifests, what it could become (automation type: script / skill / CI / config default / tooling).
- **Focus on the project root and near-root.** CI configs, README, Makefile, package scripts, skill definitions, onboarding docs — these are where toil lives. Deep source code is not the primary scope.
- **Nightly scan creates an Issue with title `[Toil Review] YYYY-MM-DD`, no label.**

## Standard Workflow

1. Read `.rco/config.json` unless already read in this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

2. Determine trigger mode and scope:

| Trigger | How to identify | Scope |
|---------|-----------------|-------|
| Manual, no input | User provided nothing | Ask: review the whole project / a specific area (onboarding, CI, release process, etc.)? |
| Manual, area specified | User gave a focus area | That area and its related files |
| Nightly scan | Scheduled or manual full scan | Whole project, root and near-root |

3. Scan the project structure using the commands in Implementation Templates. Focus on root and near-root files.

4. Run all four detection dimensions. Every dimension must produce findings or explicitly state "No findings." Never omit a dimension.

### D1: People Have to Remember and Read

- Implicit conventions not written down or not written as code (branch naming, commit message format, PR body structure — if these exist as rules, they should be enforced by tooling, not README)
- Operational guides written as README prose that could be a script or skill (deployment steps, release checklist, environment setup instructions)
- Configuration with no defaults that requires every developer to set up manually
- Onboarding that requires reading multiple docs instead of running one command
- Decision records or process rules that exist only in people's heads or chat history

### D2: People Have to Do Repeatedly

- Manual version bumping during release
- Manual deployment steps that could be a pipeline
- Manual PR body writing that could be generated (structure, reviewer assignment, goal linking)
- Manual issue creation that could be skill-triggered
- Manual documentation updates that should follow code changes automatically
- Information scattered across systems that requires human bridging (Goal in Git + status in GitHub + discussion in Slack — if the sync is manual, it's toil)
- Manual changelog generation
- Manual dependency updating

### D3: Problems Require Human Eyes to Detect

- No linter / formatter — code style relies on reviewer attention
- No commit message linting — conventional commits rely on discipline not enforcement
- No CI pipeline — problems surface after merge, not before
- No automated testing in CI — test execution relies on developers running locally
- No scheduled inspection — drift, stale issues, and misalignment accumulate silently
- No dependency vulnerability scanning
- No automated release validation (smoke tests, health checks post-deploy)

### D4: Toolchain Gaps

- Local scripts that have no CI counterpart (works on my machine syndrome)
- Development environment not reproducible (no Dockerfile, no nix flake, no mise config, no lockfile)
- Tools that exist but are not connected — each requires manual handoff (lint passes locally but CI doesn't run it; skill exists but Actions don't invoke it)
- Missing tools that would eliminate whole categories of toil (commit hooks, auto-formatter, dependency bot, release automation)
- Config duplication across environments that should share a source of truth

5. Produce output based on trigger mode.

### Nightly Scan Output

Create a GitHub Issue with no label:

```bash
gh issue create \
  --title "[Toil Review] $(date +%Y-%m-%d)" \
  --body-file <report-file>
```

Issue body:

```md
# Toil Review Report — YYYY-MM-DD

## D1: People Have to Remember and Read

- Deployment steps are a 12-item README checklist under `docs/deploy.md`. Could become a GitHub Actions workflow or a skill.
- Branch prefix convention exists only in `.rco/config.json` but is not enforced by git hook or CI. Developers must remember the rule.
- Onboarding requires reading 4 separate README files. Could become a single `setup` command or skill.

(If no findings: "No findings.")

## D2: People Have to Do Repeatedly

- PR body is written manually every time. `rco-create-pr` skill exists but is not wired into a git hook or alias.
- Changelog is updated manually before each release. Could be auto-generated from conventional commits.
- Goal Issue creation after merge is manual. Could be triggered by PR close event.

(If no findings: "No findings.")

## D3: Problems Require Human Eyes to Detect

- No linter is configured. Code style is enforced only through PR review.
- No nightly inspection is scheduled. `rco-nightly-inspect` skill exists but no Actions workflow runs it.
- No dependency vulnerability scanning.

(If no findings: "No findings.")

## D4: Toolchain Gaps

- `mise` is used locally for tool management but CI hardcodes tool versions. Dev/CI environment drift risk.
- No `.editorconfig` or formatting automation. Style consistency relies on convention.
- Commit hooks are not configured. Pre-commit checks rely on developer discipline.

(If no findings: "No findings.")

---

**Total findings: X**
```

### Manual Trigger Output

Print the same markdown report directly in the conversation.

6. Report total finding count.

## Implementation Templates

```bash
# Scan root-level files (CI, config, scripts, docs)
ls -la *.md *.yml *.yaml *.json Makefile Dockerfile docker-compose* .env* 2>/dev/null

# GitHub Actions
ls -la .github/workflows/ && cat .github/workflows/*.yml

# Package scripts and tooling
cat package.json 2>/dev/null | jq '.scripts'
cat Makefile 2>/dev/null
cat pyproject.toml 2>/dev/null
cat Cargo.toml 2>/dev/null

# README and docs near root
find . -maxdepth 2 -name '*.md' -not -path '*/node_modules/*' -not -path '*/.git/*'

# Skill definitions
find . -name 'SKILL.md' -not -path '*/.git/*'
find . -path '*/.agents/skills/*' -o -path '*/.claude/skills/*'

# Lint / format / commit hook config
ls -la .eslintrc* .prettierrc* .commitlintrc* .husky/ .pre-commit* .editorconfig .lintstagedrc* 2>/dev/null

# Environment and config templates
ls -la .env* .env.example .env.template 2>/dev/null

# Create nightly Issue
gh issue create --title "[Toil Review] $(date +%Y-%m-%d)" --body-file <report-file>

# Discover repo owner/name
gh repo view --json nameWithOwner -q .nameWithOwner
```

## Agent Feedback Loop

If the project has no source files at all (empty repo), report "Nothing to review" and stop.
If `gh` commands fail due to permissions, report the error and suggest the user check GitHub token scope.
If the user specifies an area that has no findings, still output that area with "No findings."

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "This README is fine, people need to read it." | If the README describes steps a human must execute, it is toil. Report it and suggest what it could become. |
| "The team already knows this convention." | Tribal knowledge is D1 toil. If it's not enforced by tooling, it will drift. |
| "CI is overkill for this project." | Not every project needs full CI. But if problems are caught only by human eyes, that's D3 toil. Report it. |
| "We can't automate everything." | The finding is not a mandate to automate. It is a record that toil exists. The reader decides. |
| "This is a small project, skip it." | Small projects accumulate toil faster because nobody thinks it's worth automating. Report it. |
| "The skill already exists, so there's no toil." | A skill that exists but is not wired into CI, hooks, or aliases is D4 toil. Existing but disconnected is not the same as integrated. |
| "Developers should just remember." | "Should just remember" is the definition of D1 toil. |
| "We have a README for that." | A README is D1 toil if it replaces what could be automation. Report what it could become. |
| "This dimension probably has no findings." | Run all four dimensions every time. Assumptions are the source of invisible toil. |
| "Only check the root files." | Root and near-root are the primary scope, but if a dimension's evidence is deeper (e.g., missing tests discovered in `src/`), include it. |

## Red Flags

- A dimension is missing from the output entirely (even as "No findings.")
- Findings are suppressed because "it's fine" or "the team handles it"
- Review modifies files or creates scripts
- Nightly Issue has a label applied
- Nightly Issue title does not follow `[Toil Review] YYYY-MM-DD` format
- Finding is missing what it could become (automation type not specified)
- Manual trigger with no input proceeds without asking the user what to review
- Review focuses on source code quality instead of project-level toil
- A skill that exists but is not integrated is treated as "no finding"
- A dimension is skipped because "this project is too small"
- Agent proceeds when `.rco/config.json` is missing without telling the user to run `rco-setup`

## Verification

- [ ] `.rco/config.json` was read
- [ ] If `.rco/config.json` was missing, user was told to run `rco-setup`
- [ ] Trigger mode and scope were determined correctly
- [ ] If manual with no input, user was asked what to review
- [ ] All four dimensions appear in the output (even if "No findings.")
- [ ] Each finding includes: what is wrong, where it manifests, what it could become
- [ ] No severity classification was applied to findings
- [ ] Nightly output: Issue with `[Toil Review] YYYY-MM-DD` title, no label
- [ ] Manual output: markdown report in conversation
- [ ] No code or files were modified during review
- [ ] Total finding count was reported
- [ ] Review focused on root and near-root, not deep source code
