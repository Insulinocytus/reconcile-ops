---
name: rco-setup
description: Set up ReconcileOps repository prerequisites and language configuration. Use when Codex needs to initialize or repair .reconcile-ops/config.json, install required local tools gh, jq, rg, curl, and mise, or create language-specific example symlinks under .reconcile-ops/examples in an idempotent way.
---

# RCO Setup

Before doing any work, read `.reconcile-ops/RULE.md` if it exists and has not already been read in this session.

## Overview

Set up the local ReconcileOps operating environment. The setup must be idempotent: if a tool,
config value, directory, or symlink already matches the expected state, leave it unchanged and
continue.

This skill prepares the repository for other `rco-*` skills by installing basic CLI tools,
setting the preferred language, and pointing top-level example files at the selected language
folder.

## When to Use

- Initializing ReconcileOps in a repository
- Repairing missing `.reconcile-ops/config.json`
- Changing the preferred ReconcileOps output language
- Rebuilding relative `.reconcile-ops/examples/*.md` symlinks
- Ensuring `gh`, `jq`, `rg`, `curl`, and `mise` are available

## Core Principles

- Execute the setup commands directly and verify each result.
- Keep setup idempotent.
- Skip steps that already satisfy the expected state.
- Do not create or overwrite language-specific example content.
- `config.json` stores only `preferred_language` and `branch_prefix`.
- Supported language values are `en`, `zh`, and `jp`.
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

2. Read `.reconcile-ops/RULE.md` if it exists and has not already been read in this session.
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

5. Ask the user for one language value if they did not already specify it: `en`, `zh`, or `jp`.
6. Ask the user for a branch prefix if they did not already specify one. Default: `ai/`. The prefix must end with `/`.
7. Confirm the selected language example directory exists. If it does not exist, stop and report that the repository is incomplete:

```bash
language="en"
test -d ".reconcile-ops/examples/$language"
```

8. Write `.reconcile-ops/config.json` with the selected language and branch prefix:

```bash
language="en"
branch_prefix="ai/"
printf '{\n  "preferred_language": "%s",\n  "branch_prefix": "%s"\n}\n' "$language" "$branch_prefix" > .reconcile-ops/config.json
```

9. Refresh top-level example symlinks for the selected language. Symlink targets must be relative paths:

```bash
language="en"
for file in requirement.md goal.md goal-issue.md pr.md spec.md; do
  target="$language/$file"
  link=".reconcile-ops/examples/$file"

  if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
    echo "ok: $link -> $target"
    continue
  fi

  if [ -e "$link" ] || [ -L "$link" ]; then
    rm "$link"
  fi

  ln -s "$target" "$link"
  echo "linked: $link -> $target"
done
```

10. Verify `.reconcile-ops/config.json` contains only `preferred_language` and `branch_prefix`.
11. Verify `.reconcile-ops/examples/*.md` are symlinks to `.reconcile-ops/examples/<language>/*.md`.

## Implementation Templates

Config shape:

```json
{
  "preferred_language": "en",
  "branch_prefix": "ai/"
}
```

Expected example layout:

```txt
.reconcile-ops/examples/
  en/
    requirement.md
    goal.md
    goal-issue.md
    pr.md
    spec.md
  zh/
  jp/
  requirement.md -> en/requirement.md
  goal.md -> en/goal.md
  goal-issue.md -> en/goal-issue.md
  pr.md -> en/pr.md
  spec.md -> en/spec.md
```

## Bundled Resources

- `skills/rco-setup/assets/.reconcile-ops/`: Complete `.reconcile-ops/` directory containing `RULE.md`, `GOAL_ISSUE_MAP.json`, `config.json`, and `examples/`. Copied to the project root when `.reconcile-ops/` does not already exist.

## Agent Feedback Loop

If tool installation fails because Homebrew is unavailable, report the missing tool and stop.
After the user installs the missing dependency, re-run the failed setup step. If symlinks point
to a language folder without translated files, report that examples for that language still need
to be created.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "The tools are probably installed." | Check each tool and skip only confirmed installed tools. |
| "Rewrite example files directly." | Point top-level examples to language folders with symlinks. |
| "Store more config now." | `config.json` stores only `preferred_language` and `branch_prefix` for v1. |
| "Run non-idempotent commands." | Check the current state first and skip already-correct steps. |
| "Overwrite .reconcile-ops/ to update it." | Do not overwrite an existing `.reconcile-ops/` directory. |

## Red Flags

- Setup overwrites an existing `.reconcile-ops/` directory
- Setup creates or overwrites files under `.reconcile-ops/examples/en`, `zh`, or `jp`
- `.reconcile-ops/config.json` contains fields other than `preferred_language` and `branch_prefix`
- `mise` is installed but `~/.zshrc` is missing the exact line `eval "$(mise activate zsh)"`
- Setup appends duplicate `mise` initialization lines to `~/.zshrc`
- Top-level `.reconcile-ops/examples/*.md` are regular files instead of symlinks
- Setup creates duplicate or nested example files
- The selected language is not `en`, `zh`, or `jp`

## Verification

- [ ] `.reconcile-ops/` exists in the project root (copied from assets if missing)
- [ ] `.reconcile-ops/RULE.md` was read if it existed
- [ ] `gh`, `jq`, `rg`, `curl`, and `mise` are installed or confirmed present
- [ ] `~/.zshrc` contains the exact line `eval "$(mise activate zsh)"`
- [ ] `.reconcile-ops/config.json` exists
- [ ] `.reconcile-ops/config.json` contains only `preferred_language` and `branch_prefix`
- [ ] `preferred_language` is `en`, `zh`, or `jp`
- [ ] `branch_prefix` ends with `/`
- [ ] Selected language directory exists under `.reconcile-ops/examples/`
- [ ] Top-level example markdown files are relative symlinks to the selected language folder
- [ ] Re-running setup skips already-correct steps
