# Root Cause Tracing

Technique for tracing bugs backward through the call stack to find the original trigger.

## The Technique

When you see a bad value, wrong state, or unexpected behavior:

### 1. Start at the symptom

Where does the problem manifest? Note the exact location: file, line, function, variable.

### 2. Ask "where did this value come from?"

Look at the function that produced the bad value. Check:
- What arguments were passed in?
- Which argument is wrong?
- Where was that argument computed?

### 3. Trace upstream

Move to the caller. Repeat step 2:
- What called this function?
- What data did it pass?
- Where did THAT data come from?

### 4. Keep going until you find the source

The root cause is where correct data becomes incorrect:
- A wrong default value
- A missing validation
- A stale cache
- A race condition
- A wrong assumption about input format

### 5. Fix at the source, not at the symptom

```
BAD:  Add a null check at the crash site
GOOD: Fix the function that produces null when it shouldn't
```

## Example

```
Symptom:     TypeError: Cannot read property 'name' of undefined
  at renderUser (components/User.tsx:15)

Step 1: user.name crashes because user is undefined
Step 2: user comes from props.user, passed by parent
Step 3: parent gets user from useUser(id), which returns undefined
Step 4: useUser returns undefined because id is NaN
Step 5: id is NaN because route param is parsed with parseInt but param is "abc"

Root cause: Missing validation of route parameter
Fix: Validate and reject non-numeric route params at the router level
```

## When to Add Instrumentation

If tracing by reading code is not sufficient:

1. Add a log at the first boundary you suspect
2. Add a log at the last known-good point
3. Run the reproducing case ONCE
4. Analyze the logs to narrow the failing region
5. Remove the logs after finding the root cause

Do NOT add logs everywhere. Be surgical.
