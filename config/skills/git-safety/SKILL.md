---
name: git-safety
description: Use this skill for any git operations involving commits, pushes, or branch changes. Prevents destructive operations and checks for secrets.
---

# Git Safety

## When to Use

Use this skill when:

- Creating commits
- Running git push or force-push
- Checking out branches
- Merging or rebasing
- Any destructive git operation

## Safety Rules

### Block Without Explicit Approval

- Force push: `git push --force`, `git push -f`
- Push to main/master without PR workflow
- Hard reset: `git reset --hard`
- Clean with force: `git clean -fd`
- Amending published commits
- Checkout that discards changes

### Always Check Before Committing

- No secrets, keys, credentials in changes
- No `.env`, `.env.*` files staged
- No API keys or tokens
- No sensitive configuration

### Recommended Workflow

1. **Review** — use git status, git diff first
2. **Check** — scan for sensitive files
3. **Group** — organize into logical commits
4. **Plan** — propose messages before committing
5. **Confirm** — ask before executing

## Commit Message Best Practices

- Use clear, descriptive messages
- Follow project's commit convention
- Reference issues/tickets where relevant
- Keep first line under 72 characters