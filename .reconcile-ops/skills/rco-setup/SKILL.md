---
name: rco-setup
description: Set up ReconcileOps repository prerequisites and language configuration. Use when Codex needs to initialize or repair .reconcile-ops/config.json, install required local tools gh, jq, rg, and curl, or create language-specific example symlinks under .reconcile-ops/examples in an idempotent way.
---

# RCO Setup

Before doing any work, read `.reconcile-ops/RULE.md`.

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
- Rebuilding `.reconcile-ops/examples/*.md` symlinks
- Ensuring `gh`, `jq`, `rg`, and `curl` are available

## Core Principles

- Read `.reconcile-ops/RULE.md` before doing any work.
- Prefer the bundled script over manually rewriting setup commands.
- Keep setup idempotent.
- Skip steps that already satisfy the expected state.
- Do not overwrite language-specific example content.
- `config.json` stores only `preferred_language`.
- Supported language values are `en`, `zh`, and `jp`.

## Standard Workflow

1. Read `.reconcile-ops/RULE.md`.
2. Run the setup script from the repository root:

```bash
.reconcile-ops/skills/rco-setup/scripts/setup.sh
```

3. If the user already specified a language, pass it explicitly:

```bash
.reconcile-ops/skills/rco-setup/scripts/setup.sh --language zh
```

4. If prompted, ask the user for one language value: `en`, `zh`, or `jp`.
5. Confirm the script reports installed or already-present tools.
6. Confirm `.reconcile-ops/config.json` contains the selected `preferred_language`.
7. Confirm `.reconcile-ops/examples/*.md` are symlinks to `.reconcile-ops/examples/<language>/*.md`.

## Implementation Templates

Config shape:

```json
{
  "preferred_language": "en"
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

- `scripts/setup.sh`: Idempotently installs `gh`, `jq`, `rg`, and `curl` when missing, writes `.reconcile-ops/config.json`, creates language folders, and refreshes example symlinks.

Usage:

```bash
.reconcile-ops/skills/rco-setup/scripts/setup.sh --language en
```

Expected result: required tools exist, `config.json` has the selected language, and top-level example files symlink to the selected language folder.

## Agent Feedback Loop

If tool installation fails because Homebrew is unavailable, report the missing tool and stop.
After the user installs the missing dependency, re-run the same setup command. If symlinks point
to a language folder without translated files, report that examples for that language still need
to be created.

## Common Rationalizations

| Rationalization | Correct Response |
| --- | --- |
| "The tools are probably installed." | Check each tool and skip only confirmed installed tools. |
| "Rewrite example files directly." | Point top-level examples to language folders with symlinks. |
| "Store more config now." | `config.json` stores only `preferred_language` for v1. |
| "Run setup steps manually." | Use the bundled script so setup remains repeatable. |

## Red Flags

- Setup overwrites files under `.reconcile-ops/examples/en`, `zh`, or `jp`
- `.reconcile-ops/config.json` contains fields other than `preferred_language`
- Top-level `.reconcile-ops/examples/*.md` are regular files instead of symlinks
- Setup creates duplicate or nested example files
- The selected language is not `en`, `zh`, or `jp`

## Verification

- [ ] `.reconcile-ops/RULE.md` was read
- [ ] `gh`, `jq`, `rg`, and `curl` are installed or confirmed present
- [ ] `.reconcile-ops/config.json` exists
- [ ] `.reconcile-ops/config.json` contains only `preferred_language`
- [ ] `preferred_language` is `en`, `zh`, or `jp`
- [ ] `.reconcile-ops/examples/en`, `zh`, and `jp` exist
- [ ] Top-level example markdown files are symlinks to the selected language folder
- [ ] Re-running setup skips already-correct steps
