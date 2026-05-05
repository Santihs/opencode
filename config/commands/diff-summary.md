---
description: Summarize working tree or branch diff
agent: git-guardian
---

# /diff-summary

Show a summary of current changes in the working tree or between branches.

## Usage

- `/diff-summary` — shows staged, unstaged, and untracked changes
- `/diff-summary <source>` — compares source branch with current branch
- `/diff-summary <source> <target>` — compares two branches

## What It Shows

1. **Overview** — files changed, insertions, deletions
2. **Commits** — recent commits on each branch
3. **Files** — what changed and how (stats)
4. **Full diff** — actual changes

## Rules

- Use read-only git commands
- Don't modify any files
- Check for secrets in changes
- Report if force-push would be required