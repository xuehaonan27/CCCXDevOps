# Integration Test Fixtures

## Fixture: mini-calculator

A minimal Node.js project for end-to-end development workflow testing.

### Purpose

Validate the full `cccx-dev-pipeline` flow:
1. Brainstorm a feature (add `multiply` function)
2. Plan the implementation
3. Set up worktree
4. Implement with TDD
5. Verify tests pass
6. Finish the branch

### Setup

```bash
cd tests/fixtures/mini-calculator
npm install
npm test    # Should show 2 passing tests (add, subtract)
```

### Test Scenario

**Feature request:** "Add a multiply function to the calculator"

**Expected pipeline behavior:**
1. `cccx-brainstorm` explores the feature, writes a simple design doc
2. `cccx-plan` creates a plan with:
   - Task 1: Write failing test for multiply
   - Task 2: Implement multiply
   - Task 3: Verify
3. `cccx-worktree` creates isolated workspace
4. `cccx-implement` executes the plan with TDD
5. `cccx-verify` confirms all tests pass (original 2 + new multiply test)
6. `cccx-finish` presents merge options

### Seeded Review Issue

The fixture intentionally has no input validation. A good Codex review should flag:
- No check for non-numeric inputs in existing functions
- The new multiply function should also handle edge cases (multiply by 0, negative numbers)

This validates success criterion #5: "Codex review catches at least one seeded issue in test fixtures."
