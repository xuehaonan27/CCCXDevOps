# Review Profile: dev-plan

## Intent

Evaluate an implementation plan for completeness, task granularity, and executability before development begins.

## Required Evidence

- Implementation plan (full text)
- Approved design document that the plan implements
- Project structure listing (to verify file paths)

## Review Questions

1. **Granularity:** Are all tasks at 2-5 minute granularity?
2. **Completeness:** Does every requirement from the design have a corresponding task?
3. **No placeholders:** Are there any TBD, TODO, "similar to Task N", or incomplete code blocks?
4. **File paths:** Do all referenced file paths exist or are clearly marked as new files to create?
5. **Test coverage:** Does every feature task have a corresponding test task?
6. **Order:** Can tasks be executed in the stated order without dependency conflicts?
7. **Commands:** Are all test/build commands complete and runnable?
8. **Edge cases:** Are error cases and boundary conditions covered?

## Approval Threshold

- APPROVE: Plan is executable as-is -- a developer could follow it step by step without guessing
- REQUEST_CHANGES: Plan has gaps, placeholders, or ambiguous steps that would block execution
- BLOCK: Plan is fundamentally misaligned with the design or missing large sections
