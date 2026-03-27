# TDD Principles

These principles are enforced by `cccx-tdd` and used by `cccx-implement` and `cccx-debug`.

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

## RED-GREEN-REFACTOR

### RED: Write a failing test

- One minimal test showing desired behavior
- Clear name describing what is being tested
- Real code, not mocks (unless testing external service boundaries)
- Test must compile/parse without errors

### Verify RED (mandatory)

- Run the test
- Confirm it **fails** (not errors)
- Confirm it fails for the **expected reason** (missing feature, not typo)
- If test passes: you are testing existing behavior -- fix the test
- If test errors: fix the error, re-run until proper failure

### GREEN: Write minimal code

- Simplest code that makes the test pass
- Do not add features, refactor, or "improve"
- Hardcoded return values are acceptable if they pass the test

### Verify GREEN (mandatory)

- Run the test: it must pass
- Run the full test suite: other tests must still pass
- Output must be clean (no warnings, no skipped tests)

### REFACTOR: Clean up

- Only after green
- Remove duplication, improve names, extract helpers
- Tests must stay green throughout
- Do not add behavior during refactoring

## Anti-Patterns

### Testing mock behavior

Writing tests that verify mock behavior instead of real behavior. The test passes, but the real code is untested.

**Fix:** Use real implementations. Reserve mocks for external service boundaries only.

### Test-only methods in production code

Adding methods or accessors to production code solely for test access.

**Fix:** Test through public interfaces. If you can't test it, the design needs to change.

### Writing tests after implementation

Tests written after code tend to verify "what does it do?" instead of "what should it do?" They pass immediately and prove nothing about intent.

**Fix:** Delete the implementation. Write the test. Watch it fail. Re-implement.

### Skipping the RED phase

Writing code and test simultaneously, or writing the test that you know will pass.

**Fix:** Discipline. The failing test is the specification. Without seeing it fail, you cannot trust it.

## When Mocks Are Acceptable

- External HTTP services (use a stub server or mock client)
- Database connections in unit tests (but prefer integration tests with real DB)
- Time-dependent behavior (mock the clock)
- Third-party APIs with rate limits or costs

## Common Rationalizations (All Wrong)

| Rationalization | Reality |
|---|---|
| "Too simple to test" | Simple code breaks. The test takes 30 seconds. |
| "I'll test after" | Tests-after pass immediately and prove nothing about intent. |
| "TDD slows me down" | TDD is faster than debugging. |
| "I'll keep this as reference" | You'll adapt it. That's testing after. Delete and start fresh. |
| "Just this once" | There is no "just this once." The discipline is the value. |
