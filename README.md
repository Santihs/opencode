# OpenCode Global Configuration

This repository contains a portable, GitHub-tracked OpenCode configuration that can be installed globally on any machine.

## Purpose

- Provide a consistent, safe OpenCode setup across machines
- Reusable agents, commands, and skills for daily development
- Safety hooks to prevent destructive operations
- Easy install/update scripts for quick onboarding

## What's Included

### Agents
- `architect` — read-only architecture and tradeoff analysis
- `code-reviewer` — read-only code review (bugs, security, regressions)
- `debugger` — systematic root-cause debugging before fixes
- `docs-writer` — documentation and onboarding
- `frontend-engineer` — React/UI work without project assumptions
- `git-guardian` — safe git workflow, commit planning

### Commands
- `/diff-summary` — summarize working tree or branch diff
- `/explain-repo` — onboard a new user to a repo
- `/preflight` — discover and run project checks
- `/review-changes` — review staged/unstaged/untracked changes
- `/safe-commit` — create commit plan, check secrets

### Skills
- `ask-questions-if-underspecified` — clarify before dangerous work
- `git-safety` — branch, commit, push, secret handling
- `systematic-debugging` — root-cause-first debugging
- `tdd` — test-driven development workflow

### Safety
- Froggy hooks to block destructive bash commands
- Protection for sensitive files (`.env`, secrets, keys)
- Permission defaults that ask before dangerous edits

## Installation

### Linux / macOS

```bash
# Clone this repository
git clone https://github.com/yourusername/opencode.git ~/opencode
cd ~/opencode

# Run the installer
./update.sh
```

### Windows PowerShell

```powershell
# Clone this repository
git clone https://github.com/yourusername/opencode.git $env:USERPROFILE\opencode
cd $env:USERPROFILE\opencode

# Run the installer
.\update.ps1
```

## Update

After pulling changes from the repository:

```bash
./update.sh
```

Or on Windows:

```powershell
.\update.ps1
```

## Options

### Dry Run
Preview what would be copied without making changes:

```bash
./update.sh --dry-run
```

```powershell
.\update.ps1 -DryRun
```

### Force Overwrite
Replace all existing files (creates backup first):

```bash
./update.sh --force
```

```powershell
.\update.ps1 -Force
```

### Restore from Backup
Restore from a previous backup:

```bash
./update.sh --restore latest
./update.sh --restore 20250504-143000
```

```powershell
.\update.ps1 -Restore latest
.\update.ps1 -Restore 20250504-143000
```

## Backups

Backups are stored in:

- Linux/macOS: `~/.config/opencode-backups/YYYYMMDD-HHMMSS/`
- Windows: `$env:APPDATA\opencode-backups\YYYYMMDD-HHMMSS\`

## Configuration Locations

After installation, your global OpenCode config will be at:

- Linux/macOS: `~/.config/opencode/`
- Windows: `$env:APPDATA\opencode`

## Adding MCP Servers

This template does not include active MCP configuration to avoid committing secrets.

To add an MCP server:

1. Edit your global `opencode.json`
2. Add the MCP configuration (see `docs/mcp-setup.md` for examples)
3. Authenticate if needed: `opencode mcp auth <server-name>`

Common MCP servers (commented-out in template):
- GitHub
- Sentry
- Context7

## Verifying Installation

After running the update script:

```bash
opencode debug config
opencode
```

## Project-Specific Configuration

For project-local OpenCode settings, add an `opencode.json` file and `.opencode/` directory in your project root.

See `docs/deuna-migration.md` for the DeUna project migration example.

## Customization

To customize agents, commands, or skills for a specific project:

1. Copy the global file to your project
2. Modify it there
3. Project-local settings take precedence

## License

MIT — customize freely for your own setup.