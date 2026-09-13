# Security Model

## Native Permissions

OpenCode permissions are the primary safety layer:

- Sensitive paths are denied for read, edit, glob, and grep operations.
- Arbitrary Bash commands require approval.
- Only narrow, read-only Git and GitHub inspection commands are auto-approved.
- Agents that claim read-only access cannot use broad `git *` permissions.

Only these three read-only agents—`architect`, `code-reviewer`, and `deep-advisor`—have the two metadata-only Git commands auto-allowed: `git status --short` and `git branch --show-current`. Their other Bash patterns are denied, so this allowlist does not expose file contents.

When OpenCode runs with `--auto`, permission rules set to `ask` are approved automatically. These agents therefore use `bash: deny` by default—represented in agent front matter as `permission.bash."*": deny`—with only the two metadata-only Git commands above allowed.

Protected paths include `.env*`, `secrets/**`, `credentials/**`, SSH private-key names, `.npmrc`, `.yarnrc`, `.pypirc`, and `.pem`, `.key`, `.p12`, `.pfx` files.

## Local Security Plugin

`config/plugins/security.ts` runs in the OpenCode process. It protects direct file-tool paths by normalizing their arguments and rejecting protected targets. It also blocks a small set of clear destructive shell patterns, including recursive deletion, hard resets, forced cleanup, force pushes, protected-branch pushes, filesystem formatting, and download-pipe-shell commands. It does not parse or sanitize Git or Bash output.

The plugin is intentionally not a shell sandbox. Shell commands remain approval-gated, and users must not bypass policy through wrappers or alternate tools.

## Command Audit Log

The audit logger writes best-effort redacted, tab-delimited records to `~/.config/opencode/audit/log_YYYY-MM-DD.log`; write failures are suppressed and do not disrupt command execution. On Windows, this is `%USERPROFILE%\.config\opencode\audit`.

Best-effort records may include attempts, policy blocks, and completion events with timestamps, OpenCode session/call IDs, the working directory, redacted commands, policy reasons, and safe exit metadata. Completion entries include a normalized first-300-character output preview with best-effort redaction. Audit logs are potentially sensitive because output previews and metadata can still expose information. Credential-like values in environment assignments, flags, authorization headers, and URL query parameters are redacted before logging.

Daily logs are retained indefinitely for local analysis and future policy improvement. Records cover only Bash tool activity that reaches the OpenCode plugin; commands declined before tool execution or run outside OpenCode are not recorded, and storage failures can also leave activity unrecorded.

## MCP Boundaries

Context7 is read-oriented documentation lookup. Playwright is disabled by default because browser automation can access authenticated sessions and perform remote actions. Configure other MCPs per project, use OAuth or environment interpolation for credentials, and grant least privilege.

## Limits

Global configuration is not a hostile-project security boundary. It does not defend against malicious Git configuration or helpers, PATH changes, pagers, fsmonitor behavior, project-local OpenCode overrides, or metadata exposure such as audit previews. Do not open untrusted repositories with unrestricted agent permissions, and never commit secrets.
