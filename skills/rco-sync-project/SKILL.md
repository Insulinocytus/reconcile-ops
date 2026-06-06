---
name: rco-sync-project
description: Use when the AC Progress field in the GitHub Project is out of date and needs to reflect current Goal Issue checklist states
---

# RCO Sync Project

Sync AC Progress values in the GitHub Project from Goal Issue checklists.

Before any work, read `.rco/config.json` unless already read this session. If the file does not exist, stop and tell the user to run `rco-setup` first.

## When to Use

- After PRs merge and AC checklist items are checked off
- When the Project board shows stale AC Progress values
- Manually, whenever the user wants a fresh snapshot

## When NOT to Use

- Setting up the Project for the first time → `rco-setup`
- Nightly drift inspection → `rco-nightly-inspect`

## Core Principles

1. **Read-only on Issues.** Parse checklist state but never modify Issue bodies.
2. **Write-only on Project.** Update the `AC Progress` field, nothing else.
3. **Goal Issues only.** Only Issues with the `goal` label have AC Progress.

## Standard Workflow

1. Read `.rco/config.json`. If `github_project_id` is empty, stop — no Project to sync to.
2. List all Goal Issues:

   ```bash
   gh issue list --label goal --state all --json number,title,body
   ```

3. For each Goal Issue, parse the `## Acceptance Criteria` checklist:
   - Count total items (lines starting with `- [ ]` or `- [x]`)
   - Count checked items (lines starting with `- [x]`)
   - Compute progress string: `"checked/total"` (e.g., `2/5`, `3/3 ✅`)

4. For each Goal Issue, find its Project item ID:

   ```bash
   gh project item-list --project-id <project-id> --format json
   ```

5. Update the `AC Progress` field on each Project item:

   ```bash
   gh project item-edit --project-id <project-id> --id <item-id> --field-id <ac-progress-field-id> --text "<checked/total>"
   ```

6. Report summary: total Issues synced, any Issues not found in the Project.

## Implementation

```bash
# Get AC Progress field ID
gh project field-list --project-id <project-id> --format json | jq '.[] | select(.name=="AC Progress") | .id'

# List Goal Issues
gh issue list --label goal --state all --json number,title,body

# List Project items
gh project item-list --project-id <project-id> --format json

# Update a single item
gh project item-edit --project-id <project-id> --id <item-id> --field-id <field-id> --text "2/5"
```

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Modifying Issue body or checklist | Parse only, never write to Issues |
| Syncing ADR or Common Issues | Only Issues with `goal` label have AC Progress |
| Running without `github_project_id` | Stop and tell user to run `rco-setup` |
| Updating fields other than AC Progress | This skill only touches AC Progress |

## Red Flags

- Issue body is modified in any way
- ADR or Common Issues are included in the sync
- Skill runs when `github_project_id` is empty
- Project items are added or removed (only field values should change)

## Verification

- [ ] `.rco/config.json` was read
- [ ] `github_project_id` is non-empty
- [ ] Only `goal`-labeled Issues were processed
- [ ] No Issue body was modified
- [ ] AC Progress field was updated for each Goal Issue found in the Project
- [ ] Goal Issues not in the Project were reported, not silently skipped
