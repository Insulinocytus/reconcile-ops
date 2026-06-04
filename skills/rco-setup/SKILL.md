---
name: rco-setup
description: Use when initializing a ReconcileOps repository for the first time, or when .rco/ is missing, incomplete, or needs updating.
---

# RCO Setup

Before doing any work, read `.rco/config.json` if it exists and has not already been read in this session.

## Overview

Set up the local ReconcileOps operating environment. Check everything first, then fix
only what is broken, in order. If everything passes, ask the user whether to update
configuration.

## When to Use

- Initializing ReconcileOps in a repository
- Repairing missing or incomplete `.rco/config.json`
- Adding or updating `pr_reviewers` scope configuration
- Ensuring required tools are available

## Core Principles

- Check everything in one pass before making any changes.
- Fix items in a fixed order, skipping anything that already passes.
- Keep setup idempotent.
- `config.json` stores `branch_prefix`, `github_project_url`, `github_project_id`, and `pr_reviewers`.
- `REVIEW.md` stores project-specific PR review dimensions. Optional — `rco-review-pr` works without it but will check custom dimensions if present.
- Do not overwrite an existing `.rco/` directory.

## Standard Workflow

1. Check all items in one pass:
   - Is `mise` installed?
   - Is `mise` initialized in `~/.zshrc`?
   - Are `gh`, `jq`, `rg`, `curl` installed (via `mise`)?
   - Does `.rco/` directory exist?
   - Does `.rco/config.json` exist and contain `branch_prefix`, `github_project_url`, `github_project_id`, and `pr_reviewers`?
   - Does `.rco/REVIEW.md` exist?

2. If everything passes, ask the user whether to update `config.json`. If no, stop. If yes, skip to step 4.

3. If any check fails, fix items in order, skipping those that already pass:

   **3a. Install mise if missing:**

   ```bash
   if ! command -v mise >/dev/null 2>&1; then
     brew install mise
   fi
   ```

   **3b. Initialize mise in `~/.zshrc` if missing:**

   ```bash
   if ! grep -Fxq 'eval "$(mise activate zsh)"' "$HOME/.zshrc" 2>/dev/null; then
     printf '\n# mise\n%s\n' 'eval "$(mise activate zsh)"' >> "$HOME/.zshrc"
   fi
   ```

   **3c. Install missing tools via mise:**

   ```bash
   for tool in gh jq rg curl; do
     if ! command -v "$tool" >/dev/null 2>&1; then
       mise use -g "$tool"
     fi
   done
   ```

   **3d. Copy `.rco/` from assets if missing:**

   ```bash
   if [ ! -d ".rco" ]; then
     cp -r skills/rco-setup/assets/.rco ./
   fi
   ```

4. Ask the user for configuration values that are missing or need updating, one at a time:
   - `branch_prefix` — default `ai/`, must end with `/`.
   - GitHub Project URL — optional. If provided, resolve the project ID:

   ```bash
   gh project view --owner <org-or-user> --format json --jq '.id' <project-number>
   ```

   - `pr_reviewers` — ask whether to configure now. If yes, collect scope definitions one at a time. Each scope requires:
     - Scope name (e.g., `backend`, `frontend`, `security`, `database`, `goal`)
     - `paths`: list of path prefixes that belong to this scope
     - `conditions`: list of natural-language conditions (can be empty)
     - `reviewers`: list of GitHub usernames

5. Write `.rco/config.json` with all collected values.

6. Verify configuration completeness.

## Implementation Templates

Config shape:

```json
{
  "branch_prefix": "ai/",
  "github_project_url": "https://github.com/orgs/OWNER/projects/1",
  "github_project_id": "PVT_xxxxx",
  "pr_reviewers": {
    "backend": {
      "paths": ["src/api/", "src/services/", "src/core/"],
      "conditions": [],
      "reviewers": ["alice", "bob"]
    },
    "frontend": {
      "paths": ["src/components/", "src/pages/", "src/styles/"],
      "conditions": [],
      "reviewers": ["carol"]
    },
    "security": {
      "paths": ["src/auth/", "src/middleware/"],
      "conditions": ["Changes involving authentication, authorization, or sensitive data"],
      "reviewers": ["dave"]
    },
    "goal": {
      "paths": ["docs/goals/"],
      "conditions": ["Changes to Goal acceptance criteria or source requirements"],
      "reviewers": ["alice"]
    }
  }
}
```

## Bundled Resources

- `skills/rco-setup/assets/.rco/`: Complete `.rco/` directory containing `config.json` and `REVIEW.md`. Copied to the project root when `.rco/` does not already exist.

## Agent Feedback Loop

If tool installation fails because Homebrew or mise is unavailable, report the missing tool and stop.
After the user installs the missing dependency, re-run the failed setup step.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "The tools are probably installed." | Check each tool and skip only confirmed installed tools. |
| "Run non-idempotent commands." | Check the current state first and skip already-correct steps. |
| "Overwrite .rco/ to update it." | Do not overwrite an existing `.rco/` directory. |
| "Skip pr_reviewers, add it later." | Scope-to-reviewer mapping is essential for PR creation. At minimum configure the scopes the project uses. |

## Red Flags

- Setup overwrites an existing `.rco/` directory
- Setup makes changes before checking all items first
- `mise` is installed but `~/.zshrc` is missing the exact line `eval "$(mise activate zsh)"`
- Setup appends duplicate `mise` initialization lines to `~/.zshrc`
- Tools are installed via `brew` instead of `mise`
- `pr_reviewers` is empty after setup completes without the user explicitly declining

## Verification

- [ ] All items were checked in one pass before any changes
- [ ] `mise` is installed or was installed
- [ ] `mise` is initialized in `~/.zshrc` (exact line `eval "$(mise activate zsh)"`)
- [ ] `gh`, `jq`, `rg`, `curl` are installed or were installed via `mise`
- [ ] `.rco/` exists in the project root (copied from assets if missing)
- [ ] `.rco/config.json` was read if it existed
- [ ] `.rco/config.json` contains `branch_prefix`, `github_project_url`, `github_project_id`, and `pr_reviewers`
- [ ] `.rco/REVIEW.md` exists (optional — not required for setup to pass)
- [ ] `branch_prefix` ends with `/`
- [ ] `pr_reviewers` has at least one scope configured (or user explicitly declined)
- [ ] Re-running setup skips already-correct steps
