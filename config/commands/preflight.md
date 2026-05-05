---
description: Discover and run reasonable project checks (lint, test, typecheck)
agent: build
---

# /preflight

Discover and run appropriate project checks.

## Process

1. **Discover** — inspect package.json scripts, check commands available
2. **Identify** — which checks make sense for the changes made
3. **Run** — execute the identified checks
4. **Report** — summarize results and suggest next steps

## Guidelines

- Prefer fast checks first (lint, format, typecheck)
- Don't run slow tests unless explicitly requested
- Report failures clearly with context
- Suggest targeted fixes

## Common Checks

Based on what's available:

- `pnpm tsc --noEmit` or `npm run typecheck`
- `pnpm check` or similar formatting check
- `pnpm test` or `pnpm test --run`
- `pnpm build` or similar build check