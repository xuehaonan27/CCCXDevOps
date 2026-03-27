# Review Profile: dev-implementation

## Intent

Evaluate a completed implementation for code quality, test coverage, spec compliance, and architectural coherence.

## Required Evidence

- Git diff (base..head) or summary of changes
- Test output (full suite, not just new tests)
- Implementation plan that was followed
- Commit log for the implementation branch

## Review Questions

1. **Spec compliance:** Does the implementation match the approved plan? Nothing extra, nothing missing?
2. **Test coverage:** Does every new function/method have at least one test? Were tests written first (TDD)?
3. **Code quality:** Are files focused (single responsibility)? Are interfaces clean? Are names clear?
4. **Existing patterns:** Does the implementation follow existing codebase conventions?
5. **Error handling:** Are errors handled at system boundaries? No swallowed errors?
6. **No speculative code:** Is there code for features not in the plan?
7. **Architectural coherence:** Do the pieces fit together? Are there circular dependencies or unclear boundaries?
8. **Security:** Any obvious vulnerabilities (injection, exposed secrets, missing validation)?

## Approval Threshold

- APPROVE: Implementation is clean, tested, matches spec, and ready to merge
- REQUEST_CHANGES: Implementation has quality issues, missing tests, or deviates from spec
- BLOCK: Implementation has fundamental architectural problems or security vulnerabilities
