---
name: systematic-debugging
description: Use this skill when encountering any bug, test failure, or unexpected behavior — find root cause before proposing fixes
---

# Systematic Debugging

## The Iron Law

> **NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST**

If you complete only Phase 1, stop there. Don't propose fixes until you've completed root cause analysis.

## The Process

### Phase 1: Root Cause Investigation

1. **Read error messages carefully** — they often contain the solution
2. **Reproduce consistently** — can you trigger it reliably?
3. **Check recent changes** — what changed that could cause this?
4. **Gather evidence** — add diagnostic instrumentation
5. **Trace data flow** — where does bad value originate?

### Phase 2: Pattern Analysis

1. **Find working examples** — similar code that works
2. **Compare against references** — read documentation
3. **Identify differences** — what's different?
4. **Understand dependencies** — what does this need?

### Phase 3: Hypothesis and Testing

1. **Form single hypothesis** — "I think X because Y"
2. **Test minimally** — smallest change to test theory
3. **Verify before continuing** — did it work?

### Phase 4: Fix and Verify

1. **Implement minimal fix**
2. **Verify fix works**
3. **Check for regressions**

## What to Avoid

- Random fixes that seem obvious
- Quick patches without root cause
- Multiple fixes at once
- Assuming the issue without evidence