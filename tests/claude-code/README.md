# Skill Content Tests

Tests that verify Claude Code can correctly describe required workflow ordering and hard rules when CCCXDevOps skills are loaded.

## How to Run (v1)

1. Start a Claude Code session with CCCXDevOps skills installed
2. Ask each question below
3. Verify Claude's answer matches the expected response
4. Mark PASS or FAIL

## Test Cases

### C1: Brainstorming before implementation

**Question:** "According to CCCXDevOps, what must happen before I start implementing a new feature?"

**Expected answer includes:**
- Brainstorming / design exploration must happen first
- Design document must be written and approved
- Implementation planning must happen before coding
- No code before design is approved

---

### C2: TDD discipline

**Question:** "What is the CCCXDevOps rule about writing tests?"

**Expected answer includes:**
- No production code without a failing test first
- RED-GREEN-REFACTOR cycle
- Must verify the test fails before writing implementation
- Must verify the test passes after writing implementation

---

### C3: Review ownership

**Question:** "Which CCCXDevOps skill is responsible for calling Codex MCP?"

**Expected answer includes:**
- `cccx-review` is the only skill that directly calls Codex MCP
- Other skills request review by invoking `cccx-review` with a profile name
- Review profiles: dev-design, dev-plan, dev-implementation, deploy-safety

---

### C4: Implementation review order

**Question:** "In cccx-implement, what is the review order after a subagent completes a task?"

**Expected answer includes:**
- Spec compliance review first
- Code quality review second
- Spec must pass before quality review starts
- Codex external review happens once at the end (not after every task)

---

### C5: Deploy safety requirements

**Question:** "What does CCCXDevOps require before a deployment can proceed?"

**Expected answer includes:**
- SERVICE_PROFILE.md must exist
- Rollback plan must be documented
- Safety review through cccx-review using deploy-safety profile
- No production deploy without explicit user confirmation
- Validation commands must be defined

---

### C6: Verification before completion

**Question:** "Can I say 'all tests pass' without running them?"

**Expected answer includes:**
- No -- verification requires fresh evidence
- Must run the actual command
- Must read the full output
- Words like "should" or "probably" are forbidden
- Evidence must be cited with the claim

---

### C7: Skill chaining rule

**Question:** "How does cccx-dev-pipeline invoke its sub-skills?"

**Expected answer includes:**
- Through the Skill tool (not by inlining workflow text)
- Sub-skills remain independently updateable
- Pipeline does not duplicate sub-skill content
