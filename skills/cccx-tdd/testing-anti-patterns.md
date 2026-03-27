# Testing Anti-Patterns

Common testing mistakes to avoid. Referenced by `cccx-tdd`.

## 1. Testing Mock Behavior

**Problem:** Tests verify that mocks were called correctly, not that the real system works.

```javascript
// BAD: tests the mock, not the system
test('sends email', () => {
  const mockMailer = { send: jest.fn() };
  notifyUser(mockMailer, 'hello');
  expect(mockMailer.send).toHaveBeenCalledWith('hello');
});
```

**Fix:** Test real behavior. Use mocks only for external service boundaries.

```javascript
// GOOD: tests actual behavior
test('sends email', async () => {
  const result = await notifyUser(testMailer, 'hello');
  expect(result.delivered).toBe(true);
  expect(testMailer.lastMessage.body).toBe('hello');
});
```

## 2. Test-Only Methods in Production Code

**Problem:** Adding public methods or accessors solely for test access.

```python
# BAD: exposes internal state for tests
class Cache:
    def get_internal_store(self):  # exists only for tests
        return self._store
```

**Fix:** Test through public interfaces. If you can't test it, the design needs to change.

## 3. Tests That Pass Immediately

**Problem:** Writing a test after implementation that passes on the first run. This proves nothing about intent.

**Fix:** If you accidentally wrote code first, delete it. Write the test. Watch it fail. Re-implement.

## 4. Overly Specific Tests

**Problem:** Tests that break when irrelevant details change (exact error messages, log output format, internal method names).

**Fix:** Test observable behavior and outputs, not implementation details.

## 5. Test Pollution

**Problem:** Tests that depend on other tests running first, or leave state that affects subsequent tests.

**Fix:** Each test must set up its own state and clean up after itself. Run tests in random order to detect pollution.

## 6. Ignoring Edge Cases

**Problem:** Only testing the happy path.

**Fix:** Test boundaries: empty input, null, maximum values, concurrent access, network failure.

## 7. Snapshot Tests as Primary Tests

**Problem:** Using snapshot tests as the main test strategy. They pass when output matches a saved snapshot, even if the output is wrong.

**Fix:** Use snapshot tests only for UI rendering stability. Use behavioral assertions for logic.
