# OpenCode Global Configuration

Portable, source-controlled OpenCode defaults for development work. The configuration uses native OpenCode permissions and a local TypeScript security plugin to protect sensitive files and reject a small set of unambiguous destructive commands without per-command PowerShell startup overhead.

## Included

- Specialized agents for architecture, reviews, debugging, documentation, frontend work, and Git safety.
- Reusable commands and skills.
- A local security plugin protecting `.env*`, credentials, private keys, certificates, and secret directories.
- Context7 enabled for library documentation lookups.
- Playwright registered but disabled; enable it only in a project that needs browser automation.

## Install Or Update

OpenCode 1.18.28 uses `~/.config/opencode` on Windows, Linux, and macOS. On Windows this is typically `%USERPROFILE%\.config\opencode`, not `%APPDATA%\opencode`.

```powershell
.\update.ps1
```

```bash
./update.sh
```

Both scripts back up the active configuration before updating source-owned files. They do not touch OpenCode runtime data such as logs, authentication, cache data, `node_modules`, or the legacy `%APPDATA%\opencode` directory.

Preview an update:

```powershell
.\update.ps1 -DryRun
```

```bash
./update.sh --dry-run
```

Restore a backup:

```powershell
.\update.ps1 -Restore latest
```

```bash
./update.sh --restore latest
```

Restart OpenCode after applying configuration changes, then run:

```bash
opencode debug config
opencode mcp list
```

## Security Boundary

The configuration is a guardrail for trusted projects, not a sandbox against malicious project configuration. Project-local OpenCode configuration can override global defaults. Keep secrets out of repositories and use environment variables or OpenCode OAuth for MCP credentials.

## Continuous Integration

GitHub Actions runs the Bun security and audit tests on Ubuntu, plus the PowerShell installer tests on Windows, for every push and pull request. The workflow uses temporary test directories and never uploads audit logs or installs OpenCode.

## MCPs

- `context7` is enabled globally and requires no credential.
- `playwright` is disabled globally. Enable it only per project after confirming the browser data and actions it may access.
- Configure GitHub, Sentry, Obsidian, and Anki integrations per project with least-privilege credentials; do not add tokens to `opencode.json`.
