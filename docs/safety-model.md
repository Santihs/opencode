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

## MCP Boundaries

Context7 is read-oriented documentation lookup. Playwright is disabled by default because browser automation can access authenticated sessions and perform remote actions. Configure other MCPs per project, use OAuth or environment interpolation for credentials, and grant least privilege.

## Limits

Global configuration is not a hostile-project security boundary. It does not defend against destructive commands approved by the user, malicious Git configuration or helpers, PATH changes, pagers, fsmonitor behavior, or project-local OpenCode overrides. Do not open untrusted repositories with unrestricted agent permissions, and never commit secrets.
