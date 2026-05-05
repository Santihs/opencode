---
description: Create commit plan, check for secrets, and prepare for safe commit
agent: git-guardian
---

# /safe-commit

Create a commit plan and check for safety issues.

## Process

1. **Inspect** — git status, git diff, git diff --stat
2. **Identify** — related file groups by intent
3. **Check** — look for secrets, keys, credentials
4. **Group** — organize into semantic commits
5. **Plan** — propose commit messages

## Rules

- Check for sensitive files before staging
- Use clear, semantic commit messages
- Don't force or amend commits
- Don't use --no-verify
- Ask before pushing

## Output

- Proposed commit plan with files per commit
- Safety check results
- Copy-paste commit commands ready for user confirmation