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
- Optionally installing the nightly review GitHub Actions workflow

## Core Principles

- Check everything in one pass before making any changes.
- Fix items in a fixed order, skipping anything that already passes.
- Keep setup idempotent.
- `config.json` stores `branch_prefix`, `github_project_url`, `github_project_id`, and `pr_reviewers`.
- GitHub Project setup (Step 5) only runs when `github_project_id` is non-empty. It creates views and the `AC Progress` field idempotently.
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

5. If `github_project_id` is present (non-empty), set up the GitHub Project:

   **5a. Ensure the `goal` and `adr` labels exist:**

   ```bash
   for label in goal adr; do
     gh label list --json name --jq '.[].name' | grep -qx "$label" || gh label create "$label" --description "${label} issue" --color '0E8A16'
   done
   ```

   **5b. Create 3 views if missing:**

   Check existing views:

   ```bash
   gh project view --format json --jq '.views[].name' <project-number>
   ```

   - **Roadmap** (Table): group by Milestone, columns = Title / Status. Sort by Milestone.
   - **Kanban** (Board): group by Status (Todo / In Progress / Done / Superseded)
   - **ADR Log** (Table): filter by `adr` label, columns = Title / Status, sort by Created descending

   For each view that does not already exist, create it via `gh project view-create`.

   **5c. Add existing open Issues to the Project:**

   ```bash
   gh issue list --state open --json url --jq '.[].url' | while read url; do
     gh project item-add <project-id> --url "$url"
   done
   ```

   Skip this step if all items are already in the project (idempotent — `item-add` on an existing item is a no-op that errors harmlessly).

6. Write `.rco/config.json` with all collected values.

7. Ask the user whether to install GitHub Actions workflow templates. Offer both independently:
   - **Nightly review** — scheduled drift inspection, spaghetti code review, toil review
   - **PR review** — automatic review on PR open/update, and `/review` keyword in PR comments

   For each workflow the user accepts:
   - Check whether the target file already exists under `.github/workflows/`
   - If it does not exist, copy from assets:

   ```bash
   mkdir -p .github/workflows
   cp skills/rco-setup/assets/.github/workflows/<workflow>.yml .github/workflows/
   ```

   - If it already exists, skip and inform the user.
   - **Tell the user this is a template, not a ready-to-run workflow.** They must adapt:
     - Replace `ANTHROPIC_API_KEY` with their chosen provider's secret name
     - Adjust skill paths to match their project layout
     - Adjust pi flags (model, thinking level) to their preference
     - Add or remove review steps as needed
   - After the user adapts the file, remind them to configure the API key as a repository secret.

8. Verify configuration completeness.

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
- `skills/rco-setup/assets/.github/workflows/nightly-review.yml`: Nightly review workflow **template**. Copied to the project root when the user opts in during setup. Must be adapted before use — provider secret name, skill paths, and pi flags are placeholders.
- `skills/rco-setup/assets/.github/workflows/pr-review.yml`: PR review workflow **template**. Triggers on PR open/update and `/review` keyword. Same adaptation requirements as above.

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
| "Skip project setup because there are no issues yet." | Create the views and field anyway — they are empty until issues arrive. |
| "Install the workflow without asking." | The workflow is optional — the user may have their own CI/CD solution. Ask first. |
| "Overwrite the existing workflow." | Do not overwrite an existing `.github/workflows/nightly-review.yml`. |
| "The workflow is ready to run after setup." | It is a template. The user must adapt provider secrets, skill paths, and pi flags before it can run. |

## Red Flags

- Setup overwrites an existing `.rco/` directory
- Setup makes changes before checking all items first
- `mise` is installed but `~/.zshrc` is missing the exact line `eval "$(mise activate zsh)"`
- Setup appends duplicate `mise` initialization lines to `~/.zshrc`
- Tools are installed via `brew` instead of `mise`
- `pr_reviewers` is empty after setup completes without the user explicitly declining
- Project views or AC Progress field are missing when `github_project_id` is present
- `goal` or `adr` labels are missing from the repository when `github_project_id` is present

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
- [ ] If `github_project_id` is present, `goal` and `adr` labels exist in the repository
- [ ] If `github_project_id` is present, Project has Roadmap / Kanban / ADR Log views
- [ ] If `github_project_id` is present, Project has Roadmap / Kanban / ADR Log views
- [ ] If `github_project_id` is present, existing open Issues were added to the Project
- [ ] If user opted in, `.github/workflows/nightly-review.yml` was copied (or already existed)
- [ ] If user opted in, user was told the workflow is a template and must be adapted
- [ ] If user opted in, user was reminded to configure API key secret after adapting
- [ ] Re-running setup skips already-correct steps
