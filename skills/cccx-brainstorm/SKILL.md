---
name: cccx-brainstorm
description: Use before any creative work -- new features, components, architecture changes, or significant behavior modifications. Must complete before implementation planning.
---

# Design Exploration

## Overview

Explore requirements, constraints, and approaches before committing to implementation. The output is an approved design document, not code.

**Hard Gate: NO CODE, NO SCAFFOLDING, NO IMPLEMENTATION until design is approved.**

## When to Use

- New feature or component
- Significant behavior change
- Architecture decision
- Any creative work where the approach is not obvious

Anti-pattern: "This is too simple to need design." Every project benefits from even 5 minutes of design thinking.

## Workflow

### Phase 1: Explore Context

1. Read relevant project files, docs, recent commits
2. Check for a `FEATURE_BRIEF.md` in the project root. If it exists, use it as primary context. If not, gather requirements from the user's request.
3. Understand existing patterns and conventions in the codebase

### Phase 2: Clarify Requirements

Ask clarifying questions **one at a time**:
- What is the user trying to accomplish?
- What are the constraints (timeline, compatibility, tech stack)?
- What is explicitly out of scope?
- Are there existing patterns to follow or avoid?

Do not ask all questions at once. Each answer may change the next question.

### Phase 3: Propose Approaches

Present 2-3 approaches with trade-offs:

```
## Approach A: <name>
- How: <brief description>
- Pros: <advantages>
- Cons: <disadvantages>
- Risk: <what could go wrong>

## Approach B: <name>
...
```

Let the user choose. Do not pick for them unless asked.

### Phase 4: Design Document

After the user selects an approach, write a design document covering:

1. **Problem statement** -- what we're solving and why
2. **Chosen approach** -- what we're building
3. **File structure** -- new/modified files with responsibilities
4. **Key decisions** -- why this approach over alternatives
5. **Edge cases** -- known boundary conditions
6. **Testing strategy** -- how we'll verify correctness
7. **Non-goals** -- what this design explicitly does NOT cover

Save to: `docs/cccx/specs/YYYY-MM-DD-<topic>-design.md`

### Phase 5: Self-Review

Before presenting to the user, check:
- [ ] No placeholders ("TBD", "TODO")
- [ ] Consistent naming across sections
- [ ] Scope matches requirements (not too broad, not missing pieces)
- [ ] Ambiguous sections identified and resolved
- [ ] Testing strategy is concrete, not vague

### Phase 6: External Review

Request Codex review through `cccx-review`:

1. Write `.cccx/review/REVIEW_REQUEST.md` with:
   - profile: `dev-design`
   - subject: the design document
   - goal: validate design completeness and identify risks
   - evidence: the full design document + feature brief
2. Invoke `cccx-review`
3. Handle the verdict:
   - APPROVE: proceed to Phase 7
   - REQUEST_CHANGES: address the issues, then re-submit by writing a new `.cccx/review/REVIEW_REQUEST.md` with the `threadId` from the previous `REVIEW_RESPONSE.md` and a "Changes Since Last Review" section describing what was fixed. Invoke `cccx-review` again.
   - BLOCK: present to user for decision
   - SKIPPED (Codex not configured): warn user that external review was not performed, then proceed to Phase 7

### Phase 7: User Approval

Present the reviewed design to the user for final approval. Only after explicit approval, invoke `cccx-plan` as the next step.

## Red Flags

- Writing any code before design approval
- Skipping clarifying questions because "it's obvious"
- Presenting only one approach (always offer alternatives)
- Design doc with placeholders
- Skipping external review checkpoint

## Common Mistakes

| Mistake | Fix |
|---|---|
| Jumping to implementation | Stop. Design first. Code later. |
| One-approach presentation | Always present 2-3 options with trade-offs |
| Vague testing strategy | Be specific: which tests, what they verify |
| Asking all questions at once | One at a time. Each answer informs the next. |
