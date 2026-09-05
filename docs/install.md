# Installation And Update

OpenCode 1.18.28 stores global configuration in `~/.config/opencode`. On Windows this resolves to `%USERPROFILE%\.config\opencode`.

Run the installer from this repository:

```powershell
.\update.ps1
```

```bash
./update.sh
```

Each update creates a timestamped backup in `~/.config/opencode-backups` before replacing source-owned configuration files. Runtime-generated content such as logs, package installations, and authentication remains untouched.

Use `-DryRun` or `--dry-run` to preview updates. Restore a backup with `-Restore <id>|latest` or `--restore <id>|latest`.

Restart OpenCode after an update. Verify the result with:

```bash
opencode debug config
opencode mcp list
```

`%APPDATA%\opencode` is an inactive legacy location for this setup. The installer never reads, writes, or synchronizes it.
