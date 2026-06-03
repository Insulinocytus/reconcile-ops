---
name: rco-setup
description: Set up ReconcileOps repository prerequisites and configuration. Use when Codex needs to initialize or repair .reconcile-ops/config.json, install required local tools gh, jq, rg, curl, and mise in an idempotent way.
---

# RCO Setup

Before doing any work, read `.reconcile-ops/config.json` if it exists and has not already been read in this session.

## Overview

Set up the local ReconcileOps operating environment. The setup must be idempotent: if a tool,
config value, or directory already matches the expected state, leave it unchanged and
continue.

This skill prepares the repository for other `rco-*` skills by installing basic CLI tools,
setting the preferred language, and pointing top-level example files at the selected language
folder.

## When to Use

- Initializing ReconcileOps in a repository
- Repairing missing `.reconcile-ops/config.json`
- Ensuring `gh`, `jq`, `rg`, `curl`, and `mise` are available

## Core Principles

- Execute the setup commands directly and verify each result.
- Keep setup idempotent.
- Skip steps that already satisfy the expected state.
- `config.json` stores `branch_prefix`, `github_project_url`, and `github_project_id`.
- Do not overwrite an existing `.reconcile-ops/` directory.

## Standard Workflow

1. Ensure `.reconcile-ops/` exists in the project root. If it does not exist, copy it from the skill assets:

```bash
if [ ! -d ".reconcile-ops" ]; then
  cp -r skills/rco-setup/assets/.reconcile-ops ./
  echo "copied: skills/rco-setup/assets/.reconcile-ops -> .reconcile-ops"
else
  echo "ok: .reconcile-ops already exists"
fi
```

2. Read `.reconcile-ops/config.json` if it exists and has not already been read in this session.
3. Check required tools and install only missing tools:

```bash
for tool in gh jq rg curl mise; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "ok: $tool already installed"
  else
    echo "install: $tool"
    brew install "$tool"
  fi
done
```

4. Ensure `mise` is initialized in `~/.zshrc`. Append the activation line only when it is missing:

```bash
if ! grep -Fxq 'eval "$(mise activate zsh)"' "$HOME/.zshrc" 2>/dev/null; then
  printf '\n# mise\n%s\n' 'eval "$(mise activate zsh)"' >> "$HOME/.zshrc"
  echo "updated: $HOME/.zshrc"
else
  echo "ok: mise already initialized in $HOME/.zshrc"
fi
```

5. Ask the user for a branch prefix if they did not already specify one. Default: `ai/`. The prefix must end with `/`.
6. Ask the user for a GitHub Project URL if they did not already specify one and `github_project_url` is empty in the config. If provided, resolve the project ID using `gh`:

```bash
gh project view --owner <org-or-user> --format json --jq '.id' <project-number>
```

If the user does not have a GitHub Project, leave `github_project_url` and `github_project_id` empty. The user can add this later by re-running setup.

7. Write `.reconcile-ops/config.json` with the branch prefix and project info:

```bash
printf '{\n  "branch_prefix": "%s",\n  "github_project_url": "%s",\n  "github_project_id": "%s"\n}\n' "$branch_prefix" "$project_url" "$project_id" > .reconcile-ops/config.json
```

8. Verify `.reconcile-ops/config.json` contains `branch_prefix`, `github_project_url`, and `github_project_id`.

## Implementation Templates

Config shape:

```json
{
  "branch_prefix": "ai/",
  "github_project_url": "https://github.com/orgs/OWNER/projects/1",
  "github_project_id": "PVT_xxxxx"
}
```

Expected example layout:

```txt
.reconcile-ops/examples/
  requirement.md
  goal.md
  pr.md
```

## Bundled Resources

- `skills/rco-setup/assets/.reconcile-ops/`: Complete `.reconcile-ops/` directory containing `config.json` and `examples/`. Copied to the project root when `.reconcile-ops/` does not already exist.

## Agent Feedback Loop

If tool installation fails because Homebrew is unavailable, report the missing tool and stop.
After the user installs the missing dependency, re-run the failed setup step.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "The tools are probably installed." | Check each tool and skip only confirmed installed tools. |
| "Store more config now." | `config.json` stores `branch_prefix`, `github_project_url`, and `github_project_id` for v1. |
| "Run non-idempotent commands." | Check the current state first and skip already-correct steps. |
| "Overwrite .reconcile-ops/ to update it." | Do not overwrite an existing `.reconcile-ops/` directory. |

## Red Flags

- Setup overwrites an existing `.reconcile-ops/` directory
- `.reconcile-ops/config.json` contains fields other than `branch_prefix`, `github_project_url`, and `github_project_id`
- `mise` is installed but `~/.zshrc` is missing the exact line `eval "$(mise activate zsh)"`
- Setup appends duplicate `mise` initialization lines to `~/.zshrc`

## Verification

- [ ] `.reconcile-ops/` exists in the project root (copied from assets if missing)
- [ ] `.reconcile-ops/config.json` was read if it existed
- [ ] `gh`, `jq`, `rg`, `curl`, and `mise` are installed or confirmed present
- [ ] `~/.zshrc` contains the exact line `eval "$(mise activate zsh)"`
- [ ] `.reconcile-ops/config.json` exists
- [ ] `.reconcile-ops/config.json` contains `branch_prefix`, `github_project_url`, and `github_project_id`
- [ ] `branch_prefix` ends with `/`
- [ ] Re-running setup skips already-correct steps
