---
name: git-commit-grouping
description: Use before creating commits when the worktree has multiple changed files or mixed concerns. Classifies changes by relationship, stages only one coherent group at a time, and creates valid focused commits.
---

# Git Commit Grouping

Use this skill before committing any worktree that may contain more than one concern.

## Goal

Create commits that match how files are related, not how recently they changed.

A valid commit contains one coherent concern that can be reviewed, reverted, and explained independently.

## Required Inspection

Before staging or committing:

1. Run `git status --short`.
2. Run `git diff --stat`.
3. Inspect `git diff` for modified files.
4. Inspect new files before staging them.
5. Check recent commit style with `git log --oneline -10`.

## Classification Rules

Split commits when changes represent different concerns:

- Feature or integration code
- Tests for a specific behavior
- Documentation updates
- Security policy or permission changes
- Logging, audit, or observability behavior
- Tooling, generated integration files, or local machine wiring
- Refactors that do not change behavior

Keep files together only when they support the same concern:

- Implementation plus its direct tests
- Config plus the code that requires that config
- Documentation that describes the same behavior being changed
- Generated file plus the command or config that consumes it

Do not combine unrelated changes just because all files are currently modified.

## Commit Plan

Before committing, write a short grouped plan:

- Group name
- Files included
- Why the files belong together
- Commit message
- Verification relevant to that group

If there is only one valid group, say why all changed files belong together.

## Staging Rules

- Stage explicit paths for exactly one group at a time.
- Use patch staging only when one file contains changes for multiple groups.
- Never stage sensitive files such as `.env*`, credentials, private keys, certificates, or secret directories.
- Re-run `git status --short` after each commit.

## Verification

Run the smallest sufficient proof before the first commit.

If groups are independent and verification differs by group, run the relevant proof for each group before committing that group.

## Commit Messages

- Follow existing repository style.
- Use a precise scope when possible.
- Keep the subject under 72 characters.
- Prefer messages that name the concern, not the file type.

Good examples:

- `feat(config): add caveman native integration`
- `chore(security): allow safe caveman wrapper commands`
- `docs(config): document global opencode guardrails`

Bad examples:

- `update files`
- `commit changes`
- `chore(config): update everything`
