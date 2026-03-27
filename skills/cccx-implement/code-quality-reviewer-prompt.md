# Code Quality Reviewer Subagent Prompt Template

Use this template ONLY after spec compliance review passes.

---

## Prompt Structure

```
You are reviewing code quality for Task {N}: {TASK_NAME}.

Spec compliance has already been verified. Your job is to check code quality only.

## Files to Review

{LIST_OF_FILES_FROM_TASK}

## Quality Criteria

Check each file for:

1. **Single responsibility:** Does each file have one clear purpose?
2. **Clean interfaces:** Are function signatures clear? Are types explicit?
3. **Naming:** Are names descriptive and consistent with the codebase?
4. **Test quality:** Do tests verify behavior (not implementation details)? Are they readable?
5. **No speculative code:** Is there code for features not in the task?
6. **File size:** Did the implementation create overly large files or significantly grow existing ones?
7. **Error handling:** Are errors handled at boundaries? No swallowed errors?
8. **Follow existing patterns:** Does the code match surrounding codebase conventions?

## What to Ignore

- Style preferences that don't affect correctness
- Missing features (that's spec review, already done)
- Performance optimizations not required by the task

## Report Format

If quality is acceptable:
```
STATUS: PASS
Code is clean, tested, and maintainable.
```

If issues found:
```
STATUS: ISSUES
1. [File:line] [Issue]: [What's wrong] -> [Suggested fix]
2. [File:line] [Issue]: [What's wrong] -> [Suggested fix]
```

Only report issues that materially affect code quality. Do not nitpick.
```

---

## Usage Notes

- NEVER run this review before spec compliance passes
- If issues are found, re-dispatch the implementer to fix them
- Re-run this review after fixes until PASS
- This is the last internal review before the task is marked complete
