---
name: powershell-command-practices
description: Use before running PowerShell shell commands, especially commands with executable paths, quoted paths, generated commands, or Windows-specific syntax. Prevents parser mistakes and encourages safe command execution.
---

# PowerShell Command Practices

Use this skill when preparing commands for OpenCode's PowerShell shell.

## Command Invocation

- Invoke executable paths with the call operator.
- Correct: `& 'C:/Users/santi/AppData/Local/pnpm/caveman.CMD' shrink -- git diff -- README.md`
- Incorrect: `'C:/Users/santi/AppData/Local/pnpm/caveman.CMD' shrink -- git diff -- README.md`
- A quoted path by itself is a string expression in PowerShell, not a command invocation.
- Quote paths that contain spaces.

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
