---
name: git-safety
description: Use this skill for any git operations involving commits, pushes, or branch changes. Prevents destructive operations, checks for secrets, and requires commit grouping when changes span multiple concerns.
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
- Changes are classified into related commit groups before staging
- Each commit contains one coherent concern unless all changed files directly support the same behavior

### Recommended Workflow

1. **Review** — use git status, git diff first
2. **Check** — scan for sensitive files
3. **Group** — use `git-commit-grouping` to classify related changes
4. **Stage** — stage explicit paths for one group at a time
5. **Plan** — prepare commit messages before committing
6. **Confirm** — ask before destructive or remote operations

## Commit Grouping Requirement

Use the `git-commit-grouping` skill before committing when more than one file changed, when new files are present, or when the diff touches multiple areas.

Do not create one broad commit for mixed concerns such as feature code, logging, security policy, docs, generated files, and tests. Split them by relationship and commit each group separately.

If a single commit is still correct, state why the files form one concern before committing.

## Commit Message Best Practices

- Use clear, descriptive messages
- Follow project's commit convention
- Reference issues/tickets where relevant
- Keep first line under 72 characters
