# Code Quality Principles

These principles apply across all CCCXDevOps development workflows.

## File Boundaries

- Each file has one clear responsibility
- Prefer smaller, focused files over large files doing too much
- Files that change together should live together
- Follow established patterns in existing codebases

## Interface Clarity

- Design units with clear boundaries and well-defined interfaces
- Each unit should be understandable independently
- Each unit should be testable independently
- Change internals without breaking consumers

## Follow Existing Patterns

- Read and understand existing code before modifying
- Match the style and conventions of the surrounding codebase
- If introducing a new pattern, it must be clearly better -- not just different

## No Speculative Features

- Build only what is requested (YAGNI)
- Do not add "nice to have" features
- Do not add configurability for hypothetical future needs
- Three similar lines of code is better than a premature abstraction

## Error Handling

- Validate at system boundaries (user input, external APIs)
- Trust internal code and framework guarantees
- Do not add defensive checks for impossible conditions
- Prefer clear failure over silent swallowing of errors

## Naming

- Names should describe what the thing IS or DOES
- Avoid abbreviations unless universally understood in context
- Match the naming conventions of the surrounding codebase

## Simplicity

- The right amount of complexity is the minimum needed for the current task
- If you can solve it in fewer lines without sacrificing clarity, do so
- Do not create helpers or abstractions for one-time operations
