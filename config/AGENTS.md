# Global OpenCode Rules

- Treat sensitive files as unavailable: `.env*`, credentials, private keys, certificates, and secret directories.
- Ask before any shell command not explicitly approved by the global configuration.
- Never bypass permissions or the security plugin with alternate tools or shell wrappers.
- Use Context7 when current library or framework documentation is needed.
- Playwright is disabled globally; enable it only in a project that explicitly needs browser automation.
