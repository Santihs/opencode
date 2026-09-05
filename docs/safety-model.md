# Security Model

## Native Permissions

OpenCode permissions are the primary safety layer:

- Sensitive paths are denied for read, edit, glob, and grep operations.
- Arbitrary Bash commands require approval.
- Only narrow, read-only Git and GitHub inspection commands are auto-approved.
- Agents that claim read-only access cannot use broad `git *` permissions.

Protected paths include `.env*`, `secrets/**`, `credentials/**`, SSH private-key names, `.npmrc`, `.yarnrc`, `.pypirc`, and `.pem`, `.key`, `.p12`, `.pfx` files.

## Local Security Plugin

`config/plugins/security.ts` runs in the OpenCode process. It normalizes direct file-tool arguments and rejects protected targets. It also blocks a small set of clear destructive shell operations, including recursive deletion, hard resets, forced cleanup, force pushes, protected-branch pushes, filesystem formatting, and download-pipe-shell commands.

The plugin is intentionally not a shell sandbox. Shell commands remain approval-gated, and users must not bypass policy through wrappers or alternate tools.

## MCP Boundaries

Context7 is read-oriented documentation lookup. Playwright is disabled by default because browser automation can access authenticated sessions and perform remote actions. Configure other MCPs per project, use OAuth or environment interpolation for credentials, and grant least privilege.

## Limits

Global configuration is not a hostile-project security boundary. A project-local OpenCode configuration can override it. Do not open untrusted repositories with unrestricted agent permissions, and never commit secrets.
