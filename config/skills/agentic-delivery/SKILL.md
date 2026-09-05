---
name: agentic-delivery
description: Use when implementing non-trivial software changes, deciding whether to delegate to subagents, planning PR-quality delivery, or balancing quality against token cost. Enforces lean orchestration: one agent by default, specialist agents only when complexity or risk justifies them, with final verification owned by the main thread.
---

# Agentic Delivery

Use this skill to deliver software changes with professional quality without wasting tokens on unnecessary ceremony.

## Core Principle

The main thread owns the outcome. Subagents can explore, implement, test, or review, but they do not replace final judgment, diff inspection, or verification.

Default to the smallest workflow that is safe for the task.

## Task Tiers

### Tier 1 — Main Thread Only

Use for small, low-risk work:

- Docs and README edits
- Prompt/config file additions
- One-file changes
- Obvious typo or formatting fixes
- Simple command/template mirrors

Workflow: explore briefly, edit, run the narrowest relevant check, inspect diff, finish.

### Tier 2 — Main Thread + Tests

Use when behavior changes but scope is contained:

- CLI flags or parser behavior
- Schema/model changes
- Deterministic transformations
- Bug fixes with clear reproduction
- Small application logic changes

Workflow: explore, write or update tests first when practical, implement, run targeted tests, run broader checks if risk warrants it.

Apply the `tdd` skill for new behavior or bug fixes that can be specified with tests.

### Tier 3 — Main Thread + Reviewer

Use when the diff is risky even if implementation is small:

- Security or permissions
- Installers, migrations, deploy scripts
- Data-loss or overwrite risk
- Git automation
- Cross-project configuration

Workflow: implement and test directly, then use a read-only reviewer before committing or finalizing.

### Tier 4 — Orchestrated Delivery

Use only for broad or high-risk work:

- Multi-layer features
- Domain-driven design changes
- Frontend plus backend plus persistence
- Large refactors
- Unfamiliar codebases with many affected files

Workflow: main thread plans and scopes, optional explore agent maps the code, implementer handles bounded chunks, test agent adds coverage, reviewer checks final diff, main thread verifies and decides.

## Delegation Rules

- Delegate only bounded work with clear inputs and expected output.
- Tell subagents whether they may edit files; reviewers should be read-only.
- Do not ask multiple agents to do the same work unless intentionally comparing approaches.
- Do not spawn agents for simple tasks just to feel rigorous.
- Keep exactly one source of final truth: the main thread's inspected diff and passing checks.

## Professional Delivery Loop

1. Explore the current code before assuming structure.
2. Classify the task tier.
3. Choose the minimum safe workflow.
4. Implement the smallest correct change.
5. Add or update tests when behavior changes.
6. Run targeted checks first, broader checks when risk warrants it.
7. Inspect the final diff for secrets, unrelated edits, and behavior regressions.
8. Use a reviewer on non-trivial or risky changes.
9. Commit only when explicitly requested and after verification.

## Token Budget Rules

- Prefer direct work over framework-heavy planning for small tasks.
- Prefer reading specific files over broad scans.
- Prefer one reviewer pass over repeated self-debate.
- Summarize findings tightly; avoid long progress narratives.
- Use subagents to save context only when they prevent the main thread from loading large unrelated areas.

## When In Doubt

If the user asks for speed, keep it Tier 1 or Tier 2 unless there is clear risk.

If the user asks for production-grade quality, do not automatically jump to Tier 4. Add review and verification first; add implementer/test subagents only if scope justifies them.
