# Review Profile: dev-design

## Intent

Evaluate a design document for completeness, clarity, and risk before implementation planning begins.

## Required Evidence

- Design document (full text)
- Feature brief or user request that prompted the design
- Relevant project context (tech stack, existing patterns)

## Review Questions

1. **Completeness:** Does the design address all stated requirements?
2. **Ambiguity:** Are there vague or underspecified sections that would lead to different interpretations?
3. **Risks:** What could go wrong? Are failure modes addressed?
4. **Scope:** Is the scope appropriate -- not too broad, not missing key pieces?
5. **Testability:** Can the proposed design be verified with automated tests?
6. **Alternatives:** Were trade-offs between approaches adequately considered?

## Approval Threshold

- APPROVE: Design is clear, complete, and addresses requirements with reasonable risk handling
- REQUEST_CHANGES: Design has gaps or ambiguities that would cause problems during planning
- BLOCK: Design is fundamentally flawed or missing critical requirements
