# Implementer Subagent Prompt Template

Use this template when dispatching an implementer subagent via the `Agent` tool.

---

## Prompt Structure

```
You are implementing Task {N} of a feature: {FEATURE_NAME}.

## Context

{SCENE_SETTING}

This task is part of a larger implementation plan. You are working in a git worktree at {WORKTREE_PATH} on branch {BRANCH_NAME}.

## Your Task

{FULL_TASK_TEXT_FROM_PLAN}

## Requirements

1. Follow TDD discipline: write a failing test FIRST, then implement.
   - Write the test
   - Run it: it must FAIL for the expected reason
   - Write the minimal code to make it pass
   - Run it: it must PASS
   - Refactor if needed (tests stay green)

2. Do NOT modify files outside the scope of this task.

3. Do NOT add features not specified in the task.

4. Commit your work with a clear message when done.

## When Done

Report your status:
- DONE: Task complete, tests passing
- DONE_WITH_CONCERNS: Task complete but you noticed [specific concern]
- NEEDS_CONTEXT: Cannot proceed because [specific missing information]
- BLOCKED: Cannot proceed because [specific blocker]

Include:
- Files created/modified
- Tests added
- Test output (pass count, fail count)
- Any concerns or questions
```

---

## Usage Notes

- Replace all `{PLACEHOLDERS}` with actual values
- Include the FULL task text -- do not reference the plan file
- If the implementer asks questions, answer them and re-dispatch
- If BLOCKED, assess whether to provide more context, break the task, or escalate
