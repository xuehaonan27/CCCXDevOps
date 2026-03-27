# Defense in Depth

Technique for adding validation at multiple layers to make bugs impossible, not just hard to trigger.

## When to Use

After fixing a root cause, consider whether the fix is sufficient or whether additional layers of defense are needed.

Use defense in depth when:
- The bug could recur from a different entry point
- The fix relies on a single validation that could be bypassed
- The consequence of the bug is severe (data loss, security breach, financial impact)

## The Pattern

Instead of validating at one point, validate at multiple layers:

```
Layer 1: Input validation (reject bad data at the boundary)
Layer 2: Type system (make invalid states unrepresentable)
Layer 3: Runtime checks (assert invariants at key points)
Layer 4: Output validation (verify results before returning)
```

## Example

**Bug:** User ID was passed as a string instead of number, causing a silent database lookup failure.

**Single fix:** Validate user ID at the API endpoint.

**Defense in depth:**
1. API endpoint validates and parses user ID (Layer 1)
2. TypeScript types enforce `userId: number` (Layer 2)
3. Database query function asserts `typeof id === 'number'` (Layer 3)
4. Response serializer checks user object is not null before sending (Layer 4)

## When NOT to Use

- Do not add defensive checks for impossible conditions within internal code
- Do not add validation where the type system already prevents the error
- Do not add try/catch blocks around code that should never throw
- Trust framework guarantees; defend at system boundaries

## Balance

Defense in depth is for system boundaries and high-severity paths. It is not an excuse to add paranoid checks everywhere. The goal is to prevent bugs from reaching production, not to handle every theoretical failure.
