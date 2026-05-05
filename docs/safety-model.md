# OpenCode Safety Model

This document describes what is allowed, asked for, and denied by the global configuration.

## Permission Defaults

### Read Actions

| Pattern | Behavior | Reason |
|---------|----------|--------|
| `*` | allow | Most files are safe to read |
| `*.env` | deny | Never read environment files |
| `*.env.*` | deny | Never read environment variants |

### Edit Actions

| Pattern | Behavior | Reason |
|---------|----------|--------|
| `*` | ask | Confirm before making changes |

### Bash Actions

| Pattern | Behavior | Reason |
|---------|----------|--------|
| `*` | ask | Confirm before running commands |
| `git status*` | allow | Safe read-only commands |
| `git diff*` | allow | Safe read-only commands |
| `git log*` | allow | Safe read-only commands |
| `git branch*` | allow | Safe read-only commands |
| `grep *` | allow | Safe search commands |

### Web Actions

| Pattern | Behavior | Reason |
|---------|----------|--------|
| `*` | ask | Confirm before fetching from web |

## Hook Enforcement

Beyond permissions, Froggy hooks enforce:

### Blocked Commands

- Force push: `git push --force`, `git push -f`
- Direct push to main/master (without PR workflow)
- Hard reset: `git reset --hard`
- Recursive delete: `rm -rf`
- Git clean force: `git clean -fd`
- Checkout discarding: `git checkout -- .`

### Protected Files

Hook scripts also block reading/writing:

- `.env`, `.env.*`
- `secrets/**`
- `credentials/**`
- `*.pem`, `*.key`
- API keys, tokens, passwords

## Why This Model

### Safe Defaults

- Ask before destructive operations
- Block sensitive file access by default
- Allow safe exploration and code review

### Granular Control

- Specific git commands allowed (status, diff, log)
- Dangerous commands require approval
- Per-command pattern matching

### Defense in Depth

1. Permissions: first layer of defense
2. Hooks: second layer for complex checks
3. Ask mode: human-in-the-loop

## Overriding

You can override defaults per-project or per-machine:

1. Create `opencode.json` in project root
2. Add your override permissions
3. Project settings take precedence

### Example Override

```json
{
  "permission": {
    "bash": {
      "*": "allow",
      "git push *": "ask"
    }
  }
}
```

## Emergency Escape

If locked out or blocked:

1. Edit `~/.config/opencode/opencode.json` directly
2. Remove or adjust permission rules
3. Restart OpenCode

Or temporarily rename the config:

```bash
mv ~/.config/opencode ~/.config/opencode-temp
```