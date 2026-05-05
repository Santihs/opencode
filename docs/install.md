# OpenCode Installation and Update Guide

This guide covers installing and updating the global OpenCode configuration on different platforms.

## Prerequisites

- [OpenCode installed](https://opencode.ai)
- A cloned copy of this repository

## Installation

### Linux / macOS (Bash/Zsh)

```bash
# 1. Clone this repository
git clone https://github.com/yourusername/opencode.git ~/opencode
cd ~/opencode

# 2. Run the installer
./update.sh
```

### Windows (PowerShell)

```powershell
# 1. Clone this repository
git clone https://github.com/yourusername/opencode.git $env:USERPROFILE\opencode
cd $env:USERPROFILE\opencode

# 2. Run the installer
.\update.ps1
```

## Updating

After pulling changes from the repository:

```bash
# Linux/macOS
./update.sh

# Windows
.\update.ps1
```

The update script will:

1. Create a timestamped backup of existing config
2. Copy new files from `config/` to the destination
3. Print a summary of changes

## Options

### Dry Run

Preview what would be copied:

```bash
./update.sh --dry-run
```

```powershell
.\update.ps1 -DryRun
```

### Force Overwrite

Replace existing files:

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

## Configuration Locations

After installation, your config will be at:

| Platform | Location |
|---------|----------|
| Linux | `~/.config/opencode/` |
| macOS | `~/.config/opencode/` |
| Windows | `%APPDATA%\opencode\` |

Backups are stored in same directory structure under `opencode-backups/`.

## Verifying Installation

```bash
opencode debug config
opencode
```

## Adding MCP Servers

This template does NOT include MCP configuration to avoid committing secrets.

### Adding an MCP Server

1. Edit your global config:
   - Linux/macOS: `~/.config/opencode/opencode.json`
   - Windows: `%APPDATA%\opencode\opencode.json`

2. Add your MCP configuration:

```json
{
  "mcp": {
    "my-mcp": {
      "type": "remote",
      "url": "https://mcp.example.com/mcp",
      "headers": {
        "API_KEY": "{env:MY_MCP_API_KEY}"
      }
    }
  }
}
```

3. Authenticate if needed:

```bash
opencode mcp auth my-mcp
```

### Common MCP Servers

See [OpenCode MCP documentation](https://opencode.ai/docs/mcp-servers/) for more.

## Customizing Per-Project

Add project-specific settings in your project root:

- `opencode.json` — project config
- `.opencode/` — project agents, commands, skills, plugins

Project settings override global settings.

## Uninstalling

Simply delete the global config directory:

```bash
rm -rf ~/.config/opencode
```