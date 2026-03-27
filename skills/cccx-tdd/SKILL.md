---
name: cccx-tdd
description: Use when writing any new code, fixing bugs, or changing behavior. Enforces test-driven development discipline. This is a rigid skill -- follow it exactly.
---

# Test-Driven Development

## Overview

Enforce the RED-GREEN-REFACTOR cycle for all code changes. This is a discipline skill, not a workflow skill -- it is invoked by other skills (`cccx-implement`, `cccx-debug`) during execution.

**Iron Law: NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST**

## When to Use

- Always, when writing new features
- Always, when fixing bugs
- Always, when changing behavior
- Always, when refactoring (tests must exist first)

Exceptions (ask human partner first):
- Throwaway prototypes explicitly marked as disposable
- Generated code (e.g., migrations, scaffolding)
- Configuration files with no behavioral logic

## Workflow

### Step 1: RED -- Write a Failing Test

Write one minimal test that demonstrates the desired behavior.

Requirements:
- Clear name describing what is tested
- Tests real code, not mocks (unless at external service boundaries)
- Compiles/parses without errors
- Tests exactly one behavior

### Step 2: Verify RED (mandatory -- do not skip)

Run the test:

```
npm test <path>    # or pytest, cargo test, go test, etc.
```

Confirm:
- [ ] Test **fails** (not errors)
- [ ] Fails for the **expected reason** (missing function, wrong return value -- not syntax error or import failure)

If test passes: you are testing existing behavior. Fix the test.
If test errors: fix the error. Re-run until proper failure.

### Step 3: GREEN -- Write Minimal Code

Write the **simplest** code that makes the test pass.

Rules:
- Do not add features beyond what the test requires
- Do not refactor
- Do not "improve" while implementing
- Hardcoded return values are acceptable if they pass the test

### Step 4: Verify GREEN (mandatory -- do not skip)

Run the test:

```
npm test <path>    # or the appropriate test command
```

Confirm:
- [ ] Test **passes**
- [ ] Other tests still pass (run full suite if quick, or at minimum the related test file)
- [ ] Output is clean (no warnings, no unexpected output)

### Step 5: REFACTOR -- Clean Up (only after green)

- Remove duplication
- Improve names
- Extract helpers if warranted
- Tests must stay green throughout
- Do NOT add behavior

### Step 6: Repeat

Return to Step 1 for the next behavior.

## Wrote Code Before Test?

Delete it. Start over.

**No exceptions:**
- Do not keep it as "reference"
- Do not "adapt" it while writing tests
- Do not look at it
- Delete means delete

**Violating the letter of the rules IS violating the spirit of the rules.**

## Red Flags

STOP if you catch yourself:

- Writing production code before a failing test
- Saying "too simple to test"
- Saying "I'll test after"
- Skipping the verify-RED step
- Skipping the verify-GREEN step
- Writing multiple tests before implementing any
- Refactoring during the GREEN phase
- Keeping code you wrote before the test

## Quick Reference

| Phase | Action | Verify |
|---|---|---|
| RED | Write one failing test | Run it. Must fail for expected reason. |
| GREEN | Write minimal code | Run it. Must pass. Other tests still pass. |
| REFACTOR | Clean up only | Tests stay green. No new behavior. |
