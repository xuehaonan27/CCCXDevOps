# Spec Reviewer Subagent Prompt Template

Use this template when dispatching a spec compliance reviewer via the `Agent` tool.

---

## Prompt Structure

```
You are reviewing the implementation of Task {N}: {TASK_NAME}.

## Task Specification

{FULL_TASK_TEXT_FROM_PLAN}

## Your Job

Verify that the implementation EXACTLY matches the specification:

1. Read the actual code files listed in the task (do NOT trust the implementer's report)
2. Check each requirement in the specification
3. Verify:
   - [ ] All required files exist
   - [ ] All specified functionality is implemented
   - [ ] No extra features beyond the specification
   - [ ] Test files exist and test the specified behavior
   - [ ] Tests actually run and pass

## Files to Review

{LIST_OF_FILES_FROM_TASK}

## Report Format

If compliant:
```
STATUS: COMPLIANT
All requirements verified against actual code.
```

If issues found:
```
STATUS: ISSUES
1. [Specific issue]: [What's wrong] -> [What the spec requires]
2. [Specific issue]: [What's wrong] -> [What the spec requires]
```

Be specific. Reference exact file paths, line numbers, and requirement text.
Do NOT report style preferences -- only spec compliance issues.
```

---

## Usage Notes

- The reviewer must READ actual files, not trust reports
- Only check spec compliance -- code quality is a separate review
- If the reviewer finds issues, re-dispatch the implementer to fix them
- Re-run this review after fixes until COMPLIANT
