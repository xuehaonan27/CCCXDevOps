# Skill Triggering Tests

Manual prompt + expected-skill pairs for validating that Claude Code activates the correct CCCXDevOps skill for a given user request.

## How to Run (v1)

1. Start a Claude Code session with CCCXDevOps skills installed
2. For each test case below, enter the prompt
3. Verify Claude invokes the expected skill before taking action
4. Mark PASS or FAIL

Automated trigger testing is deferred until a reliable automation path exists.

## Test Cases

### T1: Feature request triggers brainstorming

**Prompt:** "I want to add user authentication to this app"

**Expected:** `cccx-brainstorm` is invoked before any code is written.

**NOT expected:** Claude starts writing code immediately.

---

### T2: Bug report triggers debugging

**Prompt:** "The login button is broken on mobile -- it doesn't respond to taps"

**Expected:** `cccx-debug` is invoked. Phase 1 (root cause investigation) begins before any fix attempt.

**NOT expected:** Claude immediately proposes a code change without investigation.

---

### T3: Implementation request with plan triggers implement

**Prompt:** "I have an approved implementation plan at docs/cccx/plans/auth.md. Please implement it."

**Expected:** `cccx-implement` is invoked. Worktree setup occurs. Subagent dispatch begins per plan tasks.

**NOT expected:** Claude reads the plan and starts coding without invoking the skill.

---

### T4: Completion claim triggers verification

**Prompt:** "Are all the tests passing now?"

**Expected:** `cccx-verify` is invoked. Fresh test command is run and output is read before answering.

**NOT expected:** Claude says "yes" based on prior context without running verification.

---

### T5: Deploy request triggers deploy

**Prompt:** "Deploy this to staging"

**Expected:** `cccx-deploy` is invoked. SERVICE_PROFILE.md is checked. Safety review occurs.

**NOT expected:** Claude runs a deploy command without reviewing the deployment plan.

---

### T6: Merge request triggers finish

**Prompt:** "This looks good, let's merge it"

**Expected:** `cccx-finish` is invoked. Final verification and review occur before presenting merge options.

**NOT expected:** Claude immediately runs `git merge` without review.
