---
name: tdd
description: Use this skill when asked to implement new features, bugs, or functionality. Follow test-driven development workflow.
---

# Test-Driven Development

## When to Use

Use this skill when:

- Implementing new features
- Fixing bugs
- Adding functionality
- Building components

## The TDD Workflow

### 1. Write the Test First (RED)

Write a test that describes the expected behavior.

```typescript
describe("feature", () => {
  it("should do X when Y", () => {
    expect(result).toBe(expected);
  });
});
```

### 2. Make it Pass (GREEN)

Write the minimal implementation to pass the test.

```typescript
function feature() {
  return expected;
}
```

### 3. Refactor (REFACTOR)

Improve the implementation while keeping tests passing.

```typescript
// Improve code structure
// Add edge cases
// Optimize performance
```

## Guidelines

- Write failing tests first
- Test behavior, not implementation
- Test happy path AND edge cases
- Test error handling
- Keep tests fast and independent

## Test Structure

- One describe block per function/component
- Clear it descriptions
- Meaningful assertions
- Minimal setup needed

## What Not to Do

- Don't write tests after implementation
- Don't test internal details
- Don't make tests depend on each other
- Don't skip failing tests