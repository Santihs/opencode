---
name: powershell-command-practices
description: Use before running PowerShell shell commands, and immediately after ParserError, Unexpected token, quoted executable path, or caveman.CMD shrink command failures. Fixes missing call operator issues for quoted Windows executable paths.
---

# PowerShell Command Practices

Use this skill when preparing commands for OpenCode's PowerShell shell.

Also use this skill as soon as a shell command fails with `ParserError`, `Unexpected token`, or a command shaped like `'...caveman.CMD' shrink -- ...`.

## Command Invocation

- Invoke executable paths with the call operator.
- Correct: `& 'C:/Users/santi/AppData/Local/pnpm/caveman.CMD' shrink -- git diff -- README.md`
- Incorrect: `'C:/Users/santi/AppData/Local/pnpm/caveman.CMD' shrink -- git diff -- README.md`
- A quoted path by itself is a string expression in PowerShell, not a command invocation.
- Quote paths that contain spaces.

## Error Recovery

When a command fails with this shape:

```text
ParserError: Unexpected token 'shrink'
'C:/Users/santi/AppData/Local/pnpm/caveman.CMD' shrink -- ...
```

Retry once with the call operator:

```powershell
& 'C:/Users/santi/AppData/Local/pnpm/caveman.CMD' shrink -- ...
```

Do not repeat the original malformed command.

## Working Directory

- Prefer the tool `workdir` parameter instead of `Set-Location`.
- Avoid changing directories inside the command unless the command itself requires it.

## Command Shape

- Keep commands simple and explicit.
- Avoid command separators unless sequencing is required.
- Prefer multiple parallel tool calls for independent commands.
- Use `&&` only when the later command depends on the earlier command succeeding.

## File Operations

- Prefer dedicated read, glob, grep, and patch tools over shell commands for file inspection or edits.
- Before creating files or directories with shell commands, verify the parent path with `Test-Path -LiteralPath`.

## Package Managers

- Use `pnpm` for JavaScript package operations unless project docs or the user approve another package manager.
- Prefer `pnpm dlx` over `npx`.

## Before Running

- Check whether PowerShell will parse the command as intended.
- For executable paths, confirm the command begins with `&`.
- For arguments with nested quotes, prefer single quotes around arguments that contain double quotes.
