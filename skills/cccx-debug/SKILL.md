---
name: cccx-debug
description: Use when encountering any bug, test failure, unexpected behavior, or performance problem. Especially when under time pressure or tempted to "just try a quick fix."
---

# Systematic Debugging

## Overview

Find the root cause before attempting a fix. Random changes create new bugs. Systematic investigation finds the actual problem.

**Iron Law: NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST**

## When to Use

- Any bug or test failure
- Unexpected behavior
- Performance problems
- Especially when tempted to skip investigation

## Workflow

### Phase 1: Root Cause Investigation (mandatory before ANY fix attempt)

**1. Read error messages carefully**
- Do not skip errors or warnings
- Read stack traces completely
- Note line numbers, file paths, error codes
- Read the FULL error, not just the first line

**2. Reproduce consistently**
- Can you trigger it reliably?
- What are the exact steps?
- Does it happen every time?
- If intermittent, what conditions make it more likely?

**3. Check recent changes**
- `git log --oneline -10`
- `git diff` for unstaged changes
- New dependencies, config changes
- Environmental differences (different machine, different data)

**4. Trace data flow**
- Where does the bad value originate?
- What called this function with the bad input?
- Keep tracing upstream until you find the source
- See `root-cause-tracing.md` for detailed technique

**5. For multi-component systems: gather evidence at each boundary**
- What data enters each component?
- What data exits each component?
- Where does the data transformation break?
- Log at boundaries, run once, analyze

### Phase 2: Pattern Analysis

**1. Find working examples**
- Is there similar code in the codebase that works?
- What's different between working and broken?

**2. Compare against references**
- Read the reference implementation COMPLETELY
- Don't skim -- read every line
- Understand the pattern fully

**3. Identify differences**
- List every difference between working and broken
- Don't assume "that can't matter"

### Phase 3: Hypothesis and Testing

**1. Form a single hypothesis**
- State clearly: "I think X is the root cause because Y"
- Write it down
- Be specific, not vague

**2. Test minimally**
- Make the SMALLEST possible change to test the hypothesis
- One variable at a time
- Do not fix multiple things at once

**3. Evaluate**
- Did it work? -> Phase 4
- Didn't work? -> Form a NEW hypothesis (do not add more fixes on top)

### Phase 4: Implementation

**1. Create a failing test (invoke `cccx-tdd`)**
- Write a test that reproduces the bug
- Verify it fails for the right reason

**2. Implement a single fix**
- Address the root cause identified in Phase 1-3
- ONE change at a time
- No "while I'm here" improvements

**3. Verify (invoke `cccx-verify`)**
- Test passes
- No other tests broken
- Bug is actually resolved

### Escalation: 3+ Failed Fix Attempts

If you have tried 3 or more fixes and none worked:

**STOP.**

This pattern indicates:
- Each fix reveals a new problem in a different place
- Fixes require "massive refactoring"
- Each fix creates new symptoms elsewhere

**Do not attempt fix #4.** Instead:
- Question the architecture
- Present findings to user
- Discuss whether the approach needs to change fundamentally

**Optional Codex consultation:** For complex or stalled debugging, request review through `cccx-review` with profile `dev-implementation`, presenting the investigation findings and failed attempts.

## Red Flags

STOP if you catch yourself:

- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip the test, I'll manually verify"
- "It's probably X, let me fix that" (without evidence)
- "I don't fully understand but this might work"
- Proposing solutions before completing Phase 1
- "One more fix attempt" when already tried 2+

## Quick Reference

| Phase | Do | Don't |
|---|---|---|
| 1. Investigate | Read errors, reproduce, trace data flow | Jump to fixing |
| 2. Analyze | Find working examples, list differences | Assume "that can't matter" |
| 3. Hypothesize | One hypothesis, one minimal test | Multiple changes at once |
| 4. Implement | Failing test, single fix, verify | "While I'm here" improvements |
